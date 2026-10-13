import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_monaco/flutter_monaco.dart';
import 'package:pairspace_client/pairspace_client.dart';

import '../client.dart';

/// The live Monaco controller, so other screens can pause it while dialogs are open.
MonacoController? activeMonacoController;

class CodeEditorPanel extends StatefulWidget {
  const CodeEditorPanel({super.key, required this.roomId});
  final int roomId;

  @override
  State<CodeEditorPanel> createState() => _CodeEditorPanelState();
}

class _CodeEditorPanelState extends State<CodeEditorPanel> {
  static const _initialText = '# Write your solution here\n';

  /// Starter code per language. Keys must match the keys of [_languages].
  static const _starters = <String, String>{
    'Python': '# Write your solution here\n',
    'Java':
        'public class Main {\n'
        '    public static void main(String[] args) {\n'
        '        // Write your solution here\n'
        '    }\n'
        '}\n',
    'C++':
        '#include <iostream>\n'
        'using namespace std;\n'
        '\n'
        'int main() {\n'
        '    // Write your solution here\n'
        '    return 0;\n'
        '}\n',
  };

  static final _languages = <String, MonacoLanguage>{
    'Python': MonacoLanguage('python'),
    // 'JavaScript': MonacoLanguage('javascript'),
    'Java': MonacoLanguage('java'),
    'C++': MonacoLanguage('cpp'),
  };

  // Fixed options: language changes go through the controller, not here.
  static final _options = EditorOptions(
    language: MonacoLanguage('python'),
    theme: MonacoTheme.vsDark,
    fontSize: 14,
    minimap: const MonacoMinimapOptions(enabled: false),
  );

  // Identifies this browser tab so we can ignore our own echoed updates.
  final String _senderId =
      '${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(1 << 30)}';

  MonacoController? _controller;
  String _selected = 'Python';

  // Last text we sent or applied. Used to avoid echo loops.
  String _lastSyncedText = _initialText;

  /// Code kept per language while another language is showing.
  final Map<String, String> _buffers = {};
  int _version = 0;

  StreamController<CodeUpdate>? _outgoing;
  StreamSubscription<CodeUpdate>? _incomingSub;
  StreamSubscription<dynamic>? _contentSub;
  Timer? _debounce;
  Timer? _reconnectTimer;
  int _retry = 0;
  bool _disposed = false;
  Timer? _syncTimer;
  int _remoteApplies = 0;
  String? _unconfirmed;
  // Run Code (shared with everyone in the room)
  StreamSubscription<RunResult>? _runSub;
  Timer? _runReconnect;
  Timer? _runTimeout;
  RunResult? _runResult;
  bool _running = false;
  final TextEditingController _stdinCtrl = TextEditingController();
  double _outputHeight = 235;
  StreamSubscription<StdinUpdate>? _stdinSub;
  Timer? _stdinReconnect;
  Timer? _stdinDebounce;

  void _onReady(MonacoController c) => unawaited(_init(c));

  Future<void> _init(MonacoController c) async {
    _controller = c;
    activeMonacoController = c;

    // Restore the saved code (and language) before going live.
    try {
      final snap = await client.code.getCode(widget.roomId);
      if (snap != null) {
        if (_languages.containsKey(snap.language)) {
          if (mounted) setState(() => _selected = snap.language);
          await c.document.setLanguage(_languages[snap.language]!);
        }
        _lastSyncedText = snap.content; // set first so no echo is sent
        await c.document.setText(snap.content);
      }
    } catch (e) {
      debugPrint('getCode failed: $e');
    }

    if (!mounted) return;
    _contentSub = c.onContentChanged.listen((_) => _scheduleSend());
    _connect();
    _connectRun();
    _connectStdin();
  }

