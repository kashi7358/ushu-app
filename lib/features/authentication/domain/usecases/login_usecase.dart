import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<AuthUser> execute(String identifier, String password) async {
    return await repository.login(identifier, password);
  }
}
