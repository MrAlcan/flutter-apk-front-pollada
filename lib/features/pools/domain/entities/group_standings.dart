import 'team.dart';

/// Fila de la tabla de posiciones de un grupo.
class GroupRow {
  const GroupRow({
    required this.position,
    required this.team,
    required this.played,
    required this.won,
    required this.drawn,
    required this.lost,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.goalDiff,
    required this.points,
  });

  final int position;
  final Team team;
  final int played;
  final int won;
  final int drawn;
  final int lost;
  final int goalsFor;
  final int goalsAgainst;
  final int goalDiff;
  final int points;
}

/// Tabla de un grupo; el backend la recalcula con cada resultado.
class GroupStandings {
  const GroupStandings({required this.group, required this.rows});

  final String group;
  final List<GroupRow> rows;
}
