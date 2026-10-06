import 'dart:async';
import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import '../client.dart';
import 'code_editor_panel.dart' show activeMonacoController;

/// Invisible widget. While mounted, reports the candidate's tab-visibility,
/// window focus/blur and paste-into-editor events to the server.
class IntegrityMonitorHost extends StatefulWidget {
  const IntegrityMonitorHost({super.key, required this.roomId});
  final int roomId;

  @override
  State<IntegrityMonitorHost> createState() => _IntegrityMonitorHostState();
}

class _IntegrityMonitorHostState extends State<IntegrityMonitorHost> {
  late final JSFunction _onVisibility;
  late final JSFunction _onBlur;
  late final JSFunction _onFocus;
  Timer? _blurTimer;
  Timer? _pasteTimer;
  bool _blurred = false;

  // Runs inside Monaco's iframe. Hooks onDidPaste once, then returns and
  // clears the pasted lengths (only lengths, never the pasted text).
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

    _onVisibility = ((web.Event _) {
      _report(web.document.hidden ? 'tab_hidden' : 'tab_visible');
    }).toJS;

    // Clicking into the Monaco iframe also blurs the parent window, so wait
    // briefly and only report if the whole document really lost focus.
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

    web.document.addEventListener('visibilitychange', _onVisibility);
    web.window.addEventListener('blur', _onBlur);
    web.window.addEventListener('focus', _onFocus);
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
    web.document.removeEventListener('visibilitychange', _onVisibility);
    web.window.removeEventListener('blur', _onBlur);
    web.window.removeEventListener('focus', _onFocus);
    _blurTimer?.cancel();
    _pasteTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
