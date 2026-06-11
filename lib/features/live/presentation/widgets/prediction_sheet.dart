import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/match_info.dart';
import '../../domain/entities/prediction.dart';
import '../controllers/predictions_controller.dart';

/// Abre el formulario de pronóstico como bottom-sheet.
Future<void> showPredictionSheet(
  BuildContext context, {
  required MatchInfo match,
  Prediction? current,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surfaceElevated,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => PredictionSheet(match: match, current: current),
  );
}

class PredictionSheet extends ConsumerStatefulWidget {
  const PredictionSheet({super.key, required this.match, this.current});

  final MatchInfo match;
  final Prediction? current;

  @override
  ConsumerState<PredictionSheet> createState() => _PredictionSheetState();
}

class _PredictionSheetState extends ConsumerState<PredictionSheet> {
  late int _home = widget.current?.predictedHome ?? 0;
  late int _away = widget.current?.predictedAway ?? 0;
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    final error = await ref.read(predictionsProvider.notifier).save(
          matchId: widget.match.id,
          predictedHome: _home,
          predictedAway: _away,
        );
    if (!mounted) return;
    setState(() => _saving = false);
    if (error == null) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pronóstico guardado: $_home-$_away ⚽')),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
            widget.current == null ? 'Tu pronóstico' : 'Edita tu pronóstico',
            textAlign: TextAlign.center,
            style: textTheme.titleLarge,
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _ScoreStepper(
                  team: widget.match.teamHome,
                  value: _home,
                  onChanged: (v) => setState(() => _home = v),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('—', style: textTheme.headlineMedium),
              ),
              Expanded(
                child: _ScoreStepper(
                  team: widget.match.teamAway,
                  value: _away,
                  onChanged: (v) => setState(() => _away = v),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: AnimatedSwitcher(
              duration: 250.ms,
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.onPrimary,
                      ),
                    )
                  : const Text('Guardar pronóstico'),
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 300.ms),
        ],
      ),
    );
  }
}

/// Selector de goles con botones +/- y número animado.
class _ScoreStepper extends StatelessWidget {
  const _ScoreStepper({
    required this.team,
    required this.value,
    required this.onChanged,
  });

  final String team;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(
          team,
          style: textTheme.titleMedium,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outline),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: value > 0 ? () => onChanged(value - 1) : null,
                icon: const Icon(Icons.remove),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutBack,
                  ),
                  child: child,
                ),
                child: Text(
                  '$value',
                  key: ValueKey(value),
                  style: textTheme.headlineMedium
                      ?.copyWith(color: AppColors.primary),
                ),
              ),
              IconButton(
                onPressed: value < 99 ? () => onChanged(value + 1) : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
