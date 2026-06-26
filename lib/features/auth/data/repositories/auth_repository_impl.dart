import 'package:dio/dio.dart';

import '../../../../core/storage/secure_token_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote, this._tokenStorage);

  final AuthRemoteDataSource _remote;
  final SecureTokenStorage _tokenStorage;

  @override
  Future<User> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      await _remote.register(email, password, displayName);
      // Tras el registro, inicia sesión para obtener y guardar el token.
      return await login(email: email, password: password);
    } on DioException catch (e) {
      throw _toAuthException(e);
    }
  }

  @override
  Future<User> login({required String email, required String password}) async {
    try {
      final token = await _remote.login(email, password);
      await _tokenStorage.saveToken(token);
      return await _remote.me();
    } on DioException catch (e) {
      throw _toAuthException(e);
    }
  }

  @override
  Future<User?> restoreSession() async {
    final token = await _tokenStorage.readToken();
    if (token == null) return null;
    try {
      return await _remote.me();
    } on DioException {
      // Token expirado o backend inaccesible: sesión no restaurable.
      return null;
    }
  }

  @override
  Future<void> logout() => _tokenStorage.deleteToken();

  AuthException _toAuthException(DioException e) {
    final detail = switch (e.response?.data) {
      {'detail': final String message} => message,
      _ => null,
    };
    if (detail != null) return AuthException(detail);
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError =>
        const AuthException('No se pudo conectar con el servidor'),
      _ => const AuthException('Ocurrió un error inesperado'),
    };
  }
}
