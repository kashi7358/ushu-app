import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<AuthUser> login(String identifier, String password) async {
    return await remoteDataSource.login(identifier, password);
  }

  @override
  Future<AuthUser> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    required String address,
    required String role,
  }) async {
    return await remoteDataSource.register(
      fullName: fullName,
      email: email,
      phone: phone,
      password: password,
      confirmPassword: confirmPassword,
      address: address,
      role: role,
    );
  }

  @override
  Future<void> verifyEmail({required String buyerId, required String otp}) async {
    await remoteDataSource.verifyEmail(buyerId: buyerId, otp: otp);
  }

  @override
  Future<void> resendOtp({required String buyerId}) async {
    await remoteDataSource.resendOtp(buyerId: buyerId);
  }

  @override
  Future<void> forgetPassword({required String email}) async {
    await remoteDataSource.forgetPassword(email: email);
  }

  @override
  Future<void> resetPassword({required String token, required String newPassword}) async {
    await remoteDataSource.resetPassword(token: token, newPassword: newPassword);
  }
}
