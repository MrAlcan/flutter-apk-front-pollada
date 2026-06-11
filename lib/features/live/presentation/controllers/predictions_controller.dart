import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/prediction.dart';
import '../../domain/repositories/live_repository.dart';
import 'live_feed_controller.dart';

/// Pronósticos del usuario indexados por id de partido.
class PredictionsController extends AsyncNotifier<Map<int, Prediction>> {
  @override
  Future<Map<int, Prediction>> build() async {
    final predictions =
        await ref.watch(liveRepositoryProvider).fetchMyPredictions();
    return {for (final p in predictions) p.matchId: p};
  }

  /// Guarda el pronóstico. Devuelve null si todo fue bien, o el mensaje
  /// de error para mostrarlo en la interfaz.
  Future<String?> save({
    required int matchId,
    required int predictedHome,
    required int predictedAway,
  }) async {
    try {
      final saved = await ref.read(liveRepositoryProvider).savePrediction(
            matchId: matchId,
            predictedHome: predictedHome,
            predictedAway: predictedAway,
          );
      state = AsyncData({...state.value ?? {}, saved.matchId: saved});
      return null;
    } on LiveException catch (e) {
      return e.message;
    }
  }
}

final predictionsProvider =
    AsyncNotifierProvider<PredictionsController, Map<int, Prediction>>(
  PredictionsController.new,
);
