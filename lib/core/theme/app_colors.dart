import 'package:flutter/material.dart';

/// Paleta "estadio nocturno": azules profundos de cielo de noche,
/// verde césped bajo focos y dorado de trofeo como acento.
abstract final class AppColors {
  // Fondos (cielo nocturno sobre el estadio)
  static const Color background = Color(0xFF080F17);
  static const Color surface = Color(0xFF101B26);
  static const Color surfaceElevated = Color(0xFF18283A);

  // Verde césped iluminado por los focos
  static const Color primary = Color(0xFF2EE59D);
  static const Color onPrimary = Color(0xFF04140C);

  // Dorado trofeo / luces del marcador
  static const Color secondary = Color(0xFFFFC533);
  static const Color onSecondary = Color(0xFF1A1200);

  // Texto
  static const Color textPrimary = Color(0xFFEAF2F8);
  static const Color textSecondary = Color(0xFF8FA3B5);

  // Estados
  static const Color error = Color(0xFFFF5A6E);
  static const Color success = Color(0xFF2EE59D);

  static const Color outline = Color(0xFF2A3B4D);

  /// Degradado de fondo para pantallas hero (login, splash).
  static const LinearGradient stadiumGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0E2233), Color(0xFF080F17), Color(0xFF05140E)],
  );
}
