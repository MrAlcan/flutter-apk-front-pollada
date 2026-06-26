import 'match_info.dart';
import 'prediction.dart';

/// Estado de una jornada de apuestas.
enum DayStatus {
  /// Acepta participaciones (hasta 1 minuto antes del primer partido).
  open,

  /// Cerrada: venció el plazo o los equipos aún no están definidos.
  locked,

  /// Terminó el último partido del día: todo es visible.
  finished;

  static DayStatus fromApi(String value) => switch (value) {
        'open' => DayStatus.open,
        'finished' => DayStatus.finished,
        _ => DayStatus.locked,
      };
}

/// Resumen de una jornada para listados (historial / hoy).
class MatchDaySummary {
  const MatchDaySummary({
    required this.day,
    required this.matchCount,
    required this.firstKickoff,
    required this.bettingClosesAt,
    required this.status,
    required this.teamsDefined,
    required this.allFinished,
    required this.participated,
    required this.participantsCount,
  });

  /// Fecha de la jornada en formato `YYYY-MM-DD`.
  final String day;

  final int matchCount;
  final DateTime firstKickoff;

  /// Cierre de apuestas, hora local del fixture.
  final DateTime bettingClosesAt;

  final DayStatus status;
  final bool teamsDefined;
  final bool allFinished;

  /// True si el usuario actual ya envió sus pronósticos para este día.
  final bool participated;

  final int participantsCount;

  DateTime get date => DateTime.parse(day);
}

/// Detalle completo de una jornada: resumen, partidos y pronósticos propios.
class DayDetail {
  const DayDetail({
    required this.summary,
    required this.matches,
    required this.myPredictions,
  });

  final MatchDaySummary summary;
  final List<MatchInfo> matches;

  /// Pronósticos del usuario indexados por id de partido; null si no participó.
  final Map<int, Prediction>? myPredictions;

  bool get participated => myPredictions != null;

  DayStatus get status => summary.status;

  /// Puntos del día ya acumulados por el usuario.
  int get myPoints => (myPredictions?.values ?? const <Prediction>[])
      .fold(0, (total, p) => total + (p.pointsEarned ?? 0));
}
