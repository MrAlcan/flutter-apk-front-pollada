import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/team.dart';

/// Bandera circular del equipo, con el código ISO como respaldo si la
/// imagen no carga (o un balón si la llave aún no está definida).
class TeamFlag extends StatelessWidget {
  const TeamFlag({super.key, required this.team, this.size = 30});

  final Team? team;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = team;
    if (t == null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.outline),
        ),
        child: Icon(
          Icons.help_outline,
          size: size * 0.55,
          color: AppColors.textSecondary,
        ),
      );
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.outline),
      ),
      child: ClipOval(
        child: Image.network(
          t.flagUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, _, _) => ColoredBox(
            color: AppColors.surfaceElevated,
            child: Center(
              child: Text(
                t.iso2.toUpperCase(),
                style: TextStyle(
                  fontSize: size * 0.34,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
