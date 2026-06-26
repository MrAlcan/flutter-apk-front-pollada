import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../pools/domain/entities/match_info.dart';
import '../../../pools/presentation/providers.dart';
import '../../../pools/presentation/widgets/score_stepper.dart';
import '../../../pools/presentation/widgets/team_flag.dart';
import '../../domain/repositories/admin_repository.dart';
import '../providers.dart';

/// Abre el formulario de partido del admin: marcador en vivo (editable)
/// y botón "Finalizar partido" (irreversible).
Future<void> showResultSheet(BuildContext context, {required MatchInfo match}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surfaceElevated,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => ResultSheet(match: match),
  );
}

class ResultSheet extends ConsumerStatefulWidget {
  const ResultSheet({super.key, required this.match});

  final MatchInfo match;

  @override
  ConsumerState<ResultSheet> createState() => _ResultSheetState();
}

class _ResultSheetState extends ConsumerState<ResultSheet> {
  late int _home = widget.match.homeScore ?? 0;
  late int _away = widget.match.awayScore ?? 0;
  int? _winnerTeamId;
  bool _savingScore = false;
  bool _finalizing = false;

  /// Hubo cambios locales aún no enviados con "Actualizar marcador".
  bool get _dirty =>
      _home != (widget.match.homeScore ?? 0) ||
      _away != (widget.match.awayScore ?? 0);

  /// En llaves con empate el backend exige el ganador por penales.
  bool get _needsWinner => widget.match.isKnockout && _home == _away;

  void _invalidateAll() {
    ref.invalidate(allMatchesProvider);
    ref.invalidate(daysProvider);
    ref.invalidate(dayDetailProvider);
    ref.invalidate(dayPredictionsProvider);
    ref.invalidate(dayResultsProvider);
    ref.invalidate(leaderboardProvider);
    ref.invalidate(groupsProvider);
    ref.invalidate(globalHistoryProvider);
  }

  Future<void> _saveScore() async {
    setState(() => _savingScore = true);
    try {
      await ref.read(adminRepositoryProvider).updateScore(
            matchId: widget.match.id,
            homeScore: _home,
            awayScore: _away,
          );
      _invalidateAll();
      if (!mounted) return;
      setState(() => _savingScore = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Marcador en vivo: $_home-$_away'),
          duration: const Duration(seconds: 1),
        ),
      );
    } on AdminException catch (e) {
      if (!mounted) return;
      setState(() => _savingScore = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _finalize() async {
    if (_needsWinner && _winnerTeamId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Empate en llave: elige el ganador por penales'),
        ),
      );
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: const Text('¿Finalizar el partido?'),
        content: Text(
          'Se cerrará con el marcador $_home-$_away. Esta acción es '
          'irreversible: ya no podrás editar el resultado. Se puntuarán '
          'las predicciones y se actualizarán grupos y llaves.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Finalizar partido'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _finalizing = true);
    try {
      // El marcador local sin guardar se envía antes de finalizar, porque
      // finalize toma el último marcador cargado en el backend.
      if (_dirty) {
        await ref.read(adminRepositoryProvider).updateScore(
              matchId: widget.match.id,
              homeScore: _home,
              awayScore: _away,
            );
      }
      await ref.read(adminRepositoryProvider).finalizeMatch(
            matchId: widget.match.id,
            winnerTeamId: _needsWinner ? _winnerTeamId : null,
          );
      _invalidateAll();
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Partido finalizado: ${widget.match.homeLabel} $_home-$_away '
            '${widget.match.awayLabel}',
          ),
        ),
      );
    } on AdminException catch (e) {
      if (!mounted) return;
      setState(() => _finalizing = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final match = widget.match;
    final busy = _savingScore || _finalizing;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24, 20, 24, 24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 44,
            height: 4,
            alignment: Alignment.center,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppColors.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            'Marcador en vivo',
            textAlign: TextAlign.center,
            style: textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            match.stageLabel,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    TeamFlag(team: match.homeTeam, size: 32),
                    const SizedBox(height: 8),
                    ScoreStepper(
                      team: match.homeLabel,
                      value: _home,
                      onChanged: (v) => setState(() => _home = v),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 52),
                child: Text('—', style: textTheme.headlineMedium),
              ),
              Expanded(
                child: Column(
                  children: [
                    TeamFlag(team: match.awayTeam, size: 32),
                    const SizedBox(height: 8),
                    ScoreStepper(
                      team: match.awayLabel,
                      value: _away,
                      onChanged: (v) => setState(() => _away = v),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: busy ? null : _saveScore,
            icon: _savingScore
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync, size: 18),
            label: const Text('Actualizar marcador (en vivo)'),
          ),
          const SizedBox(height: 6),
          Text(
            'Edita los goles cuantas veces necesites mientras el partido '
            'está en juego; los usuarios lo ven al instante.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(fontSize: 11.5),
          ),
          if (_needsWinner) ...[
            const SizedBox(height: 16),
            Text(
              'Ganador por penales (requerido para finalizar)',
              textAlign: TextAlign.center,
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                for (final team in [match.homeTeam, match.awayTeam])
                  if (team != null)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TeamFlag(team: team, size: 18),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  team.fifaCode,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          selected: _winnerTeamId == team.id,
                          selectedColor:
                              AppColors.primary.withValues(alpha: 0.25),
                          onSelected: (_) =>
                              setState(() => _winnerTeamId = team.id),
                        ),
                      ),
                    ),
              ],
            ),
          ],
          const SizedBox(height: 18),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: busy ? null : _finalize,
            icon: _finalizing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.sports_score, size: 20),
            label: const Text('FINALIZAR PARTIDO'),
          ).animate().fadeIn(delay: 150.ms, duration: 300.ms),
          const SizedBox(height: 6),
          Text(
            'Irreversible: puntúa predicciones, define el ganador y '
            'actualiza grupos y llaves. Si es el último del día, la '
            'jornada queda terminada y se publican los resultados.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(fontSize: 11.5),
          ),
        ],
      ),
    );
  }
}
