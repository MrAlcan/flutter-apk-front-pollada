/// Una jornada en la que participó el usuario autenticado.
class HistoryEntry {
  const HistoryEntry({
    required this.day,
    required this.submittedAt,
    required this.dayFinished,
    required this.points,
  });

  /// Fecha de la jornada en formato `YYYY-MM-DD`.
  final String day;

  final DateTime submittedAt;
  final bool dayFinished;
  final int points;
}
