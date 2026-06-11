// ignore_for_file: avoid_print  — herramienta de línea de comandos
// Sonda manual del canal en vivo: imprime eventos del datasource real.
// Uso: dart run tool/ws_probe.dart [segundos]
// Reiniciar el backend a mitad de ejecución permite ver la reconexión.
import 'dart:async';

import 'package:pollada/features/live/data/datasources/live_socket_datasource.dart';
import 'package:pollada/features/live/domain/repositories/live_repository.dart';

Future<void> main(List<String> args) async {
  final seconds = args.isEmpty ? 60 : int.parse(args.first);
  final socket = LiveSocketDataSource('ws://localhost:8000/ws/live');
  final stamp = Stopwatch()..start();

  final subscription = socket.events.listen((event) {
    final t = 't+${stamp.elapsed.inSeconds}s';
    switch (event) {
      case LiveStatusEvent(:final status):
        print('$t  estado: ${status.name}');
      case LiveDataEvent(:final matches, :final leaderboard):
        final live = matches.where((m) => m.status.name == 'live').length;
        print('$t  datos: ${matches.length} partidos ($live en vivo), '
            'tabla líder: ${leaderboard.isEmpty ? '-' : leaderboard.first.displayName} '
            '${leaderboard.isEmpty ? '' : leaderboard.first.totalPoints}pts');
    }
  });

  await Future<void>.delayed(Duration(seconds: seconds));
  await subscription.cancel();
  socket.dispose();
}
