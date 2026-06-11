import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/entities/match_info.dart';
import '../../domain/entities/prediction.dart';

/// El backend serializa datetimes UTC sin sufijo de zona; se normaliza aquí.
DateTime parseUtcDate(String value) {
  final parsed = DateTime.parse(value);
  return parsed.isUtc ? parsed : DateTime.parse('${value}Z');
}

MatchInfo matchFromJson(Map<String, dynamic> json) => MatchInfo(
      id: json['id'] as int,
      teamHome: json['team_home'] as String,
      teamAway: json['team_away'] as String,
      goalsHome: json['goals_home'] as int?,
      goalsAway: json['goals_away'] as int?,
      status: MatchStatus.fromApi(json['status'] as String),
      matchTime: parseUtcDate(json['match_time'] as String),
    );

LeaderboardEntry leaderboardEntryFromJson(Map<String, dynamic> json) =>
    LeaderboardEntry(
      rank: json['rank'] as int,
      userId: json['user_id'] as int,
      email: json['email'] as String,
      totalPoints: json['total_points'] as int,
      exactHits: json['exact_hits'] as int,
      outcomeHits: json['outcome_hits'] as int,
    );

Prediction predictionFromJson(Map<String, dynamic> json) => Prediction(
      id: json['id'] as int,
      matchId: json['match_id'] as int,
      predictedHome: json['predicted_home'] as int,
      predictedAway: json['predicted_away'] as int,
      pointsEarned: json['points_earned'] as int?,
    );
