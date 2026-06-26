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
import '../../domain/repositories/pools_repository.dart';
import '../datasources/pools_remote_datasource.dart';

class PoolsRepositoryImpl implements PoolsRepository {
  const PoolsRepositoryImpl(this._remote);

  final PoolsRemoteDataSource _remote;

  @override
  Future<ScoringConfig> fetchConfig() => _guard(() => _remote.fetchConfig());

  @override
  Future<List<MatchDaySummary>> fetchDays() =>
      _guard(() => _remote.fetchDays());

  @override
  Future<DayDetail> fetchDay(String day) => _guard(() => _remote.fetchDay(day));

  @override
  Future<void> submitPredictions(String day, List<PredictionInput> inputs) =>
      _guard(() => _remote.submitPredictions(day, inputs));

  @override
  Future<List<ParticipantReveal>> fetchDayPredictions(String day) =>
      _guard(() => _remote.fetchDayPredictions(day));

  @override
  Future<List<DayResultEntry>> fetchDayResults(String day) =>
      _guard(() => _remote.fetchDayResults(day));

  @override
  Future<AppSettings> fetchSettings() =>
      _guard(() => _remote.fetchSettings());

  @override
  Future<List<GlobalHistoryEntry>> fetchGlobalHistory() =>
      _guard(() => _remote.fetchGlobalHistory());

  @override
  Future<List<LeaderboardEntry>> fetchLeaderboard() =>
      _guard(() => _remote.fetchLeaderboard());

  @override
  Future<List<HistoryEntry>> fetchMyHistory() =>
      _guard(() => _remote.fetchMyHistory());

  @override
  Future<List<GroupStandings>> fetchGroups() =>
      _guard(() => _remote.fetchGroups());

  @override
  Future<List<MatchInfo>> fetchMatches({String? day, String? stage}) =>
      _guard(() => _remote.fetchMatches(day: day, stage: stage));

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on DioException catch (e) {
      final detail = switch (e.response?.data) {
        {'detail': final String message} => message,
        _ => null,
      };
      throw PoolsException(detail ?? 'No se pudo conectar con el servidor');
    }
  }
}
