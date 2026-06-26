import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/dates.dart';
import '../../domain/entities/match_day.dart';
import '../../domain/entities/prediction.dart';
import '../../domain/repositories/pools_repository.dart';
import '../providers.dart';
import '../widgets/deadline_countdown.dart';
import '../widgets/score_stepper.dart';
import '../widgets/team_flag.dart';

/// Formulario de participación: exige el pronóstico de todos los partidos
/// del día y advierte que, una vez guardados, son inmutables (409 si repite).
class ParticipationScreen extends ConsumerStatefulWidget {
  const ParticipationScreen({super.key, required this.day});

  /// Fecha en formato API (`2026-06-11`).
  final String day;

  @override
  ConsumerState<ParticipationScreen> createState() =>
      _ParticipationScreenState();
}

class _ParticipationScreenState extends ConsumerState<ParticipationScreen> {
  /// Marcador elegido por partido: matchId -> (local, visita).
  final Map<int, (int, int)> _scores = {};
  bool _submitting = false;

  Future<void> _submit(DayDetail detail) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: const Text('¿Confirmas tus pronósticos?'),
        content: Text(
          'Enviarás ${detail.matches.length} pronósticos para la jornada '
          'del ${dayTitle(detail.summary.date)}. Una vez guardados no '
          'podrás modificarlos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Revisar de nuevo'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmar y sellar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _submitting = true);
    try {
      await ref.read(poolsRepositoryProvider).submitPredictions(
            widget.day,
            [
              for (final match in detail.matches)
                PredictionInput(
                  matchId: match.id,
                  predictedHome: _scores[match.id]?.$1 ?? 0,
                  predictedAway: _scores[match.id]?.$2 ?? 0,
                ),
            ],
          );
      ref.invalidate(dayDetailProvider(widget.day));
      ref.invalidate(daysProvider);
      ref.invalidate(myHistoryProvider);
      if (!mounted) return;
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pronósticos sellados. ¡Suerte! ⚽'),
        ),
      );
    } on PoolsException catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(dayDetailProvider(widget.day));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tus pronósticos'),
        backgroundColor: Colors.transparent,
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('$error', style: Theme.of(context).textTheme.bodyMedium),
        ),
        data: (detail) {
          if (detail.status != DayStatus.open || detail.participated) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  detail.participated
                      ? 'Ya enviaste tus pronósticos para este día'
                      : 'Las apuestas de este día están cerradas',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            );
          }
          for (final match in detail.matches) {
            _scores.putIfAbsent(match.id, () => (0, 0));
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        dayTitle(detail.summary.date),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    DeadlineCountdown(
                      deadline: detail.summary.bettingClosesAt,
                      onExpired: () =>
                          ref.invalidate(dayDetailProvider(widget.day)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 12),
                  itemCount: detail.matches.length,
                  itemBuilder: (context, index) {
                    final match = detail.matches[index];
                    final (home, away) = _scores[match.id]!;
                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.outline),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                match.stageLabel,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontSize: 12),
                              ),
                              Text(
                                shortTime(match.kickoff),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    TeamFlag(team: match.homeTeam, size: 30),
                                    const SizedBox(height: 8),
                                    ScoreStepper(
                                      team: match.homeLabel,
                                      value: home,
                                      onChanged: (v) => setState(
                                          () => _scores[match.id] = (v, away)),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 48),
                                child: Text(
                                  '—',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    TeamFlag(team: match.awayTeam, size: 30),
                                    const SizedBox(height: 8),
                                    ScoreStepper(
                                      team: match.awayLabel,
                                      value: away,
                                      onChanged: (v) => setState(
                                          () => _scores[match.id] = (home, v)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(delay: (50 * index).ms, duration: 300.ms)
                        .slideY(begin: 0.05, curve: Curves.easeOutCubic);
                  },
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _submitting ? null : () => _submit(detail),
                      child: AnimatedSwitcher(
                        duration: 250.ms,
                        child: _submitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.onPrimary,
                                ),
                              )
                            : Text(
                                'Sellar ${detail.matches.length} pronósticos'),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
