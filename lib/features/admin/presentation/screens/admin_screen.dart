import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/dates.dart';
import '../../../pools/domain/entities/app_settings.dart';
import '../../../pools/domain/entities/match_info.dart';
import '../../../pools/presentation/providers.dart';
import '../../../pools/presentation/widgets/team_flag.dart';
import '../../domain/repositories/admin_repository.dart';
import '../providers.dart';
import '../widgets/result_sheet.dart';

/// Panel del administrador: switch de visibilidad de predicciones y los
/// 104 partidos del fixture agrupados por día. Por partido: marcador en
/// vivo editable y botón de finalizar (irreversible). La base de datos del
/// torneo se nutre exclusivamente desde aquí (sin API externa).
class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(allMatchesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin'),
        backgroundColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(appSettingsProvider);
          ref.invalidate(allMatchesProvider);
          await ref.read(allMatchesProvider.future);
        },
        child: matchesAsync.when(
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
                        onPressed: () => ref.invalidate(allMatchesProvider),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          data: (matches) {
            final sections = _groupByDay(matches);
            return ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                const _VisibilitySwitch(),
                if (sections.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: Center(
                      child: Text(
                        'No hay partidos en la base de datos',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                for (final section in sections) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
                    child: Text(
                      dayTitle(DateTime.parse(section.day)),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  for (final (index, match) in section.matches.indexed)
                    _AdminMatchTile(match: match)
                        .animate()
                        .fadeIn(delay: (30 * index).ms, duration: 250.ms)
                        .slideY(begin: 0.04, curve: Curves.easeOutCubic),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  List<({String day, List<MatchInfo> matches})> _groupByDay(
    List<MatchInfo> matches,
  ) {
    final sorted = [...matches]
      ..sort((a, b) => a.kickoff.compareTo(b.kickoff));
    final sections = <({String day, List<MatchInfo> matches})>[];
    for (final match in sorted) {
      if (sections.isEmpty || sections.last.day != match.day) {
        sections.add((day: match.day, matches: [match]));
      } else {
        sections.last.matches.add(match);
      }
    }
    return sections;
  }
}

/// Switch global: cuándo ven los usuarios las predicciones ajenas.
class _VisibilitySwitch extends ConsumerStatefulWidget {
  const _VisibilitySwitch();

  @override
  ConsumerState<_VisibilitySwitch> createState() => _VisibilitySwitchState();
}

class _VisibilitySwitchState extends ConsumerState<_VisibilitySwitch> {
  bool _saving = false;

  Future<void> _change(PredictionsVisibility visibility) async {
    setState(() => _saving = true);
    try {
      await ref.read(adminRepositoryProvider).updateSettings(visibility);
      ref.invalidate(appSettingsProvider);
      ref.invalidate(dayPredictionsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            visibility == PredictionsVisibility.afterSubmit
                ? 'Visibilidad: al sellar el pronóstico propio'
                : 'Visibilidad: al finalizar cada partido',
          ),
        ),
      );
    } on AdminException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final settings = ref.watch(appSettingsProvider);
    final current = settings.value?.predictionsVisibility;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.visibility_outlined,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Predicciones ajenas visibles…',
                  style: textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          if (current == null)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            SegmentedButton<PredictionsVisibility>(
              segments: const [
                ButtonSegment(
                  value: PredictionsVisibility.afterSubmit,
                  icon: Icon(Icons.how_to_vote_outlined, size: 16),
                  label: Text('Al sellar el propio'),
                ),
                ButtonSegment(
                  value: PredictionsVisibility.afterMatch,
                  icon: Icon(Icons.sports_score, size: 16),
                  label: Text('Al final del partido'),
                ),
              ],
              selected: {current},
              onSelectionChanged: _saving
                  ? null
                  : (selection) => _change(selection.first),
            ),
        ],
      ),
    );
  }
}

class _AdminMatchTile extends ConsumerWidget {
  const _AdminMatchTile({required this.match});

  final MatchInfo match;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: match.isLive ? const Color(0xFF0E2A1E) : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: match.isLive
              ? AppColors.primary.withValues(alpha: 0.6)
              : match.finished
                  ? AppColors.secondary.withValues(alpha: 0.35)
                  : AppColors.outline,
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        // Finalizado = sellado: no se puede editar ni deshacer.
        onTap: match.finished
            ? () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Partido finalizado: el resultado está sellado'),
                  ),
                )
            : match.teamsDefined
                ? () => showResultSheet(context, match: match)
                : () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Equipos por definir: completa los partidos previos',
                        ),
                      ),
                    ),
        leading: SizedBox(
          width: 52,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TeamFlag(team: match.homeTeam, size: 24),
              const SizedBox(width: 4),
              TeamFlag(team: match.awayTeam, size: 24),
            ],
          ),
        ),
        title: Text(
          '${match.homeLabel} vs ${match.awayLabel}',
          style: textTheme.titleMedium?.copyWith(
            fontSize: match.teamsDefined ? null : 13,
            color: match.teamsDefined ? null : AppColors.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              if (match.isLive) ...[
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .fade(duration: 700.ms, begin: 0.25, end: 1),
                const SizedBox(width: 5),
                const Text(
                  'EN JUEGO',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  '${match.stageLabel} · ${shortTime(match.kickoff)}',
                  style: textTheme.bodyMedium?.copyWith(fontSize: 12.5),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        trailing: match.hasScore
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${match.homeScore}-${match.awayScore}',
                    style: textTheme.titleLarge?.copyWith(
                      color: match.isLive
                          ? AppColors.primary
                          : AppColors.secondary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    match.finished ? Icons.lock : Icons.edit,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              )
            : Icon(
                match.teamsDefined
                    ? Icons.add_circle_outline
                    : Icons.lock_clock,
                color: match.teamsDefined
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
      ),
    );
  }
}
