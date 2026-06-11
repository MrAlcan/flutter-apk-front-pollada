import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/live_remote_datasource.dart';
import '../../data/datasources/live_socket_datasource.dart';
import '../../data/repositories/live_repository_impl.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/entities/match_info.dart';
import '../../domain/repositories/live_repository.dart';

final _socketDataSourceProvider = Provider<LiveSocketDataSource>((ref) {
  final socket = LiveSocketDataSource(AppConfig.wsLiveUrl);
  ref.onDispose(socket.dispose);
  return socket;
});

final liveRepositoryProvider = Provider<LiveRepository>(
  (ref) => LiveRepositoryImpl(
    LiveRemoteDataSource(ref.watch(dioProvider)),
    ref.watch(_socketDataSourceProvider),
  ),
);

/// Estado del feed en vivo: partidos, tabla y salud de la conexión.
class LiveFeedState {
  const LiveFeedState({
    this.matches = const [],
    this.leaderboard = const [],
    this.connection = LiveConnectionStatus.connecting,
    this.loaded = false,
  });

  final List<MatchInfo> matches;
  final List<LeaderboardEntry> leaderboard;
  final LiveConnectionStatus connection;
  final bool loaded;

  List<MatchInfo> byStatus(MatchStatus status) =>
      [for (final m in matches) if (m.status == status) m];

  LiveFeedState copyWith({
    List<MatchInfo>? matches,
    List<LeaderboardEntry>? leaderboard,
    LiveConnectionStatus? connection,
    bool? loaded,
  }) =>
      LiveFeedState(
        matches: matches ?? this.matches,
        leaderboard: leaderboard ?? this.leaderboard,
        connection: connection ?? this.connection,
        loaded: loaded ?? this.loaded,
      );
}

class LiveFeedController extends Notifier<LiveFeedState> {
  @override
  LiveFeedState build() {
    final repository = ref.watch(liveRepositoryProvider);
    final subscription = repository.liveEvents().listen(_onEvent);
    ref.onDispose(subscription.cancel);
    _bootstrap(repository);
    return const LiveFeedState();
  }

  /// Carga inicial por REST: pinta datos al instante aunque el WebSocket
  /// tarde en conectar. El primer snapshot del socket la sobreescribe.
  Future<void> _bootstrap(LiveRepository repository) async {
    try {
      final matches = await repository.fetchMatches();
      final leaderboard = await repository.fetchLeaderboard();
      if (!state.loaded) {
        state = state.copyWith(
          matches: matches,
          leaderboard: leaderboard,
          loaded: true,
        );
      }
    } on LiveException {
      // Sin red: el WebSocket seguirá reintentando y traerá el snapshot.
    }
  }

  void _onEvent(LiveEvent event) {
    state = switch (event) {
      LiveStatusEvent(:final status) => state.copyWith(connection: status),
      LiveDataEvent(:final matches, :final leaderboard) => state.copyWith(
          matches: matches,
          leaderboard: leaderboard,
          loaded: true,
        ),
    };
  }
}

final liveFeedProvider = NotifierProvider<LiveFeedController, LiveFeedState>(
  LiveFeedController.new,
);
