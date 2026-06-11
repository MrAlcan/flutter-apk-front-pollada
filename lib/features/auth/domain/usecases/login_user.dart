import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUser {
  const LoginUser(this._repository);

  final AuthRepository _repository;

  Future<User> call({required String email, required String password}) =>
      _repository.login(email: email, password: password);
}
