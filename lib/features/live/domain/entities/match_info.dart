/// Estado de un partido (espeja el enum del backend).
enum MatchStatus {
  scheduled,
  live,
  finished;

  static MatchStatus fromApi(String value) => switch (value) {
        'live' => MatchStatus.live,
        'finished' => MatchStatus.finished,
        _ => MatchStatus.scheduled,
      };
}

/// Entidad de dominio: un partido del mundial.
class MatchInfo {
  const MatchInfo({
    required this.id,
    required this.teamHome,
    required this.teamAway,
    required this.goalsHome,
    required this.goalsAway,
    required this.status,
    required this.matchTime,
  });

  final int id;
  final String teamHome;
  final String teamAway;
  final int? goalsHome;
  final int? goalsAway;
  final MatchStatus status;
  final DateTime matchTime;
}
