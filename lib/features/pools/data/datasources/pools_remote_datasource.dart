import 'package:dio/dio.dart';

import '../../domain/entities/app_settings.dart';
import '../../domain/entities/day_reveal.dart';
import '../../domain/entities/global_history.dart';
import '../../domain/entities/group_standings.dart';
import '../../domain/entities/history_entry.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/entities/match_day.dart';
import '../../domain/entities/match_info.dart';
import '../../domain/entities/prediction.dart';
import '../../domain/entities/scoring_config.dart';
import '../models/pools_models.dart';

/// Endpoints REST según API_DOCS.md.
class PoolsRemoteDataSource {
  const PoolsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<ScoringConfig> fetchConfig() async {
    final response = await _dio.get<Map<String, dynamic>>('/health');
    return scoringConfigFromHealthJson(response.data!);
  }

  Future<List<MatchDaySummary>> fetchDays() async {
    final response = await _dio.get<List<dynamic>>('/days');
    return [
      for (final item in response.data!)
        daySummaryFromJson(item as Map<String, dynamic>),
    ];
  }

  Future<DayDetail> fetchDay(String day) async {
    final response = await _dio.get<Map<String, dynamic>>('/days/$day');
    return dayDetailFromJson(response.data!);
  }

  Future<void> submitPredictions(
    String day,
    List<PredictionInput> inputs,
  ) async {
    await _dio.post<dynamic>(
      '/days/$day/predictions',
      data: {
        'predictions': [
          for (final input in inputs) predictionInputToJson(input),
        ],
      },
    );
  }

  Future<List<ParticipantReveal>> fetchDayPredictions(String day) async {
    final response = await _dio.get<List<dynamic>>('/days/$day/predictions');
    return [
      for (final item in response.data!)
        participantRevealFromJson(item as Map<String, dynamic>),
    ];
  }

  Future<List<DayResultEntry>> fetchDayResults(String day) async {
    final response = await _dio.get<List<dynamic>>('/days/$day/results');
    return [
      for (final item in response.data!)
        dayResultFromJson(item as Map<String, dynamic>),
    ];
  }

  Future<AppSettings> fetchSettings() async {
    final response = await _dio.get<Map<String, dynamic>>('/settings');
    return appSettingsFromJson(response.data!);
  }

  Future<List<GlobalHistoryEntry>> fetchGlobalHistory() async {
    final response = await _dio.get<List<dynamic>>('/history');
    return [
      for (final item in response.data!)
        globalHistoryEntryFromJson(item as Map<String, dynamic>),
    ];
  }

  Future<List<LeaderboardEntry>> fetchLeaderboard() async {
    final response = await _dio.get<List<dynamic>>('/leaderboard');
    return [
      for (final item in response.data!)
        leaderboardEntryFromJson(item as Map<String, dynamic>),
    ];
  }

  Future<List<HistoryEntry>> fetchMyHistory() async {
    final response = await _dio.get<List<dynamic>>('/me/history');
    return [
      for (final item in response.data!)
        historyEntryFromJson(item as Map<String, dynamic>),
    ];
  }

  Future<List<GroupStandings>> fetchGroups() async {
    final response = await _dio.get<List<dynamic>>('/groups');
    return [
      for (final item in response.data!)
        groupStandingsFromJson(item as Map<String, dynamic>),
    ];
  }

  Future<List<MatchInfo>> fetchMatches({String? day, String? stage}) async {
    final response = await _dio.get<List<dynamic>>(
      '/matches',
      queryParameters: {
        'day': ?day,
        'stage': ?stage,
      },
    );
    return [
      for (final item in response.data!)
        matchFromJson(item as Map<String, dynamic>),
    ];
  }
}
