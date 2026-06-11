import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/live_feed_controller.dart';
import '../widgets/connection_badge.dart';
import '../widgets/leaderboard_list.dart';

/// Tabla de clasificación en tiempo real: las filas se reordenan con
/// animación cuando el simulador de goles recalcula los puntos.
class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(liveFeedProvider);
    final currentEmail = ref.watch(authControllerProvider).value?.email;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clasificación'),
        backgroundColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: ConnectionBadge(status: feed.connection)),
          ),
        ],
      ),
      body: !feed.loaded
          ? const Center(child: CircularProgressIndicator())
          : LeaderboardList(
              entries: feed.leaderboard,
              highlightEmail: currentEmail,
            ),
    );
  }
}
