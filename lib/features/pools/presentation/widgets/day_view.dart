import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/dates.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/entities/day_reveal.dart';
import '../../domain/entities/match_day.dart';
import '../providers.dart';
import 'day_status_chip.dart';
import 'deadline_countdown.dart';
import 'match_card.dart';
import 'reveal_board.dart';

/// Contenido de una jornada: cabecera con estado, llamado a participar
/// (si está abierta), partidos con pronósticos propios y, cuando termina,
/// el podio del día y los pronósticos de todos los participantes.
class DayView extends ConsumerWidget {
  const DayView({super.key, required this.day});

  /// Fecha de la jornada en formato API (`2026-06-11`).
  final String day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(dayDetailProvider(day));

    return detailAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(top: 120),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => _ErrorRetry(
        message: '$error',
        onRetry: () => ref.invalidate(dayDetailProvider(day)),
      ),
      data: (detail) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Hero(
                    tag: 'day-title-$day',
                    child: Material(
                      type: MaterialType.transparency,
                      child: Text(
                        dayTitle(detail.summary.date),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                ),
                DayStatusChip(status: detail.status),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 2, 20, 8),
            child: Row(
              children: [
                const Icon(Icons.groups_outlined,
                    size: 15, color: AppColors.textSecondary),
                const SizedBox(width: 5),
                Text(
                  '${detail.summary.participantsCount} participantes',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Spacer(),
                if (detail.status == DayStatus.open)
                  DeadlineCountdown(
                    deadline: detail.summary.bettingClosesAt,
                    onExpired: () {
                      ref.invalidate(dayDetailProvider(day));
                      ref.invalidate(daysProvider);
                    },
                  ),
              ],
            ),
          ),
          if (detail.status == DayStatus.open && !detail.participated)
            _ParticipateCard(day: day, matchCount: detail.matches.length),
          if (detail.status == DayStatus.locked &&
              !detail.summary.teamsDefined)
            _infoBanner(
              context,
              icon: Icons.hourglass_top,
              text: 'Equipos por definir: las apuestas se abrirán cuando '
                  'se conozcan los cruces',
            ),
          if (detail.participated) _participatedBanner(context, detail),
          for (final (index, match) in detail.matches.indexed)
            MatchCard(
              match: match,
              prediction: detail.myPredictions?[match.id],
            )
                .animate()
                .fadeIn(delay: (50 * index).ms, duration: 300.ms)
                .slideY(begin: 0.06, curve: Curves.easeOutCubic),
          if (detail.status == DayStatus.finished) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 6),
              child: Text(
                'Ganadores del día',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            _ResultsSection(day: day),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 6),
            child: Text(
              'Pronósticos de todos',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          if (detail.status != DayStatus.finished)
            _visibilityHint(context, ref, detail),
          _RevealSection(day: day),
        ],
      ),
    );
  }

  /// Explica qué se ve y qué no, según el modo configurado por el admin.
  Widget _visibilityHint(
    BuildContext context,
    WidgetRef ref,
    DayDetail detail,
  ) {
    final visibility = ref.watch(appSettingsProvider).value?.predictionsVisibility ??
        PredictionsVisibility.afterSubmit;
    final text = switch (visibility) {
      PredictionsVisibility.afterSubmit when !detail.participated =>
        'Sella tus pronósticos para ver los de los demás '
            '(los de partidos finalizados se ven siempre)',
      PredictionsVisibility.afterSubmit =>
        'Ya participaste: puedes ver los pronósticos de los demás',
      PredictionsVisibility.afterMatch =>
        'Los pronósticos de cada partido se revelan cuando ese '
            'partido finaliza',
    };
    return _infoBanner(
      context,
      icon: Icons.visibility_outlined,
      text: text,
    );
  }

  Widget _infoBanner(BuildContext context,
      {required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _participatedBanner(BuildContext context, DayDetail detail) {
    final scored = detail.status == DayStatus.finished;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline,
              color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              scored
                  ? 'Participaste · ${detail.myPoints} pts este día'
                  : 'Ya participaste: tus pronósticos están sellados',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms);
  }
}

class _ParticipateCard extends StatelessWidget {
  const _ParticipateCard({required this.day, required this.matchCount});

  final String day;
  final int matchCount;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.16),
            AppColors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('¿Te animas hoy?', style: textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            'Para participar debes pronosticar los $matchCount partidos '
            'del día. Una vez guardados no podrás cambiarlos.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => context.push('/participate/$day'),
              icon: const Icon(Icons.sports_soccer),
              label: const Text('Participar'),
            )
                .animate(onPlay: (c) => c.repeat())
                .shimmer(
                  delay: 2.seconds,
                  duration: 1200.ms,
                  color: Colors.white.withValues(alpha: 0.25),
                ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.05);
  }
}

class _ResultsSection extends ConsumerWidget {
  const _ResultsSection({required this.day});

  final String day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(dayResultsProvider(day));
    return resultsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => _ErrorRetry(
        message: '$error',
        onRetry: () => ref.invalidate(dayResultsProvider(day)),
      ),
      data: (results) => DayResultsBoard(results: results),
    );
  }
}

class _RevealSection extends ConsumerWidget {
  const _RevealSection({required this.day});

  final String day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final revealAsync = ref.watch(dayPredictionsProvider(day));
    final detail = ref.watch(dayDetailProvider(day)).value;
    // El ranking del día solo existe cuando la jornada terminó.
    final finished = detail?.status == DayStatus.finished;
    final winners =
        finished ? ref.watch(dayResultsProvider(day)).value : null;
    return revealAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => _ErrorRetry(
        message: '$error',
        onRetry: () => ref.invalidate(dayPredictionsProvider(day)),
      ),
      data: (participants) => participants.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'Aún no hay participantes este día',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            )
          : RevealBoard(
              participants: participants,
              matches: detail?.matches ?? const [],
              winnerIds: {
                for (final r in winners ?? const <DayResultEntry>[])
                  if (r.isWinner) r.userId,
              },
            ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Text(message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
