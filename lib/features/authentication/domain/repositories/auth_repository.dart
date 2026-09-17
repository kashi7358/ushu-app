import '../entities/auth_user.dart';

abstract class AuthRepository {
  Future<AuthUser> login(String identifier, String password);
  Future<AuthUser> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    required String address,
    required String role,
  });
  Future<void> verifyEmail({required String buyerId, required String otp});
  Future<void> resendOtp({required String buyerId});
  Future<void> forgetPassword({required String email});
  Future<void> resetPassword({required String token, required String newPassword});
}
