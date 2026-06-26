import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/stadium_scaffold.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  // Controlador externo: dispara el shake sin reconstruir el formulario
  // (cambiar la key destruiría el estado y borraría los errores visibles).
  late final AnimationController _shakeController =
      AnimationController(vsync: this);

  @override
  void dispose() {
    _shakeController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      _shakeController.forward(from: 0);
      return;
    }
    final ok = await ref.read(authControllerProvider.notifier).register(
          _emailController.text.trim(),
          _passwordController.text,
          displayName: _nameController.text.trim(),
        );
    if (!ok && mounted) {
      _shakeController.forward(from: 0);
      final error = ref.read(authControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error?.toString() ?? 'No se pudo registrar')),
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios_new),
                  ),
                ).animate().fadeIn(duration: 400.ms),
                const SizedBox(height: 8),
                Text('Únete a la polla', style: textTheme.headlineMedium)
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .slideX(begin: -0.1, curve: Curves.easeOutCubic),
                const SizedBox(height: 8),
                Text(
                  'Crea tu cuenta y demuestra quién sabe de fútbol.',
                  style: textTheme.bodyMedium,
                ).animate().fadeIn(delay: 120.ms, duration: 500.ms),
                const SizedBox(height: 36),
                Animate(
                  controller: _shakeController,
                  autoPlay: false,
                  effects: [ShakeEffect(duration: 400.ms, hz: 5)],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AuthTextField(
                        controller: _nameController,
                        label: 'Nombre visible (opcional)',
                        icon: Icons.badge_outlined,
                        keyboardType: TextInputType.name,
                      ),
                      const SizedBox(height: 16),
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
                        label: 'Contraseña (mínimo 8 caracteres)',
                        icon: Icons.lock_outline,
                        obscure: true,
                        validator: _validatePassword,
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        controller: _confirmController,
                        label: 'Repite la contraseña',
                        icon: Icons.lock_reset,
                        obscure: true,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Repite tu contraseña';
                          }
                          if (value != _passwordController.text) {
                            return 'Las contraseñas no coinciden';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: 240.ms, duration: 500.ms)
                    .slideY(begin: 0.15, curve: Curves.easeOutCubic),
                const SizedBox(height: 28),
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
                        : const Text('Crear cuenta'),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 360.ms, duration: 500.ms)
                    .slideY(begin: 0.2, curve: Curves.easeOutCubic),
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
  if (value == null || value.isEmpty) return 'Elige una contraseña';
  if (value.length < 8) return 'Mínimo 8 caracteres';
  return null;
}
