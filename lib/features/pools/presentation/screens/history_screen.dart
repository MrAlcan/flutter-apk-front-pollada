import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/dates.dart';
import '../../domain/entities/global_history.dart';
import '../../domain/entities/match_day.dart';
import '../providers.dart';
import '../widgets/day_status_chip.dart';

/// Histórico por jornada (`GET /history`): cada día con partidos, haya
/// participado o no, con sus puntos y los ganadores del día. Al tocar se
/// abre el detalle con las apuestas de todos.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daysAsync = ref.watch(daysProvider);
    final historyByDay = {
      for (final e in ref.watch(globalHistoryProvider).value ??
          const <GlobalHistoryEntry>[])
        e.day: e,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jornadas'),
        backgroundColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(globalHistoryProvider);
          ref.invalidate(daysProvider);
          await ref.read(daysProvider.future);
        },
        child: daysAsync.when(
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
                        onPressed: () => ref.invalidate(daysProvider),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          data: (days) => days.isEmpty
              ? ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 120),
                      child: Column(
                        children: [
                          const Icon(Icons.history,
                              size: 56, color: AppColors.textSecondary),
                          const SizedBox(height: 12),
                          Text(
                            'Aún no hay jornadas',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: days.length,
                  itemBuilder: (context, index) => _DayTile(
                    day: days[index],
                    history: historyByDay[days[index].day],
                  )
                      .animate()
                      .fadeIn(delay: (40 * index).ms, duration: 300.ms)
                      .slideY(begin: 0.05, curve: Curves.easeOutCubic),
                ),
        ),
      ),
    );
  }
}

class _DayTile extends StatelessWidget {
  const _DayTile({required this.day, this.history});

  final MatchDaySummary day;
  final GlobalHistoryEntry? history;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final winners = history?.winners ?? const <DayWinner>[];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outline),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.push('/day/${day.day}'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Hero(
                      tag: 'day-title-${day.day}',
                      child: Material(
                        type: MaterialType.transparency,
                        child: Text(dayTitle(day.date),
                            style: textTheme.titleMedium),
                      ),
                    ),
                  ),
                  DayStatusChip(status: day.status),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text('${day.matchCount} partidos',
                      style: textTheme.bodyMedium),
                  const SizedBox(width: 10),
                  if (day.participated) ...[
                    const Icon(Icons.check_circle,
                        size: 15, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      history?.myPoints != null && history!.dayFinished
                          ? '${history!.myPoints} pts'
                          : 'Participaste',
                      style: textTheme.bodyMedium
                          ?.copyWith(color: AppColors.primary),
                    ),
                  ] else
                    Text('Sin participar', style: textTheme.bodyMedium),
                  const Spacer(),
                  const Icon(Icons.groups_outlined,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 3),
                  Text('${day.participantsCount}',
                      style: textTheme.bodyMedium),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right,
                      size: 18, color: AppColors.textSecondary),
                ],
              ),
              if (winners.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    for (final winner in winners)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color:
                              AppColors.secondary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.secondary
                                .withValues(alpha: 0.45),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.emoji_events,
                                size: 13, color: AppColors.secondary),
                            const SizedBox(width: 4),
                            Text(
                              '${winner.displayName} · '
                              '${winner.dayPoints} pts',
                              style: const TextStyle(
                                color: AppColors.secondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
