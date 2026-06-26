import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/datasources/live_socket_datasource.dart';
import '../providers.dart';
import '../widgets/day_view.dart';

/// Pestaña "Hoy": la jornada del día si hay partidos, con la opción de
/// participar mientras las apuestas estén abiertas. Se refresca en vivo
/// cuando el admin carga resultados (WebSocket).
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayAsync = ref.watch(todayProvider);
    final config = ref.watch(scoringConfigProvider).value;
    final liveStatus = ref.watch(liveStatusProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hoy'),
        backgroundColor: Colors.transparent,
        actions: [
          if (liveStatus != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(child: _LiveDot(status: liveStatus)),
            ),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dayDetailProvider);
          ref.invalidate(daysProvider);
          await ref.read(daysProvider.future);
        },
        child: todayAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 120),
                child: Center(
                  child: Column(
                    children: [
                      Text('$error',
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () => ref.invalidate(daysProvider),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          data: (today) => today == null
              ? ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 120),
                      child: Column(
                        children: [
                          const Icon(Icons.event_busy,
                              size: 56, color: AppColors.textSecondary),
                          const SizedBox(height: 12),
                          Text(
                            'Hoy no hay partidos',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Revisa Jornadas para ver días pasados y próximos',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : ListView(
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    if (config != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                        child: Text(
                          'Resultado: ${config.pointsOutcome} pt · '
                          'Marcador exacto: ${config.pointsExact} pts',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontSize: 12),
                        ),
                      ),
                    DayView(day: today.day),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Punto de estado de la conexión en vivo.
class _LiveDot extends StatelessWidget {
  const _LiveDot({required this.status});

  final LiveConnectionStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      LiveConnectionStatus.connected => (AppColors.primary, 'En vivo'),
      LiveConnectionStatus.connecting => (AppColors.secondary, 'Conectando'),
      LiveConnectionStatus.reconnecting =>
        (AppColors.error, 'Reconectando'),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(color: color, fontSize: 11.5),
        ),
      ],
    );
  }
}
