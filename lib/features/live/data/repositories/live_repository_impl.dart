import 'package:dio/dio.dart';

import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/entities/match_info.dart';
import '../../domain/entities/prediction.dart';
import '../../domain/repositories/live_repository.dart';
import '../datasources/live_remote_datasource.dart';
import '../datasources/live_socket_datasource.dart';

class LiveRepositoryImpl implements LiveRepository {
  const LiveRepositoryImpl(this._remote, this._socket);

  final LiveRemoteDataSource _remote;
  final LiveSocketDataSource _socket;

  @override
  Future<List<MatchInfo>> fetchMatches() =>
      _guard(() => _remote.fetchMatches());

  @override
  Future<List<LeaderboardEntry>> fetchLeaderboard() =>
      _guard(() => _remote.fetchLeaderboard());

  @override
  Future<List<Prediction>> fetchMyPredictions() =>
      _guard(() => _remote.fetchMyPredictions());

  @override
  Future<Prediction> savePrediction({
    required int matchId,
    required int predictedHome,
    required int predictedAway,
  }) =>
      _guard(
        () => _remote.savePrediction(matchId, predictedHome, predictedAway),
      );

  @override
  Stream<LiveEvent> liveEvents() => _socket.events;

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on DioException catch (e) {
      final detail = switch (e.response?.data) {
        {'detail': final String message} => message,
        _ => null,
      };
      throw LiveException(detail ?? 'No se pudo conectar con el servidor');
    }
  }
}
