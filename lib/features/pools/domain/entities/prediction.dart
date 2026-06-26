/// Entidad de dominio: pronóstico guardado para un partido.
class Prediction {
  const Prediction({
    required this.matchId,
    required this.predictedHome,
    required this.predictedAway,
    required this.pointsEarned,
  });

  final int matchId;
  final int predictedHome;
  final int predictedAway;

  /// Null mientras el partido no tenga resultado puntuado.
  final int? pointsEarned;
}

/// Pronóstico aún sin enviar, parte del formulario de participación.
class PredictionInput {
  const PredictionInput({
    required this.matchId,
    required this.predictedHome,
    required this.predictedAway,
  });

  final int matchId;
  final int predictedHome;
  final int predictedAway;
}
