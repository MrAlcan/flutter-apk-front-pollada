import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/match_info.dart';
import '../controllers/live_feed_controller.dart';
import '../controllers/predictions_controller.dart';
import '../widgets/connection_badge.dart';
import '../widgets/match_card.dart';
import '../widgets/prediction_sheet.dart';

/// Lobby: partidos en vivo, programados y terminados, con acceso al
/// formulario de pronóstico para los que aún no comienzan.
class LobbyScreen extends ConsumerWidget {
  const LobbyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(liveFeedProvider);
    final predictions = ref.watch(predictionsProvider).value ?? {};

    final sections = [
      (titulo: 'En juego', matches: feed.byStatus(MatchStatus.live)),
      (titulo: 'Próximos', matches: feed.byStatus(MatchStatus.scheduled)),
      (titulo: 'Terminados', matches: feed.byStatus(MatchStatus.finished)),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Partidos'),
        backgroundColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(child: ConnectionBadge(status: feed.connection)),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: !feed.loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                for (final section in sections)
                  if (section.matches.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
                      child: Text(
                        section.titulo,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    for (final (index, match) in section.matches.indexed)
                      MatchCard(
                        match: match,
                        prediction: predictions[match.id],
                        onPredict: match.status == MatchStatus.scheduled
                            ? () => showPredictionSheet(
                                  context,
                                  match: match,
                                  current: predictions[match.id],
                                )
                            : null,
                      )
                          .animate()
                          .fadeIn(
                            delay: (60 * index).ms,
                            duration: 350.ms,
                          )
                          .slideY(begin: 0.08, curve: Curves.easeOutCubic),
                  ],
                if (feed.matches.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 120),
                    child: Column(
                      children: [
                        const Icon(Icons.sports_soccer,
                            size: 56, color: AppColors.textSecondary),
                        const SizedBox(height: 12),
                        Text(
                          'No hay partidos todavía',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
