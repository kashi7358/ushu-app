import 'package:dio/dio.dart';
import '../../domain/repositories/seller_repository.dart';
import '../datasources/seller_remote_data_source.dart';
import '../models/create_banner_request_model.dart';
import '../models/update_banner_request_model.dart';
import '../models/create_flash_sale_request_model.dart';
import '../models/create_product_request_model.dart';
import '../models/create_store_request_model.dart';
import '../models/seller_registration_model.dart';

class SellerRepositoryImpl implements SellerRepository {
  final SellerRemoteDataSource remoteDataSource;

  SellerRepositoryImpl(this.remoteDataSource);

  @override
  Future<dynamic> registerSeller(SellerRegistrationModel model) {
    return remoteDataSource.registerSeller(model);
  }

  @override
  Future<dynamic> verifySellerEmail({required String sellerId, required String otp}) {
    return remoteDataSource.verifySellerEmail(sellerId: sellerId, otp: otp);
  }

  @override
  Future<dynamic> resendSellerOtp({required String sellerId}) {
    return remoteDataSource.resendSellerOtp(sellerId: sellerId);
  }

  @override
  Future<dynamic> loginSeller(String email, String password) {
    return remoteDataSource.loginSeller(email, password);
  }

  @override
  Future<dynamic> forgetPassword(String email) {
    return remoteDataSource.forgetPassword(email);
  }

  @override
  Future<dynamic> createStore(CreateStoreRequestModel model) {
    return remoteDataSource.createStore(model);
  }

  @override
  Future<dynamic> createProduct({required String storeId, required CreateProductRequestModel model}) {
    return remoteDataSource.createProduct(storeId: storeId, model: model);
  }

  @override
  Future<dynamic> updateProduct({required String productId, required FormData formData}) {
    return remoteDataSource.updateProduct(productId: productId, formData: formData);
  }

  @override
  Future<dynamic> getProductsByStore(String storeId) {
    return remoteDataSource.getProductsByStore(storeId);
  }

  @override
  Future<dynamic> deleteProduct(String productId) {
    return remoteDataSource.deleteProduct(productId);
  }

  @override
  Future<dynamic> getDashboardStats([String? token]) {
    return remoteDataSource.getDashboardStats(token);
  }

  @override
  Future<dynamic> getMyStore([String? token]) {
    return remoteDataSource.getMyStore(token);
  }

  @override
  Future<dynamic> createFlashSale(CreateFlashSaleRequestModel model) {
    return remoteDataSource.createFlashSale(model);
  }

  @override
  Future<dynamic> getAllFlashSales() {
    return remoteDataSource.getAllFlashSales();
  }

  @override
  Future<dynamic> updateFlashSale({required String id, required CreateFlashSaleRequestModel model}) {
    return remoteDataSource.updateFlashSale(id: id, model: model);
  }

  @override
  Future<dynamic> deleteFlashSale(String id) {
    return remoteDataSource.deleteFlashSale(id);
  }

  @override
  Future<dynamic> getSellerOrders() {
    return remoteDataSource.getSellerOrders();
  }

  @override
  Future<dynamic> getSellerDeliveredOrders([String? token]) {
    return remoteDataSource.getSellerDeliveredOrders(token);
  }

  @override
  Future<dynamic> getSellerRefundedOrders([String? token]) {
    return remoteDataSource.getSellerRefundedOrders(token);
  }

  @override
  Future<dynamic> getSellerPromotions() {
    return remoteDataSource.getSellerPromotions();
  }

  @override
  Future<dynamic> createBanner(CreateBannerRequestModel model) {
    return remoteDataSource.createBanner(model);
  }

  @override
  Future<dynamic> getAllBanners([String? token]) {
    return remoteDataSource.getAllBanners(token);
  }

  @override
  Future<dynamic> updateSellerBanner({required String id, required UpdateBannerRequestModel model}) {
    return remoteDataSource.updateSellerBanner(id: id, model: model);
  }

  @override
  Future<dynamic> generateProductFromImage({required String imagePath, required String storeId}) {
    return remoteDataSource.generateProductFromImage(imagePath: imagePath, storeId: storeId);
  }

  @override
  Future<dynamic> getFinancialReport([String? token]) {
    return remoteDataSource.getFinancialReport(token);
  }
}
