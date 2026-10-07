import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/create_store_request_model.dart';
import '../models/seller_registration_model.dart';

abstract class SellerRemoteDataSource {
  Future<dynamic> registerSeller(SellerRegistrationModel model);
  Future<dynamic> verifySellerEmail({required String sellerId, required String otp});
  Future<dynamic> resendSellerOtp({required String sellerId});
  Future<dynamic> loginSeller(String email, String password);
  Future<dynamic> forgetPassword(String email);
  Future<dynamic> createStore(CreateStoreRequestModel model);
}

class SellerRemoteDataSourceImpl implements SellerRemoteDataSource {
  final ApiClient apiClient;

  SellerRemoteDataSourceImpl(this.apiClient);

  @override
  Future<dynamic> registerSeller(SellerRegistrationModel model) async {
    final formData = await model.toFormData();

    final response = await apiClient.dio.post(
      ApiEndpoints.createSeller,
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      ),
    );

    return response.data;
  }

  @override
  Future<dynamic> verifySellerEmail({required String sellerId, required String otp}) async {
    final response = await apiClient.dio.post(
      ApiEndpoints.verifySellerEmail,
      data: {
        'sellerId': sellerId,
        'otp': otp,
      },
    );

    return response.data;
  }

  @override
  Future<dynamic> resendSellerOtp({required String sellerId}) async {
    final response = await apiClient.dio.post(
      ApiEndpoints.resendSellerOtp,
      data: {
        'sellerId': sellerId,
      },
    );

    return response.data;
  }

  @override
  Future<dynamic> loginSeller(String email, String password) async {
    final response = await apiClient.dio.post(
      ApiEndpoints.loginSeller,
      data: {
        'Email': email,
        'Password': password,
      },
    );

    return response.data;
  }

  @override
  Future<dynamic> forgetPassword(String email) async {
    final response = await apiClient.dio.post(
      ApiEndpoints.sellerForgetPassword,
      data: {
        'Email': email,
      },
    );

    return response.data;
  }

  @override
  Future<dynamic> createStore(CreateStoreRequestModel model) async {
    final formData = await model.toFormData();

    final response = await apiClient.dio.post(
      ApiEndpoints.createStore,
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      ),
    );

    return response.data;
  }
}
