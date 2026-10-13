import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pairspace_client/pairspace_client.dart';

import '../client.dart';

/// Countdown shown to both roles. Display only: it never ends the room.
class CountdownTimer extends StatefulWidget {
  const CountdownTimer({super.key, required this.roomId, this.onTimeUp});
  final int roomId;

  /// Called once, when the countdown reaches zero while being watched.
  final VoidCallback? onTimeUp;

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  Timer? _tick;
  DateTime? _endsAt; // in server time
  Duration _clockOffset = Duration.zero; // server time minus this device's time
  Duration? _remaining;
  bool _fired = false;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _load();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) => _update());
  }

  Future<void> _load() async {
    try {
      final RoomTiming t = await client.room.getRoomTiming(widget.roomId);
      if (!mounted) return;
      _clockOffset = t.serverNow.difference(DateTime.now());
      final started = t.startedAt;
      if (started == null) {
        // No candidate admitted yet: show full length, don't tick, check again.
        setState(() => _remaining = Duration(minutes: t.durationMinutes));
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted && !_started) _load();
        });
        return;
      }
      _started = true;
      _endsAt = started.add(Duration(minutes: t.durationMinutes));
      _update();
    } catch (e) {
      debugPrint('getRoomTiming failed: $e');
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted && !_started) _load();
      });
    }
  }

  void _update() {
    if (!mounted || _endsAt == null) return;
    final now = DateTime.now().add(_clockOffset);
    final rem = _endsAt!.difference(now);
    final prev = _remaining;
    setState(() => _remaining = rem);
    final wasRunning = prev != null && prev > Duration.zero;
    if (wasRunning && rem <= Duration.zero && !_fired) {
      _fired = true;
      widget.onTimeUp?.call();
    }
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  String _fmt(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return h > 0 ? '$h:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
  }

  @override
  Widget build(BuildContext context) {
    final r = _remaining;
    if (r == null) return const SizedBox.shrink();

    final over = r.isNegative || r == Duration.zero;
    final warn = !over && r < const Duration(minutes: 5);
    final color = over
        ? const Color(0xFFEF4444)
        : warn
        ? const Color(0xFFF59E0B)
        : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            over
                ? "Time's up"
                : (_started ? _fmt(r) : '${_fmt(r)} · not started'),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
