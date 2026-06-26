/// Entidad de dominio: una fila de la tabla de posiciones histórica.
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.displayName,
    required this.totalPoints,
    required this.exactHits,
    required this.outcomeHits,
    required this.daysPlayed,
  });

  final int rank;
  final int userId;
  final String displayName;
  final int totalPoints;
  final int exactHits;
  final int outcomeHits;

  /// Jornadas en las que participó.
  final int daysPlayed;
}
