import '../entities/leaderboard_entry.dart';
import '../entities/match_info.dart';
import '../entities/prediction.dart';

/// Estado de la conexión en tiempo real.
enum LiveConnectionStatus { connecting, connected, reconnecting }

/// Eventos que emite el canal en vivo.
sealed class LiveEvent {
  const LiveEvent();
}

class LiveStatusEvent extends LiveEvent {
  const LiveStatusEvent(this.status);

  final LiveConnectionStatus status;
}

class LiveDataEvent extends LiveEvent {
  const LiveDataEvent({required this.matches, required this.leaderboard});

  final List<MatchInfo> matches;
  final List<LeaderboardEntry> leaderboard;
}

/// Contrato del repositorio de partidos, tabla y predicciones.
abstract interface class LiveRepository {
  Future<List<MatchInfo>> fetchMatches();

  Future<List<LeaderboardEntry>> fetchLeaderboard();

  Future<List<Prediction>> fetchMyPredictions();

  Future<Prediction> savePrediction({
    required int matchId,
    required int predictedHome,
    required int predictedAway,
  });

  /// Canal en tiempo real (WebSocket con reconexión automática).
  Stream<LiveEvent> liveEvents();
}

/// Error de dominio con mensaje listo para mostrar.
class LiveException implements Exception {
  const LiveException(this.message);

  final String message;

  @override
  String toString() => message;
}
