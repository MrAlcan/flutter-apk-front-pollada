import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollada/features/pools/domain/entities/leaderboard_entry.dart';
import 'package:pollada/features/pools/presentation/widgets/leaderboard_list.dart';

LeaderboardEntry _entry(int rank, int userId, String name, int points) =>
    LeaderboardEntry(
      rank: rank,
      userId: userId,
      displayName: name,
      totalPoints: points,
      exactHits: 0,
      outcomeHits: 0,
      daysPlayed: 1,
    );

Widget _wrap(List<LeaderboardEntry> entries) => MaterialApp(
      home: Scaffold(body: LeaderboardList(entries: entries)),
    );

void main() {
  testWidgets('reordena las filas con animación al recibir nuevos puntos',
      (tester) async {
    final before = [
      _entry(1, 1, 'ana', 5),
      _entry(2, 2, 'beto', 3),
      _entry(3, 3, 'carla', 1),
    ];
    await tester.pumpWidget(_wrap(before));
    expect(find.text('ana'), findsOneWidget);

    // beto adelanta a ana; carla sube a segunda.
    final after = [
      _entry(1, 2, 'beto', 9),
      _entry(2, 3, 'carla', 6),
      _entry(3, 1, 'ana', 5),
    ];
    await tester.pumpWidget(_wrap(after));
    await tester.pumpAndSettle();

    final rows =
        tester.widgetList<LeaderboardRow>(find.byType(LeaderboardRow)).toList();
    expect(rows.map((r) => r.entry.displayName).toList(),
        ['beto', 'carla', 'ana']);
    expect(find.text('9'), findsOneWidget);
  });

  testWidgets('maneja participantes nuevos y lista vacía', (tester) async {
    await tester.pumpWidget(_wrap(const []));
    expect(find.text('Aún no hay participantes'), findsOneWidget);

    await tester.pumpWidget(_wrap([_entry(1, 7, 'dani', 2)]));
    await tester.pumpAndSettle();
    expect(find.text('dani'), findsOneWidget);
  });
}
