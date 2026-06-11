/// Entidad de dominio: una fila de la tabla de posiciones.
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.email,
    required this.totalPoints,
    required this.exactHits,
    required this.outcomeHits,
  });

  final int rank;
  final int userId;
  final String email;
  final int totalPoints;
  final int exactHits;
  final int outcomeHits;

  /// Nombre visible: la parte local del email.
  String get displayName => email.split('@').first;
}
