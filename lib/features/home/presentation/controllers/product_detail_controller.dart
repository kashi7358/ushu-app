import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/get_product_by_id_usecase.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/utils/custom_popup.dart';
import '../../../../core/utils/session_manager.dart';
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
    final args = Get.arguments;
    if (args is Map) {
      productId = args['id']?.toString() ?? args['productId']?.toString() ?? '';
    } else {
      productId = args?.toString() ?? '';
    }
    
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
      if (data != null) {
        final List list = data['reviews'] ?? data['data'] ?? (data is List ? data : []);
        reviews.assignAll(list);
      }
    } catch (e) {
      debugPrint('Error fetching reviews: $e');
    }
  }

  Future<bool> voteReview(String reviewId, String vote, {int? reviewIndex}) async {
    if (reviewId.isEmpty) return false;
    if (!SessionManager.isLoggedIn) {
      CustomPopup.showLoginRequired();
      return false;
    }
    try {
      final apiClient = ApiClient();
      final String voteType = (vote == 'up' || vote == 'helpful' || vote == 'good') ? 'helpful' : 'unhelpful';

      final response = await apiClient.dio.post(
        ApiEndpoints.voteReview(reviewId),
        data: {
          'vote': voteType,
          'type': voteType,
          'voteType': voteType,
          'action': voteType,
        },
        options: Options(validateStatus: (status) => status != null && status < 500),
      );
      
      final data = response.data;
      final isSuccess = response.statusCode == 200 || 
          response.statusCode == 201 || 
          (data != null && (data['success'] == true || data['sucess'] == true || (data['message'] != null && data['message'].toString().toLowerCase().contains('voted'))));

      if (isSuccess) {
        if (reviewIndex != null && reviewIndex >= 0 && reviewIndex < reviews.length) {
          final Map<String, dynamic> item = Map<String, dynamic>.from(reviews[reviewIndex] as Map);
          final resData = data is Map ? (data['data'] ?? data['result'] ?? data) : null;

          if (resData is Map) {
            final hVotes = resData['helpfulVotes'] ?? resData['helpfull votes'] ?? resData['helpful'] ?? resData['upvotes'];
            final unhVotes = resData['unhelpfulVotes'] ?? resData['unhelpfullVote'] ?? resData['unhelpful'] ?? resData['downvotes'];

            if (hVotes != null) {
              item['helpfulVotes'] = hVotes;
              item['upvotes'] = hVotes;
            }
            if (unhVotes != null) {
              item['unhelpfulVotes'] = unhVotes;
              item['downvotes'] = unhVotes;
            }
          } else {
            if (voteType == 'helpful') {
              final int curr = (item['helpfulVotes'] ?? item['upvotes'] ?? item['helpful'] ?? 0) as int;
              item['helpfulVotes'] = curr + 1;
              item['upvotes'] = curr + 1;
            } else {
              final int curr = (item['unhelpfulVotes'] ?? item['downvotes'] ?? item['unhelpful'] ?? 0) as int;
              item['unhelpfulVotes'] = curr + 1;
              item['downvotes'] = curr + 1;
            }
          }
          reviews[reviewIndex] = item;
          reviews.refresh();
        }

        await fetchReviews();
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }
        CustomPopup.showToast('Thank you!', (data is Map && data['message'] != null) ? data['message'] : 'Your feedback has been recorded.');
        return true;
      } else {
        final msg = data is Map ? (data['message'] ?? 'Could not submit vote') : 'Could not submit vote';
        CustomPopup.showToast('Notice', msg.toString());
        return false;
      }
    } catch (e) {
      debugPrint('Error voting review: $e');
      CustomPopup.showToast('Error', 'An error occurred while voting');
      return false;
    }
  }
}
