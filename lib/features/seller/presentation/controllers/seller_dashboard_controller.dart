import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/errors/exception_handler.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/session_manager.dart';
import '../../data/datasources/seller_remote_data_source.dart';
import '../../data/models/seller_dashboard_stats_model.dart';
import '../../data/repositories/seller_repository_impl.dart';
import '../../domain/repositories/seller_repository.dart';

class SellerDashboardController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final Rx<SellerDashboardStatsModel> stats = const SellerDashboardStatsModel().obs;
  final RxString storeName = ''.obs;
  final RxString sellerName = ''.obs;
  final RxString sellerEmail = ''.obs;

  late final SellerRepository _repository;

  @override
  void onInit() {
    super.onInit();
    final apiClient = ApiClient();
    final remoteDataSource = SellerRemoteDataSourceImpl(apiClient);
    _repository = SellerRepositoryImpl(remoteDataSource);

    // Initial load from session
    sellerName.value = SessionManager.sellerName ?? 'Seller';
    sellerEmail.value = SessionManager.sellerEmail ?? '';

    fetchDashboardStats();
  }

  Future<void> fetchDashboardStats() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _repository.getDashboardStats();

      if (response is Map<String, dynamic>) {
        final parsed = SellerDashboardStatsModel.fromJson(response);
        stats.value = parsed;

        if (parsed.storeName.isNotEmpty && parsed.storeName != 'My Store') {
          storeName.value = parsed.storeName;
        } else if (storeName.value.isEmpty) {
          storeName.value = 'Fashion Store';
        }

        if (parsed.sellerName.isNotEmpty) {
          sellerName.value = parsed.sellerName;
        }
        if (parsed.sellerEmail.isNotEmpty) {
          sellerEmail.value = parsed.sellerEmail;
        }
      }
    } catch (e) {
      final error = ExceptionHandler.handle(e);
      errorMessage.value = error.message;
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToAddProduct() {
    Get.toNamed(
      AppRoutes.sellerCreateProduct,
      arguments: {
        'storeId': SessionManager.sellerStoreId ?? '',
      },
    );
  }

  Future<void> logout() async {
    await SessionManager.clearSellerSession();
    Get.offAllNamed(AppRoutes.sellerLogin);
  }
}
