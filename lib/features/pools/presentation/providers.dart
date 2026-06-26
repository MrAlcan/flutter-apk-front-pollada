import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/dates.dart';
import '../data/datasources/live_socket_datasource.dart';
import '../data/datasources/pools_remote_datasource.dart';
import '../data/repositories/pools_repository_impl.dart';
import '../domain/entities/app_settings.dart';
import '../domain/entities/day_reveal.dart';
import '../domain/entities/global_history.dart';
import '../domain/entities/group_standings.dart';
import '../domain/entities/history_entry.dart';
import '../domain/entities/leaderboard_entry.dart';
import '../domain/entities/match_day.dart';
import '../domain/entities/match_info.dart';
import '../domain/entities/scoring_config.dart';
import '../domain/repositories/pools_repository.dart';

final poolsRepositoryProvider = Provider<PoolsRepository>(
  (ref) => PoolsRepositoryImpl(PoolsRemoteDataSource(ref.watch(dioProvider))),
);

/// Puntajes vigentes (`GET /health`). Con fallback local para no bloquear
/// la interfaz si el endpoint no responde.
final scoringConfigProvider = FutureProvider<ScoringConfig>((ref) async {
  try {
    return await ref.watch(poolsRepositoryProvider).fetchConfig();
  } on PoolsException {
    return ScoringConfig.fallback;
  }
});

/// Todas las jornadas, ordenadas de la más reciente a la más antigua.
final daysProvider = FutureProvider<List<MatchDaySummary>>((ref) async {
  final days = await ref.watch(poolsRepositoryProvider).fetchDays();
  return [...days]..sort((a, b) => b.day.compareTo(a.day));
});

/// Jornada de hoy (fecha local del dispositivo), o null si no hay partidos.
final todayProvider = FutureProvider<MatchDaySummary?>((ref) async {
  final days = await ref.watch(daysProvider.future);
  final today = apiDate(DateTime.now());
  for (final day in days) {
    if (day.day == today) return day;
  }
  return null;
});

/// Detalle de una jornada; la clave es la fecha `2026-06-11`.
final dayDetailProvider = FutureProvider.family<DayDetail, String>(
  (ref, day) => ref.watch(poolsRepositoryProvider).fetchDay(day),
);

/// Pronósticos de todos los participantes (solo jornadas terminadas).
final dayPredictionsProvider =
    FutureProvider.family<List<ParticipantReveal>, String>(
  (ref, day) => ref.watch(poolsRepositoryProvider).fetchDayPredictions(day),
);

/// Ranking del día con ganadores (solo jornadas terminadas).
final dayResultsProvider = FutureProvider.family<List<DayResultEntry>, String>(
  (ref, day) => ref.watch(poolsRepositoryProvider).fetchDayResults(day),
);

final leaderboardProvider = FutureProvider<List<LeaderboardEntry>>(
  (ref) => ref.watch(poolsRepositoryProvider).fetchLeaderboard(),
);

/// Mi historial de participación, indexado por día.
final myHistoryProvider = FutureProvider<Map<String, HistoryEntry>>(
  (ref) async {
    final entries = await ref.watch(poolsRepositoryProvider).fetchMyHistory();
    return {for (final e in entries) e.day: e};
  },
);

final groupsProvider = FutureProvider<List<GroupStandings>>(
  (ref) => ref.watch(poolsRepositoryProvider).fetchGroups(),
);

/// Fixture completo (104 partidos); también alimenta el panel admin.
final allMatchesProvider = FutureProvider<List<MatchInfo>>(
  (ref) => ref.watch(poolsRepositoryProvider).fetchMatches(),
);

/// Modo de visibilidad de predicciones ajenas (switch del admin).
final appSettingsProvider = FutureProvider<AppSettings>(
  (ref) => ref.watch(poolsRepositoryProvider).fetchSettings(),
);

/// Histórico global por jornada (participación, puntos, ganadores).
final globalHistoryProvider = FutureProvider<List<GlobalHistoryEntry>>(
  (ref) async {
    final entries =
        await ref.watch(poolsRepositoryProvider).fetchGlobalHistory();
    return [...entries]..sort((a, b) => b.day.compareTo(a.day));
  },
);

final _liveSocketProvider = Provider<LiveSocketDataSource>((ref) {
  final socket = LiveSocketDataSource(AppConfig.wsLiveUrl);
  ref.onDispose(socket.dispose);
  return socket;
});

/// Estado visible de la conexión en vivo (badge en la pestaña Hoy).
final liveStatusProvider = StreamProvider<LiveConnectionStatus>(
  (ref) => ref
      .watch(_liveSocketProvider)
      .events
      .where((e) => e is LiveStatusEvent)
      .map((e) => (e as LiveStatusEvent).status),
);

/// Sincronización en tiempo real: cada `live_update` del WebSocket (un
/// resultado cargado por el admin) refresca los datos REST en pantalla.
final liveSyncProvider = Provider<void>((ref) {
  final subscription =
      ref.watch(_liveSocketProvider).events.listen((event) {
    if (event is! LiveUpdateEvent || event.isSnapshot) return;
    ref.invalidate(daysProvider);
    ref.invalidate(dayDetailProvider);
    ref.invalidate(dayPredictionsProvider);
    ref.invalidate(dayResultsProvider);
    ref.invalidate(leaderboardProvider);
    ref.invalidate(myHistoryProvider);
    ref.invalidate(globalHistoryProvider);
    ref.invalidate(groupsProvider);
    ref.invalidate(allMatchesProvider);
  });
  ref.onDispose(subscription.cancel);
});
