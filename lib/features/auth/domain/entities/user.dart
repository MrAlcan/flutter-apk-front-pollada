/// Entidad de dominio: usuario autenticado.
class User {
  const User({
    required this.id,
    required this.email,
    required this.displayName,
    required this.createdAt,
    this.isAdmin = false,
  });

  final int id;
  final String email;
  final String displayName;
  final DateTime createdAt;

  /// True para el usuario administrador (carga resultados desde la app).
  final bool isAdmin;
}
