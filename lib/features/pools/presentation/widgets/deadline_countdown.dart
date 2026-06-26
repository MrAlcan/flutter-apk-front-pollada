import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Cuenta regresiva hasta el cierre de apuestas (1 minuto antes del primer
/// partido del día). Invoca [onExpired] una sola vez al llegar a cero.
class DeadlineCountdown extends StatefulWidget {
  const DeadlineCountdown({
    super.key,
    required this.deadline,
    this.onExpired,
  });

  final DateTime deadline;
  final VoidCallback? onExpired;

  @override
  State<DeadlineCountdown> createState() => _DeadlineCountdownState();
}

class _DeadlineCountdownState extends State<DeadlineCountdown> {
  Timer? _timer;
  late Duration _remaining = _untilDeadline();
  bool _expiredNotified = false;

  Duration _untilDeadline() {
    final diff = widget.deadline.difference(DateTime.now().toUtc());
    return diff.isNegative ? Duration.zero : diff;
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _remaining = _untilDeadline());
      if (_remaining == Duration.zero && !_expiredNotified) {
        _expiredNotified = true;
        widget.onExpired?.call();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _label {
    if (_remaining == Duration.zero) return 'Apuestas cerradas';
    final h = _remaining.inHours;
    final m = _remaining.inMinutes % 60;
    final s = _remaining.inSeconds % 60;
    final time = h > 0
        ? '${h}h ${m.toString().padLeft(2, '0')}m'
        : '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    return 'Cierra en $time';
  }

  @override
  Widget build(BuildContext context) {
    final urgent = _remaining < const Duration(minutes: 10);
    final color = _remaining == Duration.zero
        ? AppColors.textSecondary
        : urgent
            ? AppColors.error
            : AppColors.secondary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.timer_outlined, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          _label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 13,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
