import '../../domain/entities/user.dart';

/// Modelo de datos: mapea el JSON de la API a la entidad de dominio.
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as int,
        email: json['email'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
