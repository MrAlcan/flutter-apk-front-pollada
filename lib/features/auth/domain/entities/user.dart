/// Entidad de dominio: usuario autenticado.
class User {
  const User({required this.id, required this.email, required this.createdAt});

  final int id;
  final String email;
  final DateTime createdAt;
}
