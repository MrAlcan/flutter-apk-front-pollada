import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/match_info.dart';
import '../../domain/entities/prediction.dart';

/// Tarjeta de partido. Los partidos en vivo destacan con borde verde
/// brillante, chip LIVE pulsante y marcador animado.
class MatchCard extends StatelessWidget {
  const MatchCard({
    super.key,
    required this.match,
    this.prediction,
    this.onPredict,
  });

  final MatchInfo match;
  final Prediction? prediction;

  /// Solo para partidos programados: abre el formulario de pronóstico.
  final VoidCallback? onPredict;

  bool get _isLive => match.status == MatchStatus.live;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isLive ? const Color(0xFF0E2A1E) : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isLive
              ? AppColors.primary.withValues(alpha: 0.7)
              : AppColors.outline,
          width: _isLive ? 1.4 : 1,
        ),
        boxShadow: _isLive
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
            children: [_statusChip(), _kickoffLabel(textTheme)],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _teamLabel(match.teamHome, textTheme)),
              _scoreBoard(textTheme),
              Expanded(
                child: _teamLabel(match.teamAway, textTheme,
                    alignEnd: true),
              ),
            ],
          ),
          if (prediction != null || onPredict != null) ...[
            const SizedBox(height: 12),
            _predictionRow(context, textTheme),
          ],
        ],
      ),
    );
  }

  Widget _statusChip() {
    final (label, color) = switch (match.status) {
      MatchStatus.live => ('LIVE', AppColors.primary),
      MatchStatus.scheduled => ('PROGRAMADO', AppColors.textSecondary),
      MatchStatus.finished => ('FINAL', AppColors.secondary),
    };
    Widget chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isLive) ...[
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
    return chip;
  }

  Widget _kickoffLabel(TextTheme textTheme) {
    final local = match.matchTime.toLocal();
    final time = '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
    return Text('${local.day}/${local.month} · $time',
        style: textTheme.bodyMedium);
  }

  Widget _teamLabel(String name, TextTheme textTheme,
      {bool alignEnd = false}) {
    return Text(
      name,
      textAlign: alignEnd ? TextAlign.right : TextAlign.left,
      style: textTheme.titleMedium,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _scoreBoard(TextTheme textTheme) {
    final score = match.status == MatchStatus.scheduled
        ? 'vs'
        : '${match.goalsHome ?? 0} - ${match.goalsAway ?? 0}';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: Text(
          score,
          key: ValueKey(score),
          style: textTheme.headlineMedium?.copyWith(
            color: _isLive ? AppColors.primary : AppColors.textPrimary,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }

  Widget _predictionRow(BuildContext context, TextTheme textTheme) {
    final pred = prediction;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (pred != null)
          Row(
            children: [
              const Icon(Icons.sports_soccer,
                  size: 15, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                'Tu pronóstico: ${pred.predictedHome}-${pred.predictedAway}',
                style: textTheme.bodyMedium,
              ),
              if (pred.pointsEarned != null) ...[
                const SizedBox(width: 8),
                _pointsChip(pred.pointsEarned!),
              ],
            ],
          )
        else
          Text('Sin pronóstico', style: textTheme.bodyMedium),
        if (onPredict != null)
          TextButton.icon(
            onPressed: onPredict,
            icon: Icon(pred == null ? Icons.add_circle_outline : Icons.edit,
                size: 18),
            label: Text(pred == null ? 'Pronosticar' : 'Editar'),
          ),
      ],
    );
  }

  Widget _pointsChip(int points) {
    final color = switch (points) {
      3 => AppColors.secondary,
      1 => AppColors.primary,
      _ => AppColors.textSecondary,
    };
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
