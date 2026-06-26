import '../../domain/entities/app_settings.dart';
import '../../domain/entities/day_reveal.dart';
import '../../domain/entities/global_history.dart';
import '../../domain/entities/group_standings.dart';
import '../../domain/entities/history_entry.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/entities/match_day.dart';
import '../../domain/entities/match_info.dart';
import '../../domain/entities/prediction.dart';
import '../../domain/entities/scoring_config.dart';
import '../../domain/entities/team.dart';

/// Los `kickoff` del fixture vienen como hora local sin zona (el backend
/// compara contra APP_TIMEZONE); se parsean tal cual, sin convertir.
DateTime parseNaiveDate(String value) => DateTime.parse(value);

Team teamFromJson(Map<String, dynamic> json) => Team(
      id: json['id'] as int,
      name: json['name'] as String,
      fifaCode: json['fifa_code'] as String,
      iso2: json['iso2'] as String,
      flagUrl: json['flag_url'] as String,
      group: json['group'] as String?,
    );

Stadium stadiumFromJson(Map<String, dynamic> json) => Stadium(
      id: json['id'] as int,
      name: json['name'] as String,
      city: json['city'] as String,
      country: json['country'] as String,
      capacity: json['capacity'] as int,
    );

MatchInfo matchFromJson(Map<String, dynamic> json) => MatchInfo(
      id: json['id'] as int,
      stage: Stage.fromApi(json['stage'] as String?),
      group: json['group'] as String?,
      matchday: json['matchday'] as int?,
      kickoff: parseNaiveDate(json['kickoff'] as String),
      day: json['day'] as String,
      stadium: json['stadium'] == null
          ? null
          : stadiumFromJson(json['stadium'] as Map<String, dynamic>),
      homeTeam: json['home_team'] == null
          ? null
          : teamFromJson(json['home_team'] as Map<String, dynamic>),
      awayTeam: json['away_team'] == null
          ? null
          : teamFromJson(json['away_team'] as Map<String, dynamic>),
      homeSource: json['home_source'] as String?,
      awaySource: json['away_source'] as String?,
      homeScore: json['home_score'] as int?,
      awayScore: json['away_score'] as int?,
      winnerTeamId: json['winner_team_id'] as int?,
      finished: json['finished'] as bool? ?? false,
      status: json['status'] != null
          ? MatchStatus.fromApi(json['status'] as String)
          // Backends sin el campo: se infiere de `finished`.
          : (json['finished'] as bool? ?? false)
              ? MatchStatus.finished
              : MatchStatus.scheduled,
    );

Prediction predictionFromJson(Map<String, dynamic> json) => Prediction(
      matchId: json['match_id'] as int,
      predictedHome: json['predicted_home'] as int,
      predictedAway: json['predicted_away'] as int,
      pointsEarned: json['points_earned'] as int?,
    );

Map<String, dynamic> predictionInputToJson(PredictionInput input) => {
      'match_id': input.matchId,
      'predicted_home': input.predictedHome,
      'predicted_away': input.predictedAway,
    };

MatchDaySummary daySummaryFromJson(Map<String, dynamic> json) =>
    MatchDaySummary(
      day: json['day'] as String,
      matchCount: json['match_count'] as int,
      firstKickoff: parseNaiveDate(json['first_kickoff'] as String),
      bettingClosesAt: parseNaiveDate(json['betting_closes_at'] as String),
      status: DayStatus.fromApi(json['status'] as String),
      teamsDefined: json['teams_defined'] as bool? ?? true,
      allFinished: json['all_finished'] as bool? ?? false,
      participated: json['participated'] as bool? ?? false,
      participantsCount: json['participants_count'] as int? ?? 0,
    );

DayDetail dayDetailFromJson(Map<String, dynamic> json) => DayDetail(
      summary: daySummaryFromJson(json['summary'] as Map<String, dynamic>),
      matches: [
        for (final item in json['matches'] as List<dynamic>)
          matchFromJson(item as Map<String, dynamic>),
      ],
      myPredictions: json['my_predictions'] == null
          ? null
          : {
              for (final item in json['my_predictions'] as List<dynamic>)
                (item as Map<String, dynamic>)['match_id'] as int:
                    predictionFromJson(item),
            },
    );

