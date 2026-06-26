/// Modo de visibilidad de las predicciones ajenas (switch del admin).
enum PredictionsVisibility {
  /// Apenas el usuario sella su pronóstico del día, ve los de los demás.
  afterSubmit('after_submit'),

  /// Las predicciones de cada partido se publican cuando ese partido
  /// finaliza (sin esperar al fin del día).
  afterMatch('after_match');

  const PredictionsVisibility(this.apiValue);

  final String apiValue;

  static PredictionsVisibility fromApi(String? value) =>
      PredictionsVisibility.values.firstWhere(
        (v) => v.apiValue == value,
        orElse: () => PredictionsVisibility.afterSubmit,
      );
}

/// Configuración global de la app expuesta en `GET /settings`.
class AppSettings {
  const AppSettings({required this.predictionsVisibility});

  final PredictionsVisibility predictionsVisibility;
}
