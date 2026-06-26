import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../admin/presentation/screens/admin_screen.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../providers.dart';
import 'groups_screen.dart';
import 'history_screen.dart';
import 'leaderboard_screen.dart';
import 'today_screen.dart';

/// Pantalla principal con navegación inferior: Hoy, Jornadas, Grupos,
/// Tabla y, solo para el administrador, el panel de resultados.
class DashboardShell extends ConsumerStatefulWidget {
  const DashboardShell({super.key});

  @override
  ConsumerState<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends ConsumerState<DashboardShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    // Mantiene viva la sincronización en tiempo real (WebSocket).
    ref.watch(liveSyncProvider);
    final isAdmin = ref.watch(authControllerProvider).value?.isAdmin ?? false;

    final screens = [
      const TodayScreen(),
      const HistoryScreen(),
      const GroupsScreen(),
      const LeaderboardScreen(),
      if (isAdmin) const AdminScreen(),
    ];
    if (_index >= screens.length) _index = 0;

    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.18),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.sports_soccer_outlined),
            selectedIcon: Icon(Icons.sports_soccer, color: AppColors.primary),
            label: 'Hoy',
          ),
          const NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon:
                Icon(Icons.calendar_month, color: AppColors.primary),
            label: 'Jornadas',
          ),
          const NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view, color: AppColors.primary),
            label: 'Grupos',
          ),
          const NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events, color: AppColors.primary),
            label: 'Tabla',
          ),
          if (isAdmin)
            const NavigationDestination(
              icon: Icon(Icons.admin_panel_settings_outlined),
              selectedIcon:
                  Icon(Icons.admin_panel_settings, color: AppColors.primary),
              label: 'Admin',
            ),
        ],
      ),
    );
  }
}
