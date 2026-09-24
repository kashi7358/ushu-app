import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/get_product_by_id_usecase.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/utils/custom_popup.dart';
import '../../data/datasources/home_remote_data_source.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../../../core/errors/exception_handler.dart';
import '../../../../core/utils/browsing_history.dart';
import '../../data/models/product_model.dart';

class ProductDetailController extends GetxController {
  final Rx<ProductEntity?> product = Rx<ProductEntity?>(null);
  final RxBool isLoading = true.obs;
  final RxInt selectedImageIndex = 0.obs;
  final reviews = <dynamic>[].obs;

  late final GetProductByIdUseCase _getProductByIdUseCase;
  late final String productId;

  @override
  void onInit() {
    super.onInit();
    productId = Get.arguments as String;
    
    final apiClient = ApiClient();
    final remoteDataSource = HomeRemoteDataSourceImpl(apiClient);
    final repository = HomeRepositoryImpl(remoteDataSource);
    _getProductByIdUseCase = GetProductByIdUseCase(repository);
    
    fetchProductDetails();
    fetchReviews();
  }

  Future<void> fetchProductDetails() async {
    try {
      isLoading.value = true;
      final result = await _getProductByIdUseCase.execute(productId);
      product.value = result;
      selectedImageIndex.value = 0;
      
      // Save to browsing history
      if (result is ProductModel) {
        BrowsingHistory.addProduct(result);
      }
    } catch (e) {
      final error = ExceptionHandler.handle(e);
      Get.snackbar('Error', error.message, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchReviews() async {
    try {
      final apiClient = ApiClient();
      final response = await apiClient.dio.get(
        ApiEndpoints.getReviews(productId),
        options: Options(validateStatus: (status) => status != null && status < 500),
      );
      final data = response.data;
      if (data != null && data['success'] == true) {
        reviews.assignAll(data['reviews'] ?? []);
      }
    } catch (e) {
      debugPrint('Error fetching reviews: $e');
    }
  }

  Future<bool> voteReview(String reviewId, String vote) async {
    try {
      final apiClient = ApiClient();
      final response = await apiClient.dio.post(
        ApiEndpoints.voteReview(reviewId),
        data: {'vote': vote},
        options: Options(validateStatus: (status) => status != null && status < 500),
      );
      
      final data = response.data;
      if (data != null && data['success'] == true) {
        fetchReviews(); // Refresh review counts quietly
        CustomPopup.showFastLottie('assets/lotties/done.json');
        return true;
      } else {
        CustomPopup.showToast('Notice', data?['message'] ?? 'Could not submit vote');
        return false;
      }
    } catch (e) {
      debugPrint('Error voting review: $e');
      CustomPopup.showToast('Error', 'An error occurred while voting');
      return false;
    }
  }
}
