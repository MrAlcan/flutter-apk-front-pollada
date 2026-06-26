import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../widgets/day_view.dart';

/// Detalle de una jornada abierta desde la lista de jornadas.
class DayDetailScreen extends ConsumerWidget {
  const DayDetailScreen({super.key, required this.day});

  /// Fecha en formato API (`2026-06-11`).
  final String day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jornada'),
        backgroundColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dayDetailProvider(day));
          ref.invalidate(dayPredictionsProvider(day));
          ref.invalidate(dayResultsProvider(day));
        },
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [DayView(day: day)],
        ),
      ),
    );
  }
}
