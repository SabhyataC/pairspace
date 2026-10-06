import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pairspace_client/pairspace_client.dart';

import '../client.dart';

/// Interviewer-only panel: counts and a timeline of the candidate's focus signals.
class IntegrityLogPanel extends StatefulWidget {
  const IntegrityLogPanel({super.key, required this.roomId});
  final int roomId;

  @override
  State<IntegrityLogPanel> createState() => _IntegrityLogPanelState();
}

class _IntegrityLogPanelState extends State<IntegrityLogPanel> {
  List<IntegrityEvent> _events = [];
  Timer? _timer;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _load());
  }

  Future<void> _load() async {
    try {
      final e = await client.integrity.getEvents(widget.roomId);
      if (mounted) setState(() => _events = e);
    } catch (e) {
      debugPrint('integrity getEvents failed: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _label(IntegrityEvent e) {
    switch (e.type) {
      case 'tab_hidden':
        return 'Switched to another tab';
      case 'tab_visible':
        return 'Returned to the tab';
      case 'window_blur':
        return 'Window lost focus';
      case 'window_focus':
        return 'Window regained focus';
      case 'paste':
        return 'Pasted into editor (${e.detail ?? '?'} chars)';
      default:
        return e.type;
    }
  }

  String _time(DateTime t) {
    final l = t.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(l.hour)}:${two(l.minute)}:${two(l.second)}';
  }

  @override
  Widget build(BuildContext context) {
    // A tab switch fires both tab_hidden and window_blur; count it once.
    final hidden = _events.where((e) => e.type == 'tab_hidden').toList();
    final extraBlurs = _events
        .where((e) => e.type == 'window_blur')
        .where(
          (b) => !hidden.any(
            (h) =>
                h.createdAt.difference(b.createdAt).abs() <
                const Duration(seconds: 1),
          ),
        )
        .length;
    final leftPage = hidden.length + extraBlurs;
    final pastes = _events.where((e) => e.type == 'paste').length;
    final latest = _events.reversed.take(20).toList();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () => setState(() => _open = !_open),
              child: Row(
                children: [
                  const Icon(Icons.visibility_outlined, size: 18),
                  const SizedBox(width: 8),
                  const Text('Focus signals (candidate)'),
                  const Spacer(),
                  Text('Left page: $leftPage   Pastes: $pastes'),
                  Icon(_open ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
            if (_open)
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 140),
                child: latest.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text('No signals recorded.'),
                      )
                    : ListView(
                        shrinkWrap: true,
                        children: [
                          for (final e in latest)
                            Text('${_time(e.createdAt)}  ${_label(e)}'),
                        ],
                      ),
              ),
          ],
        ),
      ),
    );
  }
}
