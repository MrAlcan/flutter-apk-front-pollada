import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/stadium_scaffold.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // Controlador externo: dispara el shake sin reconstruir el formulario
  // (cambiar la key destruiría el estado y borraría los errores visibles).
  late final AnimationController _shakeController =
      AnimationController(vsync: this);

  @override
  void dispose() {
    _shakeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      _shakeController.forward(from: 0);
      return;
    }
    final ok = await ref.read(authControllerProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text,
        );
    if (!ok && mounted) {
      _shakeController.forward(from: 0);
      final error = ref.read(authControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error?.toString() ?? 'Error de autenticación')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final textTheme = Theme.of(context).textTheme;

    return StadiumScaffold(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Marca
                Icon(Icons.sports_soccer, size: 64, color: AppColors.primary)
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: -0.3, curve: Curves.easeOutCubic),
                const SizedBox(height: 16),
                Text(
                  'Mundial Polla',
                  textAlign: TextAlign.center,
                  style: textTheme.displayLarge,
                ).animate().fadeIn(delay: 120.ms, duration: 500.ms),
                const SizedBox(height: 8),
                Text(
                  'Predice. Compite. Celebra.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium,
                ).animate().fadeIn(delay: 240.ms, duration: 500.ms),
                const SizedBox(height: 44),

                // Formulario (tiembla si hay error)
                Animate(
                  controller: _shakeController,
                  autoPlay: false,
                  effects: [ShakeEffect(duration: 400.ms, hz: 5)],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AuthTextField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.alternate_email,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        controller: _passwordController,
                        label: 'Contraseña',
                        icon: Icons.lock_outline,
                        obscure: true,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                        validator: _validatePassword,
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: 360.ms, duration: 500.ms)
                    .slideY(begin: 0.15, curve: Curves.easeOutCubic),
                const SizedBox(height: 28),

                // Botón con estado de carga animado
                FilledButton(
                  onPressed: auth.isLoading ? null : _submit,
                  child: AnimatedSwitcher(
                    duration: 250.ms,
                    child: auth.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.onPrimary,
                            ),
                          )
                        : const Text('Entrar al estadio'),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 480.ms, duration: 500.ms)
                    .slideY(begin: 0.2, curve: Curves.easeOutCubic),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('¿Aún no juegas?', style: textTheme.bodyMedium),
                    TextButton(
                      onPressed: () => context.push('/register'),
                      child: const Text('Crea tu cuenta'),
                    ),
                  ],
                ).animate().fadeIn(delay: 600.ms, duration: 500.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String? _validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'Escribe tu email';
  final pattern = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
  if (!pattern.hasMatch(email)) return 'Ese email no parece válido';
  return null;
}

String? _validatePassword(String? value) {
  if (value == null || value.isEmpty) return 'Escribe tu contraseña';
  if (value.length < 8) return 'Mínimo 8 caracteres';
  return null;
}
