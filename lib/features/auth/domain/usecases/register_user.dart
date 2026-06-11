import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUser {
  const RegisterUser(this._repository);

  final AuthRepository _repository;

  Future<User> call({required String email, required String password}) =>
      _repository.register(email: email, password: password);
}
