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
  Future<dynamic> getDashboardStats();
}
