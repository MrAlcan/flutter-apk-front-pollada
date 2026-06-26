import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/pools/presentation/screens/dashboard_shell.dart';
import '../../features/pools/presentation/screens/day_detail_screen.dart';
import '../../features/pools/presentation/screens/participation_screen.dart';
import '../theme/app_colors.dart';

/// Pantalla de carga mientras se restaura la sesión guardada.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.stadiumGradient),
        child: Center(
          child: Image.asset(
            'assets/icon/icon_foreground.png',
            width: 160,
            height: 160,
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                duration: 700.ms,
                begin: const Offset(1, 1),
                end: const Offset(1.12, 1.12),
                curve: Curves.easeInOut,
              )
              .fade(begin: 0.7, end: 1),
        ),
      ),
    );
  }
}

/// Transición suave compartida: fundido + deslizamiento ascendente.
CustomTransitionPage<void> _fadeSlidePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved =
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  // Notifica al router cada cambio de sesión para reevaluar `redirect`.
  final refresh = ValueNotifier(0);
  ref
    ..onDispose(refresh.dispose)
    ..listen(authControllerProvider, (_, _) => refresh.value++);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final loggedIn = auth.value != null;
      final atAuthScreen = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (auth.isLoading) {
        // Restauración inicial: muestra splash. Si el usuario ya está en
        // login/registro (envío en curso), no se le mueve de pantalla.
        return atAuthScreen ? null : '/splash';
      }
      if (loggedIn) {
        return atAuthScreen || state.matchedLocation == '/splash' ? '/' : null;
      }
      return atAuthScreen ? null : '/login';
    },
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const SplashScreen()),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const LoginScreen()),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const RegisterScreen()),
      ),
      GoRoute(
        path: '/',
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const DashboardShell()),
      ),
      GoRoute(
        path: '/day/:day',
        pageBuilder: (context, state) => _fadeSlidePage(
          state,
          DayDetailScreen(day: state.pathParameters['day']!),
        ),
      ),
      GoRoute(
        path: '/participate/:day',
        pageBuilder: (context, state) => _fadeSlidePage(
          state,
          ParticipationScreen(day: state.pathParameters['day']!),
        ),
      ),
    ],
  );
});
