import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';

/// Fondo común de las pantallas de autenticación: degradado de estadio
/// nocturno con un resplandor de focos animado sutilmente.
class StadiumScaffold extends StatelessWidget {
  const StadiumScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(gradient: AppColors.stadiumGradient),
            child: SizedBox.expand(),
          ),
          // Resplandor de focos que respira lentamente.
          Positioned(
            top: -120,
            left: -60,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  duration: 4.seconds,
                  begin: const Offset(1, 1),
                  end: const Offset(1.25, 1.25),
                  curve: Curves.easeInOut,
                ),
          ),
          SafeArea(child: child),
        ],
      ),
    );
  }
}
