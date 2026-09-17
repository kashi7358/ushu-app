import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/auth_user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthUserModel> login(String identifier, String password);
  Future<AuthUserModel> register({
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

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl(this.apiClient);

  @override
  Future<AuthUserModel> login(String identifier, String password) async {
    final response = await apiClient.dio.post(
      ApiEndpoints.loginBuyer,
      data: {
        "Email": identifier,
        "Password": password,
      },
    );
    
    final data = response.data;
    String? rootToken;
    if (data is Map<String, dynamic> && data['token'] != null) {
      rootToken = data['token'];
    }

    if (data is Map<String, dynamic> && data['data'] != null) {
        return AuthUserModel.fromJson(data['data'], extraToken: rootToken);
    } else if (data is Map<String, dynamic> && data['buyer'] != null) {
        return AuthUserModel.fromJson(data['buyer'], extraToken: rootToken);
    }
    return AuthUserModel.fromJson(data, extraToken: rootToken);
  }

  @override
  Future<AuthUserModel> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    required String address,
    required String role,
  }) async {
    final response = await apiClient.dio.post(
      ApiEndpoints.registerBuyer,
      data: {
        "FullName": fullName,
        "Email": email,
        "Phone": phone,
        "Password": password,
        "ConfirmPassword": confirmPassword,
        "Role": role,
        "address": address
      }
    );
    
    final data = response.data;
    String? rootToken;
    if (data is Map<String, dynamic> && data['token'] != null) {
      rootToken = data['token'];
    }

    if (data is Map<String, dynamic> && data['data'] != null) {
        return AuthUserModel.fromJson(data['data'], extraToken: rootToken);
    } else if (data is Map<String, dynamic> && data['buyer'] != null) {
        return AuthUserModel.fromJson(data['buyer'], extraToken: rootToken);
    }
    return AuthUserModel.fromJson(data, extraToken: rootToken);
  }

  @override
  Future<void> verifyEmail({required String buyerId, required String otp}) async {
    await apiClient.dio.post(
      ApiEndpoints.verifyEmail,
      data: {
        "buyerId": buyerId,
        "otp": otp,
      }
    );
  }

  @override
  Future<void> resendOtp({required String buyerId}) async {
    await apiClient.dio.post(
      ApiEndpoints.resendOtp,
      data: {
        "buyerId": buyerId,
      }
    );
  }

  @override
  Future<void> forgetPassword({required String email}) async {
    await apiClient.dio.post(
      ApiEndpoints.forgetPassword,
      data: {
        "Email": email,
      }
    );
  }

  @override
  Future<void> resetPassword({required String token, required String newPassword}) async {
    await apiClient.dio.post(
      ApiEndpoints.resetPassword,
      data: {
        "token": token,
        "newPassword": newPassword,
      }
    );
  }
}
