import '../repositories/auth_repository.dart';

class ResendOtpUseCase {
  final AuthRepository repository;

  ResendOtpUseCase(this.repository);

  Future<void> execute(String buyerId) async {
    return await repository.resendOtp(buyerId: buyerId);
  }
}
