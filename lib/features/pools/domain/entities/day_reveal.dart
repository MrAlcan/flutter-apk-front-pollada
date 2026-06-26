import 'prediction.dart';

/// Pronósticos de un participante, visibles cuando la jornada terminó.
class ParticipantReveal {
  const ParticipantReveal({
    required this.userId,
    required this.displayName,
    required this.dayPoints,
    required this.predictions,
  });

  final int userId;
  final String displayName;
  final int dayPoints;

  /// Pronósticos indexados por id de partido.
  final Map<int, Prediction> predictions;
}

/// Fila del ranking de una jornada terminada.
class DayResultEntry {
  const DayResultEntry({
    required this.rank,
    required this.userId,
    required this.displayName,
    required this.dayPoints,
    required this.exactHits,
    required this.outcomeHits,
    required this.isWinner,
  });

  final int rank;
  final int userId;
  final String displayName;
  final int dayPoints;
  final int exactHits;
  final int outcomeHits;

  /// Los empatados en el máximo puntaje del día comparten la victoria.
  final bool isWinner;
}
