/// Entidad de dominio: pronóstico del usuario para un partido.
class Prediction {
  const Prediction({
    required this.id,
    required this.matchId,
    required this.predictedHome,
    required this.predictedAway,
    required this.pointsEarned,
  });

  final int id;
  final int matchId;
  final int predictedHome;
  final int predictedAway;

  /// Null mientras el partido no se haya puntuado.
  final int? pointsEarned;
}
