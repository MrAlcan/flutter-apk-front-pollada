import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_token_storage.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/register_user.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    AuthRemoteDataSource(ref.watch(dioProvider)),
    ref.watch(tokenStorageProvider),
  ),
);

final loginUserProvider =
    Provider<LoginUser>((ref) => LoginUser(ref.watch(authRepositoryProvider)));

final registerUserProvider = Provider<RegisterUser>(
  (ref) => RegisterUser(ref.watch(authRepositoryProvider)),
);

/// Estado global de sesión. `AsyncValue<User?>`:
///  * loading  -> restaurando sesión / autenticando
///  * data(null) -> sin sesión
///  * data(user) -> autenticado
///  * error    -> fallo de autenticación (mensaje en `AuthException`)
class AuthController extends AsyncNotifier<User?> {
  @override
  Future<User?> build() =>
      ref.read(authRepositoryProvider).restoreSession();

  Future<bool> login(String email, String password) =>
      _run(() => ref.read(loginUserProvider)(email: email, password: password));

  Future<bool> register(String email, String password,
          {String? displayName}) =>
      _run(() => ref.read(registerUserProvider)(
          email: email, password: password, displayName: displayName));

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }

  Future<bool> _run(Future<User> Function() action) async {
    state = const AsyncLoading();
    try {
      final user = await action();
      state = AsyncData(user);
      return true;
    } on AuthException catch (e, stack) {
      state = AsyncError(e, stack);
      return false;
    }
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, User?>(AuthController.new);
