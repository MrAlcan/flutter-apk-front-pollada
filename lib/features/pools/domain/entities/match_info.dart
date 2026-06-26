import 'team.dart';

/// Estado del partido: `live` = ya pasó el kickoff y el admin no lo
/// finalizó (el marcador parcial puede venir con goles).
enum MatchStatus {
  scheduled,
  live,
  finished;

  static MatchStatus fromApi(String? value) => switch (value) {
        'live' => MatchStatus.live,
        'finished' => MatchStatus.finished,
        _ => MatchStatus.scheduled,
      };
}

/// Fase del torneo (espeja el enum `stage` del backend).
enum Stage {
  group('Fase de grupos', 'group'),
  r32('Dieciseisavos', 'r32'),
  r16('Octavos', 'r16'),
  qf('Cuartos', 'qf'),
  sf('Semifinal', 'sf'),
  third('Tercer puesto', 'third'),
  finalMatch('Final', 'final');

  const Stage(this.label, this.apiValue);

  final String label;
  final String apiValue;

  static Stage fromApi(String? value) => Stage.values.firstWhere(
        (stage) => stage.apiValue == value,
        orElse: () => Stage.group,
      );
}

/// Entidad de dominio: un partido del fixture (104 en total, en la base).
class MatchInfo {
  const MatchInfo({
    required this.id,
    required this.stage,
    required this.group,
    required this.matchday,
    required this.kickoff,
    required this.day,
    required this.stadium,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeSource,
    required this.awaySource,
    required this.homeScore,
    required this.awayScore,
    required this.winnerTeamId,
    required this.finished,
    required this.status,
  });

  final int id;
  final Stage stage;
  final String? group;
  final int? matchday;

  /// Hora local del fixture (sin zona; el backend compara en APP_TIMEZONE).
  final DateTime kickoff;

  /// Día de la jornada en formato `YYYY-MM-DD`.
  final String day;

  final Stadium? stadium;

  /// Null mientras la llave no esté definida; ver [homeSource]/[awaySource].
  final Team? homeTeam;
  final Team? awayTeam;

  /// Descripción del origen del cruce (p. ej. `Runner-up Group A`).
  final String? homeSource;
  final String? awaySource;

  final int? homeScore;
  final int? awayScore;

  /// Solo en llaves que terminaron en empate: ganador por penales.
  final int? winnerTeamId;

  final bool finished;

  final MatchStatus status;

  bool get isLive => status == MatchStatus.live;

  /// Hay marcador para mostrar (parcial en vivo o final).
  bool get hasScore => homeScore != null && awayScore != null;

  bool get teamsDefined => homeTeam != null && awayTeam != null;

  bool get isKnockout => stage != Stage.group;

  bool get isDraw => finished && homeScore == awayScore;

  String get homeLabel => homeTeam?.name ?? homeSource ?? 'Por definir';

  String get awayLabel => awayTeam?.name ?? awaySource ?? 'Por definir';

  /// Etiqueta corta de fase: `Grupo B` u `Octavos`.
  String get stageLabel =>
      stage == Stage.group && group != null ? 'Grupo $group' : stage.label;
}
