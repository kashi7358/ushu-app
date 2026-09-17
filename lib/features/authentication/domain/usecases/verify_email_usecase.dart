import '../repositories/auth_repository.dart';

class VerifyEmailUseCase {
  final AuthRepository repository;

  VerifyEmailUseCase(this.repository);

  Future<void> execute(String buyerId, String otp) async {
    return await repository.verifyEmail(buyerId: buyerId, otp: otp);
  }
}
