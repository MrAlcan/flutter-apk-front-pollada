import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/dates.dart';
import '../../domain/entities/match_info.dart';
import '../../domain/entities/prediction.dart';
import '../../domain/entities/team.dart';
import 'team_flag.dart';

/// Tarjeta de partido con banderas, sede y pronóstico propio sellado.
class MatchCard extends StatelessWidget {
  const MatchCard({
    super.key,
    required this.match,
    this.prediction,
  });

  final MatchInfo match;
  final Prediction? prediction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final finished = match.finished;
    final live = match.isLive;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: live ? const Color(0xFF0E2A1E) : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: live
              ? AppColors.primary.withValues(alpha: 0.7)
              : finished
                  ? AppColors.secondary.withValues(alpha: 0.35)
                  : AppColors.outline,
          width: live ? 1.4 : 1,
        ),
        boxShadow: live
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ]
            : const [],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statusChip(),
              Flexible(
                child: Text(
                  match.stageLabel,
                  style: textTheme.bodyMedium?.copyWith(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(shortTime(match.kickoff), style: textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _teamColumn(
                  textTheme,
                  team: match.homeTeam,
                  label: match.homeLabel,
                ),
              ),
              _scoreBoard(textTheme),
              Expanded(
                child: _teamColumn(
                  textTheme,
                  team: match.awayTeam,
                  label: match.awayLabel,
                ),
              ),
            ],
          ),
          if (match.stadium != null) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.stadium_outlined,
                    size: 13, color: AppColors.textSecondary),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    '${match.stadium!.name} · ${match.stadium!.city}',
                    style: textTheme.bodyMedium?.copyWith(fontSize: 11.5),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          if (prediction != null) ...[
            const SizedBox(height: 12),
            _predictionRow(textTheme),
          ],
        ],
      ),
    );
  }

  Widget _statusChip() {
    final (label, color) = switch (match.status) {
      MatchStatus.live => ('EN JUEGO', AppColors.primary),
      MatchStatus.finished => ('FINAL', AppColors.secondary),
      MatchStatus.scheduled => ('PROGRAMADO', AppColors.textSecondary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (match.isLive) ...[
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .fade(duration: 700.ms, begin: 0.25, end: 1)
                .scale(
                  duration: 700.ms,
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.2, 1.2),
                ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _teamColumn(
    TextTheme textTheme, {
    required Team? team,
    required String label,
  }) {
    return Column(
      children: [
        TeamFlag(team: team, size: 34),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: textTheme.titleMedium?.copyWith(
            fontSize: team == null ? 12.5 : null,
            color: team == null ? AppColors.textSecondary : null,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _scoreBoard(TextTheme textTheme) {
    // En vivo el marcador parcial es visible aunque `finished` sea false.
    final score = match.hasScore || match.finished
        ? '${match.homeScore ?? 0} - ${match.awayScore ?? 0}'
        : 'vs';
    final penalties = match.isDraw && match.winnerTeamId != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale:
                  CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: Text(
              score,
              key: ValueKey(score),
              style: textTheme.headlineMedium?.copyWith(
                color: match.isLive
                    ? AppColors.primary
                    : match.finished
                        ? AppColors.secondary
                        : AppColors.textPrimary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          if (penalties)
            Text(
              _penaltyWinnerLabel(),
              style: textTheme.bodyMedium?.copyWith(fontSize: 10.5),
            ),
        ],
      ),
    );
  }

  String _penaltyWinnerLabel() {
    final winner = match.winnerTeamId == match.homeTeam?.id
        ? match.homeTeam?.fifaCode
        : match.awayTeam?.fifaCode;
    return 'Pen. $winner';
  }

  Widget _predictionRow(TextTheme textTheme) {
    final pred = prediction!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline,
              size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            'Tu pronóstico: ${pred.predictedHome}-${pred.predictedAway}',
            style: textTheme.bodyMedium,
          ),
          if (pred.pointsEarned != null) ...[
            const SizedBox(width: 8),
            PointsChip(points: pred.pointsEarned!),
          ],
        ],
      ),
    );
  }
}

/// Chip de puntos ganados por un pronóstico ya puntuado.
class PointsChip extends StatelessWidget {
  const PointsChip({super.key, required this.points});

  final int points;

  @override
  Widget build(BuildContext context) {
    final color = points > 0
        ? (points >= 3 ? AppColors.secondary : AppColors.primary)
        : AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '+$points pts',
        style:
            TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}
