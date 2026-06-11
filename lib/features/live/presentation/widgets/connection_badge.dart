import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/repositories/live_repository.dart';

/// Chip que informa la salud del canal en tiempo real.
class ConnectionBadge extends StatelessWidget {
  const ConnectionBadge({super.key, required this.status});

  final LiveConnectionStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      LiveConnectionStatus.connected => ('EN VIVO', AppColors.primary),
      LiveConnectionStatus.connecting => ('CONECTANDO', AppColors.textSecondary),
      LiveConnectionStatus.reconnecting => ('RECONECTANDO', AppColors.secondary),
    };

    Widget dot = Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
    if (status != LiveConnectionStatus.connected) {
      dot = dot
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .fade(duration: 600.ms, begin: 0.3, end: 1);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          dot,
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
