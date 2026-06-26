import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/match_day.dart';

/// Chip de estado de jornada: abierta, cerrada o terminada.
class DayStatusChip extends StatelessWidget {
  const DayStatusChip({super.key, required this.status});

  final DayStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      DayStatus.open => ('ABIERTA', AppColors.primary),
      DayStatus.locked => ('EN JUEGO', AppColors.secondary),
      DayStatus.finished => ('TERMINADA', AppColors.textSecondary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
