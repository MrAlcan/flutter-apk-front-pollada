import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

/// Estado de la conexión en tiempo real.
enum LiveConnectionStatus { connecting, connected, reconnecting }

/// Eventos del canal `/ws/live`.
sealed class LiveEvent {
  const LiveEvent();
}

class LiveStatusEvent extends LiveEvent {
  const LiveStatusEvent(this.status);

  final LiveConnectionStatus status;
}

/// Snapshot inicial o actualización tras un resultado del admin. La app
/// reacciona invalidando providers (la fuente de verdad sigue siendo REST).
class LiveUpdateEvent extends LiveEvent {
  const LiveUpdateEvent({required this.isSnapshot});

  final bool isSnapshot;
}

/// Cliente del WebSocket /ws/live con reconexión automática.
///
/// Si el servidor se cae o la red se corta, reintenta con backoff
/// exponencial (1, 2, 4, 8… hasta 15 s) y emite el estado de conexión
/// para que la interfaz pueda informarlo.
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
    switch (json['type']) {
      case 'ping':
        return; // keep-alive, se ignora
      case 'snapshot':
        _events.add(const LiveUpdateEvent(isSnapshot: true));
      case 'live_update':
        _events.add(const LiveUpdateEvent(isSnapshot: false));
    }
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
