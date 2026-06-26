import '../../../pools/domain/entities/app_settings.dart';
import '../../../pools/domain/entities/match_info.dart';

/// Contrato del repositorio de administración. El backend valida el rol
/// (usuarios sin `is_admin` reciben 403).
abstract interface class AdminRepository {
  /// Actualiza el marcador **en vivo** (editable cuantas veces se quiera).
  /// No finaliza el partido, no puntúa ni mueve llaves; solo difunde el
  /// marcador por WebSocket. 409 si el partido ya fue finalizado.
  Future<MatchInfo> updateScore({
    required int matchId,
    required int homeScore,
    required int awayScore,
  });

  /// Cierra el partido de forma **irreversible** con el último marcador
  /// cargado: determina el ganador, puntúa predicciones, recalcula grupos
  /// y avanza llaves. En llaves con empate, [winnerTeamId] es obligatorio
  /// (ganador por penales). 409 si ya está finalizado o no hay marcador.
  Future<MatchInfo> finalizeMatch({required int matchId, int? winnerTeamId});

  /// Cambia el modo de visibilidad de las predicciones ajenas.
  Future<AppSettings> updateSettings(PredictionsVisibility visibility);
}

/// Error de dominio con mensaje listo para mostrar.
class AdminException implements Exception {
  const AdminException(this.message);

  final String message;

  @override
  String toString() => message;
}
