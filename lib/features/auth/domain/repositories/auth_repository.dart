import '../entities/user.dart';

/// Contrato del repositorio de autenticación (la capa de datos lo implementa).
abstract interface class AuthRepository {
  /// Registra al usuario y deja la sesión iniciada (token guardado).
  Future<User> register({required String email, required String password});

  /// Inicia sesión y persiste el token JWT de forma segura.
  Future<User> login({required String email, required String password});

  /// Recupera el perfil con el token guardado; null si no hay sesión válida.
  Future<User?> restoreSession();

  /// Cierra la sesión y borra el token.
  Future<void> logout();
}

/// Error de dominio con mensaje listo para mostrar al usuario.
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
