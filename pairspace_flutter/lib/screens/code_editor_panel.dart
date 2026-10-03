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
  int _version = 0;

  StreamController<CodeUpdate>? _outgoing;
  StreamSubscription<CodeUpdate>? _incomingSub;
  StreamSubscription<dynamic>? _contentSub;
  Timer? _debounce;

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
  }

  void _connect() {
    final out = StreamController<CodeUpdate>();
    _outgoing = out;
    _incomingSub = client.code
        .codeStream(widget.roomId, out.stream)
        .listen(
          _onRemote,
          onError: (Object e) => debugPrint('codeStream error: $e'),
        );
  }

  void _scheduleSend() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 120), _sendNow);
  }

  Future<void> _sendNow({bool force = false}) async {
    final c = _controller;
    final out = _outgoing;
    if (c == null || out == null || out.isClosed) return;
    final text = await c.document.getText();
    if (!force && text == _lastSyncedText) return;
    _lastSyncedText = text;
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
    if (u.senderId == _senderId) return;
    final c = _controller;
    if (c == null) return;

    if (u.language != _selected && _languages.containsKey(u.language)) {
      if (mounted) setState(() => _selected = u.language);
      await c.document.setLanguage(_languages[u.language]!);
    }

    if (u.text == _lastSyncedText) return;

    // If the editor holds text we haven't sent yet, the user is typing right
    // now. Keep their text; their next send will overwrite the remote one.
    final current = await c.document.getText();
    if (current != _lastSyncedText) return;

    _lastSyncedText =
        u.text; // set first so the resulting change event is ignored
    final sel = await c.getSelection();
    await c.document.setText(u.text);
    if (sel != null) await c.setSelection(sel);
  }

  Future<void> _changeLanguage(String name) async {
    setState(() => _selected = name);
    await _controller?.document.setLanguage(_languages[name]!);
    await _sendNow(force: true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _contentSub?.cancel();
    _incomingSub?.cancel();
    _outgoing?.close();
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              const Icon(Icons.code, size: 18),
              const SizedBox(width: 8),
              const Text('Code'),
              const Spacer(),
              SegmentedButton<String>(
                showSelectedIcon: false,
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
      ],
    );
  }
}
