import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/group_standings.dart';
import '../providers.dart';
import '../widgets/team_flag.dart';

/// Tablas de posiciones de los grupos; el backend las recalcula con cada
/// resultado que carga el admin.
class GroupsScreen extends ConsumerWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(groupsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grupos'),
        backgroundColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(groupsProvider.future),
        child: groupsAsync.when(
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
                        onPressed: () => ref.invalidate(groupsProvider),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          data: (groups) => ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: groups.length,
            itemBuilder: (context, index) => _GroupCard(group: groups[index])
                .animate()
                .fadeIn(delay: (50 * index).ms, duration: 300.ms)
                .slideY(begin: 0.04, curve: Curves.easeOutCubic),
          ),
        ),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.group});

  final GroupStandings group;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Grupo ${group.group}', style: textTheme.titleLarge),
          const SizedBox(height: 10),
          Row(
            children: [
              const SizedBox(width: 26),
              const SizedBox(width: 30),
              const SizedBox(width: 8),
              Expanded(
                child:
                    Text('Equipo', style: _headerStyle(textTheme)),
              ),
              _statCell('PJ', header: true, textTheme: textTheme),
              _statCell('DG', header: true, textTheme: textTheme),
              _statCell('Pts', header: true, textTheme: textTheme),
            ],
          ),
          const SizedBox(height: 4),
          for (final row in group.rows) _row(row, textTheme),
        ],
      ),
    );
  }

  TextStyle? _headerStyle(TextTheme textTheme) =>
      textTheme.bodyMedium?.copyWith(fontSize: 11.5);

  Widget _row(GroupRow row, TextTheme textTheme) {
    // 1.º y 2.º clasifican directo; el 3.º puede entrar entre los 8 mejores.
    final color = switch (row.position) {
      1 || 2 => AppColors.primary,
      3 => AppColors.secondary,
      _ => AppColors.textSecondary,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 26,
            child: Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Text(
                '${row.position}',
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          TeamFlag(team: row.team, size: 26),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              row.team.name,
              style: textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _statCell('${row.played}', textTheme: textTheme),
          _statCell(
            row.goalDiff > 0 ? '+${row.goalDiff}' : '${row.goalDiff}',
            textTheme: textTheme,
          ),
          _statCell('${row.points}', bold: true, textTheme: textTheme),
        ],
      ),
    );
  }

  Widget _statCell(
    String value, {
    bool header = false,
    bool bold = false,
    required TextTheme textTheme,
  }) {
    return SizedBox(
      width: 34,
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: header
            ? _headerStyle(textTheme)
            : textTheme.bodyMedium?.copyWith(
                color: bold ? AppColors.primary : null,
                fontWeight: bold ? FontWeight.w800 : null,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
      ),
    );
  }
}
