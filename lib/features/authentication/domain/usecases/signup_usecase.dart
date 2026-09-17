import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class SignupUseCase {
  final AuthRepository repository;

  SignupUseCase(this.repository);

  Future<AuthUser> execute({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    required String address,
  }) async {
    return await repository.register(
      fullName: fullName,
      email: email,
      phone: phone,
      password: password,
      confirmPassword: confirmPassword,
      address: address,
      role: 'Buyer',
    );
  }
}
