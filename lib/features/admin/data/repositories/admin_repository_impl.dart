import 'package:dio/dio.dart';

import '../../../pools/domain/entities/app_settings.dart';
import '../../../pools/domain/entities/match_info.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_datasource.dart';

class AdminRepositoryImpl implements AdminRepository {
  const AdminRepositoryImpl(this._remote);

  final AdminRemoteDataSource _remote;

  @override
  Future<MatchInfo> updateScore({
    required int matchId,
    required int homeScore,
    required int awayScore,
  }) =>
      _guard(() => _remote.updateScore(matchId, homeScore, awayScore));

  @override
  Future<MatchInfo> finalizeMatch({required int matchId, int? winnerTeamId}) =>
      _guard(() => _remote.finalizeMatch(matchId, winnerTeamId));

  @override
  Future<AppSettings> updateSettings(PredictionsVisibility visibility) =>
      _guard(() => _remote.updateSettings(visibility));

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on DioException catch (e) {
      final detail = switch (e.response?.data) {
        {'detail': final String message} => message,
        _ => null,
      };
      throw AdminException(detail ?? 'No se pudo conectar con el servidor');
    }
  }
}
