import 'package:dio/dio.dart';

import '../models/user_model.dart';

/// Acceso directo a los endpoints de autenticación del backend FastAPI.
class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<UserModel> register(String email, String password) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/register',
      data: {'email': email, 'password': password},
    );
    return UserModel.fromJson(response.data!);
  }

  /// Devuelve el token JWT. El endpoint usa formulario OAuth2,
  /// donde `username` transporta el email.
  Future<String> login(String email, String password) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'username': email, 'password': password},
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    return response.data!['access_token'] as String;
  }

  Future<UserModel> me() async {
    final response = await _dio.get<Map<String, dynamic>>('/auth/me');
    return UserModel.fromJson(response.data!);
  }
}
