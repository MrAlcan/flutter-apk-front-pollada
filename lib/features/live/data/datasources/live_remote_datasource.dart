import 'package:dio/dio.dart';

import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/entities/match_info.dart';
import '../../domain/entities/prediction.dart';
import '../models/live_models.dart';

/// Endpoints REST de partidos, tabla y predicciones.
class LiveRemoteDataSource {
  const LiveRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<MatchInfo>> fetchMatches() async {
    final response = await _dio.get<List<dynamic>>('/matches');
    return [
      for (final item in response.data!)
        matchFromJson(item as Map<String, dynamic>),
    ];
  }

  Future<List<LeaderboardEntry>> fetchLeaderboard() async {
    final response = await _dio.get<List<dynamic>>('/leaderboard');
    return [
      for (final item in response.data!)
        leaderboardEntryFromJson(item as Map<String, dynamic>),
    ];
  }

  Future<List<Prediction>> fetchMyPredictions() async {
    final response = await _dio.get<List<dynamic>>('/predictions/me');
    return [
      for (final item in response.data!)
        predictionFromJson(item as Map<String, dynamic>),
    ];
  }

  Future<Prediction> savePrediction(
    int matchId,
    int predictedHome,
    int predictedAway,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/predictions',
      data: {
        'match_id': matchId,
        'predicted_home': predictedHome,
        'predicted_away': predictedAway,
      },
    );
    return predictionFromJson(response.data!);
  }
}
