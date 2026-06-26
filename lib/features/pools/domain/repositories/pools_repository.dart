import '../entities/app_settings.dart';
import '../entities/day_reveal.dart';
import '../entities/global_history.dart';
import '../entities/group_standings.dart';
import '../entities/history_entry.dart';
import '../entities/leaderboard_entry.dart';
import '../entities/match_day.dart';
import '../entities/match_info.dart';
import '../entities/prediction.dart';
import '../entities/scoring_config.dart';

/// Contrato del repositorio de jornadas, pronósticos y clasificación.
abstract interface class PoolsRepository {
  /// Puntajes configurados en el backend (`GET /health`).
  Future<ScoringConfig> fetchConfig();

  /// Jornadas: una entrada por cada día que tiene partidos.
  Future<List<MatchDaySummary>> fetchDays();

  /// Detalle de una jornada (`day` en formato `2026-06-11`).
  Future<DayDetail> fetchDay(String day);

  /// Participa en la jornada: exactamente una predicción por partido del
  /// día, en una sola petición. Inmutable una vez guardada (409 si repite).
  Future<void> submitPredictions(String day, List<PredictionInput> inputs);

  /// Pronósticos de todos los participantes. Siempre responde 200: el
  /// backend filtra qué predicciones son visibles según el modo de
  /// visibilidad y la participación del usuario.
  Future<List<ParticipantReveal>> fetchDayPredictions(String day);

  /// Modo de visibilidad vigente (`GET /settings`).
  Future<AppSettings> fetchSettings();

  /// Histórico global por jornada: participación, puntos y ganadores.
  Future<List<GlobalHistoryEntry>> fetchGlobalHistory();

  /// Ranking del día con ganadores (403 hasta que el día termine).
  Future<List<DayResultEntry>> fetchDayResults(String day);

  /// Tabla de posiciones global acumulada.
  Future<List<LeaderboardEntry>> fetchLeaderboard();

  /// Jornadas en las que participó el usuario autenticado.
  Future<List<HistoryEntry>> fetchMyHistory();

  /// Tablas de posiciones de los grupos.
  Future<List<GroupStandings>> fetchGroups();

  /// Fixture, con filtros opcionales por día, fase o grupo.
  Future<List<MatchInfo>> fetchMatches({String? day, String? stage});
}

/// Error de dominio con mensaje listo para mostrar.
class PoolsException implements Exception {
  const PoolsException(this.message);

  final String message;

  @override
  String toString() => message;
}
