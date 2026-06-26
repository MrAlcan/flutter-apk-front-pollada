/// Ganador (o empatado en el máximo) de una jornada terminada.
class DayWinner {
  const DayWinner({
    required this.userId,
    required this.displayName,
    required this.dayPoints,
  });

  final int userId;
  final String displayName;
  final int dayPoints;
}

/// Fila del histórico global (`GET /history`): una por cada día con
/// partidos, haya participado o no el usuario.
class GlobalHistoryEntry {
  const GlobalHistoryEntry({
    required this.day,
    required this.matchCount,
    required this.dayFinished,
    required this.participated,
    required this.myPoints,
    required this.participantsCount,
    required this.winners,
  });

  /// Fecha de la jornada en formato `YYYY-MM-DD`.
  final String day;

  final int matchCount;
  final bool dayFinished;
  final bool participated;

  /// Null si el usuario no participó ese día.
  final int? myPoints;

  final int participantsCount;

  /// Null mientras el día no termine.
  final List<DayWinner>? winners;
}
