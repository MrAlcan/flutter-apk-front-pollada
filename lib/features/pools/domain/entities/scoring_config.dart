/// Puntajes vigentes, definidos por variables de entorno del backend
/// (expuestos en `GET /health`).
class ScoringConfig {
  const ScoringConfig({
    required this.pointsOutcome,
    required this.pointsExact,
  });

  /// Puntos por acertar el resultado general (local, visita o empate).
  final int pointsOutcome;

  /// Puntos por acertar el marcador exacto (no se suman ambos).
  final int pointsExact;

  static const fallback = ScoringConfig(pointsOutcome: 1, pointsExact: 3);
}