ParticipantReveal participantRevealFromJson(Map<String, dynamic> json) =>
    ParticipantReveal(
      userId: json['user_id'] as int,
      displayName: json['display_name'] as String,
      dayPoints: json['day_points'] as int,
      predictions: {
        for (final item in json['predictions'] as List<dynamic>)
          (item as Map<String, dynamic>)['match_id'] as int:
              predictionFromJson(item),
      },
    );

DayResultEntry dayResultFromJson(Map<String, dynamic> json) => DayResultEntry(
      rank: json['rank'] as int,
      userId: json['user_id'] as int,
      displayName: json['display_name'] as String,
      dayPoints: json['day_points'] as int,
      exactHits: json['exact_hits'] as int,
      outcomeHits: json['outcome_hits'] as int,
      isWinner: json['is_winner'] as bool? ?? false,
    );

LeaderboardEntry leaderboardEntryFromJson(Map<String, dynamic> json) =>
    LeaderboardEntry(
      rank: json['rank'] as int,
      userId: json['user_id'] as int,
      displayName: json['display_name'] as String,
      totalPoints: json['total_points'] as int,
      exactHits: json['exact_hits'] as int,
      outcomeHits: json['outcome_hits'] as int,
      daysPlayed: json['days_played'] as int? ?? 0,
    );

HistoryEntry historyEntryFromJson(Map<String, dynamic> json) => HistoryEntry(
      day: json['day'] as String,
      submittedAt: parseNaiveDate(json['submitted_at'] as String),
      dayFinished: json['day_finished'] as bool? ?? false,
      points: json['points'] as int? ?? 0,
    );

GroupRow groupRowFromJson(Map<String, dynamic> json) => GroupRow(
      position: json['position'] as int,
      team: teamFromJson(json['team'] as Map<String, dynamic>),
      played: json['played'] as int,
      won: json['won'] as int,
      drawn: json['drawn'] as int,
      lost: json['lost'] as int,
      goalsFor: json['goals_for'] as int,
      goalsAgainst: json['goals_against'] as int,
      goalDiff: json['goal_diff'] as int,
      points: json['points'] as int,
    );

GroupStandings groupStandingsFromJson(Map<String, dynamic> json) =>
    GroupStandings(
      group: json['group'] as String,
      rows: [
        for (final item in json['rows'] as List<dynamic>)
          groupRowFromJson(item as Map<String, dynamic>),
      ],
    );

AppSettings appSettingsFromJson(Map<String, dynamic> json) => AppSettings(
      predictionsVisibility: PredictionsVisibility.fromApi(
        json['predictions_visibility'] as String?,
      ),
    );

DayWinner dayWinnerFromJson(Map<String, dynamic> json) => DayWinner(
      userId: json['user_id'] as int,
      displayName: json['display_name'] as String,
      dayPoints: json['day_points'] as int,
    );

GlobalHistoryEntry globalHistoryEntryFromJson(Map<String, dynamic> json) =>
    GlobalHistoryEntry(
      day: json['day'] as String,
      matchCount: json['match_count'] as int,
      dayFinished: json['day_finished'] as bool? ?? false,
      participated: json['participated'] as bool? ?? false,
      myPoints: json['my_points'] as int?,
      participantsCount: json['participants_count'] as int? ?? 0,
      winners: json['winners'] == null
          ? null
          : [
              for (final item in json['winners'] as List<dynamic>)
                dayWinnerFromJson(item as Map<String, dynamic>),
            ],
    );

/// `GET /health` expone los puntajes configurados.
ScoringConfig scoringConfigFromHealthJson(Map<String, dynamic> json) =>
    ScoringConfig(
      pointsOutcome: json['points_outcome_match'] as int? ?? 1,
      pointsExact: json['points_exact_match'] as int? ?? 3,
    );
