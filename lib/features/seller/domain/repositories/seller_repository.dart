import 'package:dio/dio.dart';
import '../../data/models/create_banner_request_model.dart';
import '../../data/models/update_banner_request_model.dart';
import '../../data/models/create_flash_sale_request_model.dart';
import '../../data/models/create_product_request_model.dart';
import '../../data/models/create_store_request_model.dart';
import '../../data/models/seller_registration_model.dart';

abstract class SellerRepository {
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
}
