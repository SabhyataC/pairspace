import 'dart:async';
import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import '../client.dart';
import 'code_editor_panel.dart' show activeMonacoController;

class IntegrityMonitorHost extends StatefulWidget {
  const IntegrityMonitorHost({
    super.key,
    required this.roomId,
    required this.onDecline,
  });
  final int roomId;
  final VoidCallback onDecline;

  @override
  State<IntegrityMonitorHost> createState() => _IntegrityMonitorHostState();
}

class _IntegrityMonitorHostState extends State<IntegrityMonitorHost> {
  static final Set<int> _acknowledgedRooms = {};

  late final JSFunction _onVisibility;
  late final JSFunction _onBlur;
  late final JSFunction _onFocus;
  late final JSFunction _onPaste;
  Timer? _blurTimer;
  Timer? _pasteTimer;
  bool _blurred = false;
  bool _listening = false;
  late bool _acknowledged;

  static const _pasteScript = '''
(() => {
  const ed = monaco.editor.getEditors()[0];
  if (!ed) return [];
  if (!window.__pairspacePasteHooked) {
    window.__pairspacePasteHooked = true;
    window.__pairspacePastes = [];
    ed.onDidPaste((e) => {
      const m = ed.getModel();
      window.__pairspacePastes.push(m ? m.getValueInRange(e.range).length : 0);
    });
  }
  const out = window.__pairspacePastes;
  window.__pairspacePastes = [];
  return out;
})()
''';

  @override
  void initState() {
    super.initState();
    _acknowledged = _acknowledgedRooms.contains(widget.roomId);
    if (_acknowledged) {
      _startMonitoring();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _askConsent());
    }
  }

  Future<void> _askConsent() async {
    if (!mounted) return;
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.visibility_outlined, size: 36),
        title: const Text('This session is monitored'),
        content: const Text(
          'To keep the interview fair, PairSpace records when you switch to '
          'another tab or window, and when you paste text into the editor or '
          'a text box.\n\n'
          'Only the time of each event and the number of pasted characters '
          'are recorded, never what you paste. The interviewer can see these '
          'signals during the session and in the recap afterwards.\n\n'
          'Nothing else on your computer is monitored.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Leave room'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('I understand'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (accepted == true) {
      _acknowledgedRooms.add(widget.roomId);
      setState(() => _acknowledged = true);
      _startMonitoring();
    } else {
      widget.onDecline();
    }
  }

  void _startMonitoring() {
    if (_listening) return;
    _listening = true;

    _onVisibility = ((web.Event _) {
      _report(web.document.hidden ? 'tab_hidden' : 'tab_visible');
    }).toJS;

    _onBlur = ((web.Event _) {
      _blurTimer?.cancel();
      _blurTimer = Timer(const Duration(milliseconds: 200), () {
        if (!web.document.hasFocus() && !_blurred) {
          _blurred = true;
          _report('window_blur');
        }
      });
    }).toJS;

    _onFocus = ((web.Event _) {
      _blurTimer?.cancel();
      if (_blurred) {
        _blurred = false;
        _report('window_focus');
      }
    }).toJS;

    _onPaste = ((web.Event e) {
      var length = 0;
      try {
        if (e.isA<web.ClipboardEvent>()) {
          final data = (e as web.ClipboardEvent).clipboardData;
          length = data?.getData('text').length ?? 0;
        }
      } catch (_) {}
      _report('paste', detail: '$length');
    }).toJS;

    web.document.addEventListener('visibilitychange', _onVisibility);
    web.window.addEventListener('blur', _onBlur);
    web.window.addEventListener('focus', _onFocus);
    web.document.addEventListener('paste', _onPaste, true.toJS);
    _pasteTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _pollPastes(),
    );
  }

  Future<void> _pollPastes() async {
    final c = activeMonacoController;
    if (c == null) return;
    try {
      final result = await c.evaluateJavaScript<List<dynamic>>(_pasteScript);
      for (final len in result ?? const <dynamic>[]) {
        _report('paste', detail: '$len');
      }
    } catch (e) {
      debugPrint('paste poll failed: $e');
    }
  }

  void _report(String type, {String? detail}) {
    client.integrity.report(widget.roomId, type, detail).catchError((Object e) {
      debugPrint('integrity report failed: $e');
    });
  }

  @override
  void dispose() {
    if (_listening) {
      web.document.removeEventListener('visibilitychange', _onVisibility);
      web.window.removeEventListener('blur', _onBlur);
      web.window.removeEventListener('focus', _onFocus);
      web.document.removeEventListener('paste', _onPaste, true.toJS);
    }
    _blurTimer?.cancel();
    _pasteTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_acknowledged) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E7FF)),
      ),
      child: const Row(
        children: [
          Icon(Icons.visibility_outlined, size: 16, color: Color(0xFF4338CA)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Tab switches and pastes are visible to the interviewer.',
              style: TextStyle(fontSize: 12, color: Color(0xFF4338CA)),
            ),
          ),
        ],
      ),
    );
  }
}
