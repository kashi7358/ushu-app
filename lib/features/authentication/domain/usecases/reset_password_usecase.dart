import '../repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<void> execute(String token, String newPassword) async {
    return await repository.resetPassword(token: token, newPassword: newPassword);
  }
}
