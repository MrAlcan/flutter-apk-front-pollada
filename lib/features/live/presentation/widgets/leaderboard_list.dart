import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/leaderboard_entry.dart';

/// Tabla de posiciones animada. Cuando llega una actualización del
/// WebSocket, se calcula la diferencia de orden por usuario y las filas
/// que cambian de puesto se animan (salida + entrada deslizante) con
/// AnimatedList, de modo que la reorganización se percibe fluida.
class LeaderboardList extends StatefulWidget {
  const LeaderboardList({
    super.key,
    required this.entries,
    this.highlightEmail,
  });

  final List<LeaderboardEntry> entries;

  /// Email del usuario autenticado, para resaltar su fila.
  final String? highlightEmail;

  @override
  State<LeaderboardList> createState() => _LeaderboardListState();
}

class _LeaderboardListState extends State<LeaderboardList> {
  final _listKey = GlobalKey<AnimatedListState>();
  late List<LeaderboardEntry> _entries = List.of(widget.entries);

  @override
  void didUpdateWidget(LeaderboardList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _applyUpdate(widget.entries);
  }

  /// Diff por userId: las filas cuyo puesto cambió se quitan y reinsertan
  /// en su nueva posición; AnimatedList anima ambas transiciones.
  void _applyUpdate(List<LeaderboardEntry> next) {
    final listState = _listKey.currentState;
    if (listState == null) {
      setState(() => _entries = List.of(next));
      return;
    }

    final working = List.of(_entries);
    for (var target = 0; target < next.length; target++) {
      final entry = next[target];
      final current = working.indexWhere((e) => e.userId == entry.userId);
      if (current == target) continue;
      if (current != -1) {
        final moved = working.removeAt(current);
        listState.removeItem(
          current,
          (context, animation) => _buildRow(moved, animation),
          duration: const Duration(milliseconds: 350),
        );
      }
      working.insert(target, entry);
      listState.insertItem(target,
          duration: const Duration(milliseconds: 350));
    }
    while (working.length > next.length) {
      final index = working.length - 1;
      final removed = working.removeAt(index);
      listState.removeItem(
        index,
        (context, animation) => _buildRow(removed, animation),
        duration: const Duration(milliseconds: 350),
      );
    }
    setState(() => _entries = List.of(next));
  }

  @override
  Widget build(BuildContext context) {
    if (_entries.isEmpty) {
      return Center(
        child: Text(
          'Aún no hay participantes',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }
    return AnimatedList(
      key: _listKey,
      initialItemCount: _entries.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index, animation) =>
          _buildRow(_entries[index], animation),
    );
  }

  Widget _buildRow(LeaderboardEntry entry, Animation<double> animation) {
    final curved =
        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
    return SizeTransition(
      sizeFactor: curved,
      child: FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.15, 0),
            end: Offset.zero,
          ).animate(curved),
          child: LeaderboardRow(
            entry: entry,
            highlighted: entry.email == widget.highlightEmail,
          ),
        ),
      ),
    );
  }
}

class LeaderboardRow extends StatelessWidget {
  const LeaderboardRow({
    super.key,
    required this.entry,
    this.highlighted = false,
  });

  final LeaderboardEntry entry;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: highlighted
            ? AppColors.primary.withValues(alpha: 0.08)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: highlighted
              ? AppColors.primary.withValues(alpha: 0.6)
              : AppColors.outline,
        ),
      ),
      child: Row(
        children: [
          _RankBadge(rank: entry.rank),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.displayName,
                  style: textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.exactHits} exactos · ${entry.outcomeHits} aciertos',
                  style: textTheme.bodyMedium?.copyWith(fontSize: 12.5),
                ),
              ],
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: CurvedAnimation(
                  parent: animation, curve: Curves.easeOutBack),
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: Text(
              '${entry.totalPoints}',
              key: ValueKey(entry.totalPoints),
              style: textTheme.headlineMedium?.copyWith(
                color: AppColors.primary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(' pts', style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank});

  final int rank;

  @override
  Widget build(BuildContext context) {
    final color = switch (rank) {
      1 => const Color(0xFFFFD700), // oro
      2 => const Color(0xFFC0C7D1), // plata
      3 => const Color(0xFFCD8C52), // bronce
      _ => AppColors.surfaceElevated,
    };
    final onColor = rank <= 3 ? const Color(0xFF131313) : AppColors.textPrimary;
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Text(
        '$rank',
        style: TextStyle(
          color: onColor,
          fontWeight: FontWeight.w800,
          fontSize: 15,
        ),
      ),
    );
  }
}
