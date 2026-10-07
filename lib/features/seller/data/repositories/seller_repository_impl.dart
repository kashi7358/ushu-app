import '../../domain/repositories/seller_repository.dart';
import '../datasources/seller_remote_data_source.dart';
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
}
