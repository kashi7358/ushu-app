import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/create_banner_request_model.dart';
import '../models/update_banner_request_model.dart';
import '../models/create_flash_sale_request_model.dart';
import '../models/create_product_request_model.dart';
import '../models/create_store_request_model.dart';
import '../models/seller_registration_model.dart';

abstract class SellerRemoteDataSource {
  Future<dynamic> registerSeller(SellerRegistrationModel model);
  Future<dynamic> verifySellerEmail({required String sellerId, required String otp});
  Future<dynamic> resendSellerOtp({required String sellerId});
  Future<dynamic> loginSeller(String email, String password);
  Future<dynamic> forgetPassword(String email);
  Future<dynamic> createStore(CreateStoreRequestModel model);
  Future<dynamic> createProduct({required String storeId, required CreateProductRequestModel model});
  Future<dynamic> updateProduct({required String productId, required FormData formData});
  Future<dynamic> getProductsByStore(String storeId);
  Future<dynamic> deleteProduct(String productId);
  Future<dynamic> getDashboardStats([String? token]);
  Future<dynamic> getMyStore([String? token]);
  Future<dynamic> createFlashSale(CreateFlashSaleRequestModel model);
  Future<dynamic> getAllFlashSales();
  Future<dynamic> updateFlashSale({required String id, required CreateFlashSaleRequestModel model});
  Future<dynamic> deleteFlashSale(String id);
  Future<dynamic> getSellerOrders();
  Future<dynamic> getSellerPromotions();
  Future<dynamic> createBanner(CreateBannerRequestModel model);
  Future<dynamic> updateSellerBanner({required String id, required UpdateBannerRequestModel model});
  Future<dynamic> generateProductFromImage({required String imagePath, required String storeId});
  Future<dynamic> getFinancialReport([String? token]);
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

  @override
  Future<dynamic> createProduct({required String storeId, required CreateProductRequestModel model}) async {
    final formData = await model.toFormData();

    final response = await apiClient.dio.post(
      ApiEndpoints.createProduct(storeId),
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
  Future<dynamic> getProductsByStore(String storeId) async {
    final response = await apiClient.dio.get(
      ApiEndpoints.getAllProductsByStore(storeId),
    );
    return response.data;
  }

  @override
  Future<dynamic> deleteProduct(String productId) async {
    final response = await apiClient.dio.delete(
      ApiEndpoints.deleteProduct(productId),
    );
    return response.data;
  }

  @override
  Future<dynamic> updateProduct({required String productId, required FormData formData}) async {
    final response = await apiClient.dio.patch(
      ApiEndpoints.updateProduct(productId),
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
  Future<dynamic> getDashboardStats([String? token]) async {
    final response = await apiClient.dio.get(
      ApiEndpoints.sellerDashboardStats,
      options: token != null && token.isNotEmpty
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null,
    );
    return response.data;
  }

  @override
  Future<dynamic> getMyStore([String? token]) async {
    final response = await apiClient.dio.get(
      ApiEndpoints.myStore,
      options: token != null && token.isNotEmpty
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null,
    );
    return response.data;
  }

  @override
  Future<dynamic> createFlashSale(CreateFlashSaleRequestModel model) async {
    final response = await apiClient.dio.post(
      ApiEndpoints.createFlashSale,
      data: model.toJson(),
    );
    return response.data;
  }

  @override
  Future<dynamic> getAllFlashSales() async {
    final response = await apiClient.dio.get(
      ApiEndpoints.getAllFlashSales,
    );
    return response.data;
  }

  @override
  Future<dynamic> updateFlashSale({required String id, required CreateFlashSaleRequestModel model}) async {
    final response = await apiClient.dio.put(
      ApiEndpoints.updateFlashSale(id),
      data: model.toJson(),
    );
    return response.data;
  }

  @override
  Future<dynamic> deleteFlashSale(String id) async {
    final response = await apiClient.dio.delete(
      ApiEndpoints.deleteFlashSale(id),
    );
    return response.data;
  }

  @override
  Future<dynamic> getSellerOrders() async {
    final response = await apiClient.dio.get(
      ApiEndpoints.sellerOrders,
    );
    return response.data;
  }

  @override
  Future<dynamic> getSellerPromotions() async {
    final response = await apiClient.dio.get(
      ApiEndpoints.sellerPromotions,
    );
    return response.data;
  }

  @override
  Future<dynamic> createBanner(CreateBannerRequestModel model) async {
    final formData = await model.toFormData();
    final response = await apiClient.dio.post(
      ApiEndpoints.createBanner,
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
  Future<dynamic> updateSellerBanner({required String id, required UpdateBannerRequestModel model}) async {
    final formData = await model.toFormData();
    final response = await apiClient.dio.patch(
      ApiEndpoints.updateSellerBanner(id),
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
  Future<dynamic> generateProductFromImage({required String imagePath, required String storeId}) async {
    final fileName = imagePath.split(RegExp(r'[/\\]')).last;
    final formData = FormData.fromMap({
      'productImage': await MultipartFile.fromFile(
        imagePath,
        filename: fileName.isNotEmpty ? fileName : 'product_image.jpg',
      ),
      'storeId': storeId,
    });

    final response = await apiClient.dio.post(
      ApiEndpoints.copilotGenerateFromImage,
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
  Future<dynamic> getFinancialReport([String? token]) async {
    final response = await apiClient.dio.get(
      ApiEndpoints.sellerFinancialReport,
      options: Options(
        headers: {
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ),
    );
    return response.data;
  }
}
