import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../../domain/repositories/live_repository.dart';
import '../models/live_models.dart';

/// Cliente del WebSocket /ws/live con reconexión automática.
///
/// Si el servidor se cae o la red se corta, reintenta con backoff
/// exponencial (1, 2, 4, 8… hasta 15 s) y emite el estado de conexión
/// para que la interfaz pueda informarlo. Cada conexión nueva recibe un
/// snapshot completo del backend, así que no se pierde estado.
class LiveSocketDataSource {
  LiveSocketDataSource(this._url);

  final String _url;
  final _events = StreamController<LiveEvent>.broadcast();

  WebSocketChannel? _channel;
  bool _disposed = false;
  bool _started = false;
  int _attempts = 0;

  Stream<LiveEvent> get events {
    _start();
    return _events.stream;
  }

  void _start() {
    if (_started) return;
    _started = true;
    unawaited(_connectLoop());
  }

  Future<void> _connectLoop() async {
    while (!_disposed) {
      _emitStatus(
        _attempts == 0
            ? LiveConnectionStatus.connecting
            : LiveConnectionStatus.reconnecting,
      );
      try {
        final channel = WebSocketChannel.connect(Uri.parse(_url));
        await channel.ready;
        _channel = channel;
        _attempts = 0;
        _emitStatus(LiveConnectionStatus.connected);
        await for (final raw in channel.stream) {
          _handleMessage(raw);
        }
        // Stream cerrado por el servidor: se reintenta abajo.
      } catch (_) {
        // Conexión fallida o interrumpida: se reintenta abajo.
      }
      _channel = null;
      if (_disposed) return;
      _attempts++;
      final seconds = (1 << (_attempts - 1)).clamp(1, 15);
      await Future<void>.delayed(Duration(seconds: seconds));
    }
  }

  void _handleMessage(dynamic raw) {
    final json = jsonDecode(raw as String) as Map<String, dynamic>;
    if (json['type'] == 'ping') return;
    _events.add(
      LiveDataEvent(
        matches: [
          for (final item in json['matches'] as List<dynamic>)
            matchFromJson(item as Map<String, dynamic>),
        ],
        leaderboard: [
          for (final item in json['leaderboard'] as List<dynamic>)
            leaderboardEntryFromJson(item as Map<String, dynamic>),
        ],
      ),
    );
  }

  void _emitStatus(LiveConnectionStatus status) {
    if (!_events.isClosed) _events.add(LiveStatusEvent(status));
  }

  void dispose() {
    _disposed = true;
    _channel?.sink.close();
    _events.close();
  }
}
