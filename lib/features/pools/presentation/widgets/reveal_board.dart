import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/day_reveal.dart';
import '../../domain/entities/match_info.dart';
import 'match_card.dart';

/// Podio de la jornada: ganadores destacados con trofeo animado y el
/// ranking del día completo.
class DayResultsBoard extends StatelessWidget {
  const DayResultsBoard({super.key, required this.results});

  final List<DayResultEntry> results;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    if (results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text('Nadie participó este día', style: textTheme.bodyMedium),
        ),
      );
    }

    return Column(
      children: [
        for (final (index, entry) in results.indexed)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: entry.isWinner
                  ? AppColors.secondary.withValues(alpha: 0.08)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: entry.isWinner
                    ? AppColors.secondary.withValues(alpha: 0.55)
                    : AppColors.outline,
              ),
            ),
            child: Row(
              children: [
                if (entry.isWinner)
                  const Icon(Icons.emoji_events, color: AppColors.secondary)
                      .animate()
                      .scale(
                        delay: (150 + 80 * index).ms,
                        duration: 500.ms,
                        curve: Curves.elasticOut,
                        begin: const Offset(0, 0),
                      )
                else
                  SizedBox(
                    width: 24,
                    child: Text(
                      '${entry.rank}',
                      textAlign: TextAlign.center,
                      style: textTheme.titleMedium
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.displayName, style: textTheme.titleMedium),
                      Text(
                        '${entry.exactHits} exactos · '
                        '${entry.outcomeHits} aciertos',
                        style:
                            textTheme.bodyMedium?.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${entry.dayPoints}',
                  style: textTheme.titleLarge?.copyWith(
                    color: entry.isWinner
                        ? AppColors.secondary
                        : AppColors.primary,
                  ),
                ),
                Text(' pts', style: textTheme.bodyMedium),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: (60 * index).ms, duration: 300.ms)
              .slideX(begin: 0.06, curve: Curves.easeOutCubic),
      ],
    );
  }
}

/// Pronósticos de todos los participantes, expandibles por jugador.
class RevealBoard extends StatelessWidget {
  const RevealBoard({
    super.key,
    required this.participants,
    required this.matches,
    this.winnerIds = const {},
  });

  final List<ParticipantReveal> participants;
  final List<MatchInfo> matches;
  final Set<int> winnerIds;

  @override
  Widget build(BuildContext context) {
    if (participants.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final participant in participants)
          _ParticipantTile(
            participant: participant,
            matches: matches,
            isWinner: winnerIds.contains(participant.userId),
          ),
      ],
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  const _ParticipantTile({
    required this.participant,
    required this.matches,
    required this.isWinner,
  });

  final ParticipantReveal participant;
  final List<MatchInfo> matches;
  final bool isWinner;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isWinner
              ? AppColors.secondary.withValues(alpha: 0.55)
              : AppColors.outline,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          leading: isWinner
              ? const Icon(Icons.emoji_events, color: AppColors.secondary)
              : const Icon(Icons.person_outline,
                  color: AppColors.textSecondary),
          title: Text(participant.displayName, style: textTheme.titleMedium),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${participant.dayPoints}',
                style: textTheme.titleLarge?.copyWith(
                  color: isWinner ? AppColors.secondary : AppColors.primary,
                ),
              ),
              Text(' pts', style: textTheme.bodyMedium),
            ],
          ),
          children: [
            for (final match in matches) _predictionLine(match, textTheme),
          ],
        ),
      ),
    );
  }

  Widget _predictionLine(MatchInfo match, TextTheme textTheme) {
    final pred = participant.predictions[match.id];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${match.homeLabel} vs ${match.awayLabel}',
              style: textTheme.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            pred == null ? '—' : '${pred.predictedHome}-${pred.predictedAway}',
            style: textTheme.titleMedium?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 8),
          if (pred?.pointsEarned != null)
            PointsChip(points: pred!.pointsEarned!),
        ],
      ),
    );
  }
}
