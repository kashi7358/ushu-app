import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/utils/session_manager.dart';
import '../../../../core/utils/custom_popup.dart';
import '../../../home/data/models/product_model.dart';
import 'package:flutter/material.dart';

class WishlistController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  
  // To keep track of heart icons globally across the app
  final RxList<String> wishlistedProductIds = <String>[].obs;
  
  // The actual products to display on the wishlist screen
  final RxList<ProductModel> wishlistProducts = <ProductModel>[].obs;
  
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (SessionManager.isLoggedIn) {
      fetchWishlist();
    }
  }

  Future<void> fetchWishlist({bool showLoading = true}) async {
    if (!SessionManager.isLoggedIn) return;
    
    try {
      if (showLoading) isLoading.value = true;
      final response = await _apiClient.dio.get(ApiEndpoints.getWishlist);
      
      if (response.data['success'] == true) {
        wishlistProducts.clear();
        wishlistedProductIds.clear();
        
        final List<dynamic> items = response.data['item']?['items'] ?? [];
        List<Future<ProductModel?>> fetchFutures = [];

        for (var item in items) {
          if (item is Map && item['productId'] != null) {
            final productData = item['productId'];
            if (productData is Map<String, dynamic>) {
              // Full product object populated by backend
              final product = ProductModel.fromJson(productData);
              wishlistProducts.add(product);
              wishlistedProductIds.add(product.id);
            } else if (productData is String) {
              // Only ID
              wishlistedProductIds.add(productData);
              
              // Add a future to fetch it concurrently
              fetchFutures.add((() async {
                try {
                  final prodRes = await _apiClient.dio.get(ApiEndpoints.singleProduct + productData);
                  if (prodRes.data['success'] == true && prodRes.data['product'] != null) {
                    return ProductModel.fromJson(prodRes.data['product']);
                  }
                } catch (e) {
                   debugPrint('Error fetching single product $productData: $e');
                }
                return null;
              })());
            }
          }
        }
        
        // Wait for all single product fetches to complete
        if (fetchFutures.isNotEmpty) {
          final fetchedProducts = await Future.wait(fetchFutures);
          for (var p in fetchedProducts) {
            if (p != null) {
              wishlistProducts.add(p);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching wishlist: $e');
    } finally {
      if (showLoading) isLoading.value = false;
    }
  }

  Future<void> toggleWishlist(String productId) async {
    if (!SessionManager.isLoggedIn) {
      CustomPopup.showError('Error', 'Please login to add items to wishlist');
      return;
    }

    final isAlreadyWishlisted = wishlistedProductIds.contains(productId);

    // Optimistic UI update
    if (isAlreadyWishlisted) {
      wishlistedProductIds.remove(productId);
      wishlistProducts.removeWhere((p) => p.id == productId);
      CustomPopup.showFastLottie('assets/lotties/done.json');
    } else {
      wishlistedProductIds.add(productId);
      CustomPopup.showFastLottie('assets/lotties/done.json');
    }

    try {
      if (isAlreadyWishlisted) {
        final response = await _apiClient.dio.delete(
          ApiEndpoints.removeWishlist(productId),
          data: {'productId': productId},
          options: Options(validateStatus: (status) => status != null && status < 500),
        );
        
        final isSuccess = (response.statusCode == 200 || response.statusCode == 404) ||
            (response.data is Map && response.data['success'] == true);
            
        if (!isSuccess) {
          // Revert optimistic removal
          wishlistedProductIds.add(productId);
        }
      } else {
        final response = await _apiClient.dio.post(
          ApiEndpoints.addWishlist,
          data: {'productId': productId},
          options: Options(validateStatus: (status) => status != null && status < 500),
        );
        
        if (response.data is Map && response.data['success'] == false) {
          wishlistedProductIds.remove(productId);
        } else {
          fetchWishlist(showLoading: false); // Fetch quietly in background
        }
      }
    } catch (e) {
      // Revert optimistic update on error
      if (isAlreadyWishlisted) {
        wishlistedProductIds.add(productId);
      } else {
        wishlistedProductIds.remove(productId);
      }
      debugPrint('Wishlist Error: $e');
    }
  }

  bool isFavorite(String productId) {
    return wishlistedProductIds.contains(productId);
  }
}
