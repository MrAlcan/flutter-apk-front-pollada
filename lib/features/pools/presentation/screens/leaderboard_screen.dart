import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../providers.dart';
import '../widgets/leaderboard_list.dart';

/// Tabla de clasificación histórica acumulada de todas las jornadas.
class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);
    final currentUserId = ref.watch(authControllerProvider).value?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clasificación'),
        backgroundColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(leaderboardProvider.future),
        child: leaderboardAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 120),
                child: Center(
                  child: Column(
                    children: [
                      Text('$error',
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () => ref.invalidate(leaderboardProvider),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          data: (entries) => LeaderboardList(
            entries: entries,
            highlightUserId: currentUserId,
          ),
        ),
      ),
    );
  }
}
