import 'package:dio/dio.dart';

import '../../../pools/data/models/pools_models.dart';
import '../../../pools/domain/entities/app_settings.dart';
import '../../../pools/domain/entities/match_info.dart';

/// Endpoints REST de administración según API_DOCS.md (v2):
///   PUT  /admin/matches/{id}/result   -> marcador en vivo {home_score, away_score}
///   POST /admin/matches/{id}/finalize -> cierra el partido [{winner_team_id}]
///   PUT  /admin/settings              -> {predictions_visibility}
class AdminRemoteDataSource {
  const AdminRemoteDataSource(this._dio);

  final Dio _dio;

  Future<MatchInfo> updateScore(
    int matchId,
    int homeScore,
    int awayScore,
  ) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/admin/matches/$matchId/result',
      data: {'home_score': homeScore, 'away_score': awayScore},
    );
    return matchFromJson(response.data!);
  }

  Future<MatchInfo> finalizeMatch(int matchId, int? winnerTeamId) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/admin/matches/$matchId/finalize',
      data: {'winner_team_id': ?winnerTeamId},
    );
    return matchFromJson(response.data!);
  }

  Future<AppSettings> updateSettings(PredictionsVisibility visibility) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/admin/settings',
      data: {'predictions_visibility': visibility.apiValue},
    );
    return appSettingsFromJson(response.data!);
  }
}
