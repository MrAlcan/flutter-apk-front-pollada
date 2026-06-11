/// Configuración global de la app.
abstract final class AppConfig {
  /// URL base de la API. En el emulador de Android, `10.0.2.2` apunta al
  /// localhost de la máquina anfitriona. Sobreescribible en compilación:
  /// `flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000`
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  static const String wsLiveUrl = String.fromEnvironment(
    'WS_LIVE_URL',
    defaultValue: 'ws://10.0.2.2:8000/ws/live',
  );
}