  void _connect() {
    if (_disposed) return;
    _incomingSub?.cancel();
    final out = StreamController<CodeUpdate>();
    _outgoing = out;
    _incomingSub = client.code
        .codeStream(widget.roomId, out.stream)
        .listen(
          _onRemote,
          onError: (Object e) {
            debugPrint('codeStream error: $e');
            _scheduleReconnect();
          },
          onDone: _scheduleReconnect,
        );
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 4), (_) async {
      if (_outgoing == null || _disposed) {
        return;
      } // offline: reconnect handles it
      try {
        final pending = _unconfirmed;
        if (pending != null) {
          final snap = await client.code.getCode(widget.roomId);
          if (snap != null && snap.content == pending) {
            _unconfirmed = null; // the server has it
          } else if (_outgoing != null) {
            debugPrint('code: server missing our edit, resending');
            await _sendNow(force: true);
          }
          return;
        }
        await _resync();
      } catch (e) {
        debugPrint('code: periodic sync error: $e');
      }
    });
  }

  void _scheduleReconnect() {
    if (_disposed || !mounted) return;
    if (_reconnectTimer?.isActive ?? false) return; // error + done both fire

    // Drop the dead outgoing stream. While it is null, _sendNow() returns
    // early and keeps _lastSyncedText unchanged, so edits typed while offline
    // are still treated as "unsent".
    _outgoing?.close();
    _outgoing = null;

    final seconds = min(1 << min(_retry, 4), 10); // 1, 2, 4, 8, 10, 10...
    _retry++;
    _reconnectTimer = Timer(Duration(seconds: seconds), () async {
      try {
        await _resync(); // throws if the server is still unreachable
        _retry = 0;
        _connect();

        // Give the server a moment to register the new stream, then fetch the
        // saved code once more so nothing sent in that gap is missed.
        await Future<void>.delayed(const Duration(seconds: 2));
        if (_disposed) return;
        await _resync();

        debugPrint('code: reconnected, sending held edit');
        await _sendNow(); // push anything typed while offline
      } catch (e) {
        debugPrint('code reconnect failed: $e');
        _scheduleReconnect();
      }
    });
    debugPrint('code stream dropped, scheduling reconnect (retry $_retry)');
  }

  /// Pull the saved code from the server after a drop, unless the user has
  /// typed something that hasn't been sent yet (then keep their text).
  Future<void> _resync() async {
    final c = _controller;
    if (c == null) return;
    final applies = _remoteApplies;
    final sentVersion = _version;
    final snap = await client.code.getCode(widget.roomId);
    if (snap == null) return;
    if (applies != _remoteApplies || sentVersion != _version) {
      debugPrint('code: resync skipped (changed while fetching)');
      return;
    }

    final current = await c.document.getText();
    if (current != _lastSyncedText) {
      debugPrint('code: resync skipped (editor differs from last synced)');
      return;
    }

    if (snap.language != _selected && _languages.containsKey(snap.language)) {
      _buffers[_selected] = current;
      if (mounted) setState(() => _selected = snap.language);
      await c.document.setLanguage(_languages[snap.language]!);
    }
    if (snap.content != current) {
      _unconfirmed = null;
      _lastSyncedText = snap.content; // set first so no echo is sent
      await _applyRemoteText(c, current, snap.content);
    }
  }

  void _scheduleSend() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 120), _sendNow);
  }

  Future<void> _sendNow({bool force = false}) async {
    final c = _controller;
    if (c == null) return;
    final text = await c.document.getText();
    final out = _outgoing; // read AFTER the await, so it can't be stale
    if (out == null || out.isClosed) {
      debugPrint('code: offline, holding edit');
      return;
    }
    if (!force && text == _lastSyncedText) return;
    _lastSyncedText = text;
    _unconfirmed = text;
    out.add(
      CodeUpdate(
        roomId: widget.roomId,
        senderId: _senderId,
        version: ++_version,
        text: text,
        language: _selected,
      ),
    );
  }

  Future<void> _onRemote(CodeUpdate u) async {
    debugPrint('code: remote update received');
    if (u.senderId == _senderId) return;
    final c = _controller;
    if (c == null) return;

    if (u.language != _selected && _languages.containsKey(u.language)) {
      // The other person switched language: keep our code for the old
      // language, then show their code for the new one.
      _buffers[_selected] = await c.document.getText();
      if (mounted) setState(() => _selected = u.language);
      await c.document.setLanguage(_languages[u.language]!);
      _lastSyncedText = u.text; // set first so the change event is ignored
      _remoteApplies++;
      _unconfirmed = null;
      await c.document.setText(u.text);
      return;
    }

    if (u.text == _lastSyncedText) return;

    // If the editor holds text we haven't sent yet, the user is typing right
    // now. Keep their text; their next send will overwrite the remote one.
    final current = await c.document.getText();
    if (current != _lastSyncedText) {
      debugPrint(
        'code: remote update IGNORED (editor differs from last synced)',
      );
      return;
    }

    _lastSyncedText =
        u.text; // set first so the resulting change event is ignored
    _remoteApplies++;
    _unconfirmed = null;
    await _applyRemoteText(c, current, u.text);
  }

  /// Applies [next] to the editor as ONE minimal edit (common prefix/suffix
  /// trimmed) instead of setText, so Monaco keeps cursor, scroll and undo.
  /// [cur] must be the editor text read just before calling this.
  Future<void> _applyRemoteText(
    MonacoController c,
    String cur,
    String next,
  ) async {
    if (cur == next) return;

    var start = 0;
    final maxPrefix = min(cur.length, next.length);
    while (start < maxPrefix &&
        cur.codeUnitAt(start) == next.codeUnitAt(start)) {
      start++;
    }
    var endCur = cur.length;
    var endNext = next.length;
    while (endCur > start &&
        endNext > start &&
        cur.codeUnitAt(endCur - 1) == next.codeUnitAt(endNext - 1)) {
      endCur--;
      endNext--;
    }

    // Never cut an emoji (surrogate pair) in half.
    bool isHigh(int u) => u >= 0xD800 && u <= 0xDBFF;
    bool isLow(int u) => u >= 0xDC00 && u <= 0xDFFF;
    if (start > 0 && isHigh(cur.codeUnitAt(start - 1))) start--;
    if (endCur < cur.length && isLow(cur.codeUnitAt(endCur))) {
      endCur++;
      endNext++;
    }

    // Offset -> Monaco's 1-based line/column.
    Position pos(String s, int offset) {
      var line = 1;
      var lastNewline = -1;
      for (var i = 0; i < offset; i++) {
        if (s.codeUnitAt(i) == 10) {
          line++;
          lastNewline = i;
        }
      }
      return Position(line: line, column: offset - lastNewline);
    }

    final from = pos(cur, start);
    final to = pos(cur, endCur);
    await c.document.replaceRange(
      Range(
        startLine: from.line,
        startColumn: from.column,
        endLine: to.line,
        endColumn: to.column,
      ),
      next.substring(start, endNext),
    );
  }

  void _connectRun() {
    if (_disposed) return;
    _runSub?.cancel();
    _runSub = client.run
        .runStream(widget.roomId)
        .listen(
          _onRunResult,
          onError: (Object e) {
            debugPrint('runStream error: $e');
            _scheduleRunReconnect();
          },
          onDone: _scheduleRunReconnect,
        );
  }

  void _scheduleRunReconnect() {
    if (_disposed || !mounted) return;
    if (_runReconnect?.isActive ?? false) return;
    _runReconnect = Timer(const Duration(seconds: 3), _connectRun);
  }

  void _onRunResult(RunResult r) {
    if (!mounted) return;
    _runTimeout?.cancel();
    if (r.status == 'Running') {
      // Safety net: never leave the button stuck on "Running".
      _runTimeout = Timer(const Duration(seconds: 30), () {
        if (mounted) setState(() => _running = false);
      });
    }
    setState(() {
      _runResult = r;
      _running = r.status == 'Running';
    });
  }

  Future<void> _run() async {
    final c = _controller;
    if (c == null || _running) return;
    final code = await c.document.getText();
    await _sendNow(force: true); // make sure the other person has this code
    if (!mounted) return;
    setState(() => _running = true);
    try {
      final r = await client.run.runCode(
        widget.roomId,
        _selected,
        code,
        stdin: _stdinCtrl.text.isEmpty ? null : _stdinCtrl.text,
      );
      _onRunResult(r);
    } catch (e) {
      debugPrint('runCode failed: $e');
      _onRunResult(
        RunResult(
          stdout: '',
          stderr: 'Could not run code. Check your connection.',
          status: 'Error',
        ),
      );
    }
  }

  Widget _buildResizeHandle() {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeRow,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragUpdate: (d) {
          final maxH = MediaQuery.of(context).size.height * 0.6;
          setState(() {
            _outputHeight = (_outputHeight - d.delta.dy).clamp(90.0, maxH);
          });
        },
        onDoubleTap: () => setState(() => _outputHeight = 235),
        child: Container(
          height: 12,
          color: const Color(0xFF2A2A2A),
          child: Center(
            child: Container(
              width: 40,
              height: 3,
              decoration: BoxDecoration(
                color: Colors.white38,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOutput() {
    final r = _runResult;
    final Color statusColor = _running
        ? Colors.amber
        : r == null
        ? Colors.grey
        : r.status == 'Accepted'
        ? Colors.greenAccent
        : Colors.redAccent;

    return Container(
      height: _outputHeight,
      color: const Color(0xFF1E1E1E),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FilledButton.icon(
                onPressed: _running ? null : _run,
                icon: _running
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.play_arrow, size: 18),
                label: Text(_running ? 'Running…' : 'Run'),
              ),
              const SizedBox(width: 12),
              if (r != null)
                Flexible(
                  child: Text(
                    r.status +
                        (!_running && r.timeMs != null
                            ? ' · ${r.timeMs} ms'
                            : ''),
                    style: TextStyle(color: statusColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const Spacer(),
              if (_selected == 'Java')
                const Text(
                  'Java: public class must be named Main',
                  style: TextStyle(fontSize: 12, color: Colors.white54),
                ),
            ],
          ),
          const SizedBox(height: 6),
          if (_outputHeight >= 190) ...[
            TextField(
              controller: _stdinCtrl,
              onChanged: _onStdinChanged,
              maxLines: 2,
              minLines: 2,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: Colors.white,
              ),
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
                labelText: 'Input (stdin), one value per line',
              ),
            ),
            const SizedBox(height: 6),
          ],
          const SizedBox(height: 6),
          Expanded(
            child: SingleChildScrollView(
              child: SelectableText.rich(
                TextSpan(
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    color: Colors.white,
                  ),
                  children: [
                    if (r == null)
                      const TextSpan(
                        text:
                            'Press Run to execute the code. Everyone in the room sees the output.',
                        style: TextStyle(color: Colors.white54),
                      )
                    else ...[
                      TextSpan(text: r.stdout),
                      if (r.stderr.isNotEmpty)
                        TextSpan(
                          text: r.stdout.isEmpty ? r.stderr : '\n${r.stderr}',
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _connectStdin() {
    if (_disposed) return;
    _stdinSub?.cancel();
    _stdinSub = client.run
        .stdinStream(widget.roomId)
        .listen(
          _onRemoteStdin,
          onError: (Object e) {
            debugPrint('stdinStream error: $e');
            _scheduleStdinReconnect();
          },
          onDone: _scheduleStdinReconnect,
        );
  }

  void _scheduleStdinReconnect() {
    if (_disposed || !mounted) return;
    if (_stdinReconnect?.isActive ?? false) return;
    _stdinReconnect = Timer(const Duration(seconds: 3), _connectStdin);
  }

  void _onRemoteStdin(StdinUpdate u) {
    if (!mounted || u.senderId == _senderId) return;
    if (_stdinCtrl.text == u.text) return;
    final sel = _stdinCtrl.selection;
    final offset = sel.isValid
        ? sel.baseOffset.clamp(0, u.text.length).toInt()
        : u.text.length;
    _stdinCtrl.value = TextEditingValue(
      text: u.text,
      selection: TextSelection.collapsed(offset: offset),
    );
  }

  void _onStdinChanged(String _) {
    _stdinDebounce?.cancel();
    _stdinDebounce = Timer(const Duration(milliseconds: 250), () async {
      try {
        await client.run.sendStdin(widget.roomId, _senderId, _stdinCtrl.text);
      } catch (e) {
        debugPrint('sendStdin failed: $e');
      }
    });
  }

  Future<void> _changeLanguage(String name) async {
    final c = _controller;
    if (c == null || name == _selected) return;

    // Remember the code of the language we are leaving, then show the new
    // language's own code (or its starter if nothing was written there yet).
    final current = await c.document.getText();
    _buffers[_selected] = current;
    final saved = _buffers[name];
    final next = (saved == null || saved.trim().isEmpty)
        ? (_starters[name] ?? '')
        : saved;

    setState(() => _selected = name);
    await c.document.setLanguage(_languages[name]!);
    _lastSyncedText = next; // set first so no extra echo is sent
    await c.document.setText(next);
    await _sendNow(force: true);
  }

  @override
  void dispose() {
    _disposed = true;
    _syncTimer?.cancel();
    _reconnectTimer?.cancel();
    _debounce?.cancel();
    _contentSub?.cancel();
    _incomingSub?.cancel();
    _runSub?.cancel();
    _runReconnect?.cancel();
    _runTimeout?.cancel();
    _outgoing?.close();
    _stdinCtrl.dispose();
    _stdinSub?.cancel();
    _stdinReconnect?.cancel();
    _stdinDebounce?.cancel();
    if (identical(activeMonacoController, _controller)) {
      activeMonacoController = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            border: Border(bottom: BorderSide(color: Color(0xFF334155))),
          ),
          child: Row(
            children: [
              const Icon(Icons.code, size: 18, color: Color(0xFF818CF8)),
              const SizedBox(width: 8),
              const Text(
                'Code',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              SegmentedButton<String>(
                showSelectedIcon: false,
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  backgroundColor: WidgetStateProperty.resolveWith<Color>((
                    states,
                  ) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white;
                    }
                    return const Color(0xFF1E293B);
                  }),
                  foregroundColor: WidgetStateProperty.resolveWith<Color>((
                    states,
                  ) {
                    if (states.contains(WidgetState.selected)) {
                      return const Color(0xFF0F172A);
                    }
                    return const Color(0xFFE2E8F0);
                  }),
                  side: const WidgetStatePropertyAll(
                    BorderSide(color: Color(0xFF334155)),
                  ),
                  textStyle: const WidgetStatePropertyAll(
                    TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                ),
                segments: _languages.keys
                    .map((l) => ButtonSegment(value: l, label: Text(l)))
                    .toList(),
                selected: {_selected},
                onSelectionChanged: (s) => _changeLanguage(s.first),
              ),
            ],
          ),
        ),
        Expanded(
          child: MonacoEditor(
            initialText: _initialText,
            options: _options,
            onReady: _onReady,
          ),
        ),
        _buildResizeHandle(),
        _buildOutput(),
      ],
    );
  }
}
