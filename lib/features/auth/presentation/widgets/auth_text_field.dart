import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';

/// Campo de formulario con validación visual interactiva: valida mientras
/// el usuario escribe y muestra un check animado cuando el valor es válido.
class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.validator = _noValidation,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?) validator;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final void Function(String)? onSubmitted;

  static String? _noValidation(String? _) => null;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscured = true;
  bool _valid = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_revalidate);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_revalidate);
    super.dispose();
  }

  void _revalidate() {
    final valid = widget.validator(widget.controller.text) == null &&
        widget.controller.text.isNotEmpty;
    if (valid != _valid) setState(() => _valid = valid);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      obscureText: widget.obscure && _obscured,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: Icon(widget.icon, size: 22),
        suffixIcon: widget.obscure
            ? IconButton(
                icon: Icon(
                  _obscured ? Icons.visibility_off : Icons.visibility,
                  size: 22,
                ),
                onPressed: () => setState(() => _obscured = !_obscured),
              )
            : _valid
                ? const Icon(Icons.check_circle,
                        color: AppColors.success, size: 22)
                    .animate()
                    .scale(
                      duration: 250.ms,
                      curve: Curves.easeOutBack,
                      begin: const Offset(0, 0),
                    )
                : null,
      ),
    );
  }
}
