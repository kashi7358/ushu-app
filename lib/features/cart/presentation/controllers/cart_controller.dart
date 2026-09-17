import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/utils/custom_popup.dart';

import '../../data/models/cart_item_model.dart';

class CartController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  final RxBool isAddingToCart = false.obs;
  final RxBool isLoadingCart = false.obs;

  final RxList<CartItemModel> cartItems = <CartItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCart();
  }

  num get subtotal {
    num total = 0;
    for (var item in cartItems) {
      if (item.isSelected) {
        total += item.price * item.quantity;
      }
    }
    return total;
  }

  Future<void> addToCart(String productId, int quantity, String productName) async {
    try {
      isAddingToCart.value = true;
      final response = await _apiClient.dio.post(
        ApiEndpoints.addToCart,
        data: {
          "productId": productId,
          "quantity": quantity
        },
        options: Options(validateStatus: (status) => true),
      );
      
      final data = response.data;
      if (data['success'] == true) {
        _updateCartItems(data);
        Get.snackbar(
          'Added to Cart',
          '$productName is in your cart.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.black.withValues(alpha: 0.8),
          colorText: Colors.white,
          borderRadius: 16,
          margin: const EdgeInsets.all(16),
          icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
          duration: const Duration(seconds: 2),
          animationDuration: const Duration(milliseconds: 400),
          forwardAnimationCurve: Curves.easeOutBack,
        );
      } else {
        CustomPopup.showError('Failed', data['message'] ?? 'Could not add to cart');
      }
    } catch (e) {
      CustomPopup.showError('Error', 'An error occurred while adding to cart.');
    } finally {
      isAddingToCart.value = false;
    }
  }

  Future<void> fetchCart() async {
    try {
      isLoadingCart.value = true;
      final response = await _apiClient.dio.get(
        ApiEndpoints.getCart,
        options: Options(validateStatus: (status) => true),
      );
      
      final data = response.data;
      if (data != null && data['success'] == true) {
        _updateCartItems(data);
      }
    } catch (e) {
      print('Error fetching cart: $e');
    } finally {
      isLoadingCart.value = false;
    }
  }

  Future<void> removeFromCart(String itemId) async {
    try {
      final response = await _apiClient.dio.delete(
        ApiEndpoints.removeCartItem(itemId),
        options: Options(validateStatus: (status) => true),
      );
      
      final data = response.data;
      if (data != null && data['success'] == true) {
        _updateCartItems(data);
        CustomPopup.showSuccess('Removed', 'Item removed from cart.');
      } else {
        CustomPopup.showError('Failed', data['message'] ?? 'Could not remove item');
      }
    } catch (e) {
      CustomPopup.showError('Error', 'An error occurred while removing item.');
    }
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    try {
      final response = await _apiClient.dio.patch(
        ApiEndpoints.updateCartQuantity(itemId),
        data: {"quantity": quantity},
        options: Options(validateStatus: (status) => true),
      );
      
      final data = response.data;
      if (data != null && data['success'] == true) {
        _updateCartItems(data);
      } else {
        CustomPopup.showError('Failed', data['message'] ?? 'Could not update quantity');
      }
    } catch (e) {
      CustomPopup.showError('Error', 'An error occurred while updating quantity.');
    }
  }

  Future<void> selectCartItem(String itemId) async {
    try {
      final response = await _apiClient.dio.patch(
        ApiEndpoints.selectCartItem,
        data: {"itemId": itemId},
        options: Options(validateStatus: (status) => true),
      );
      
      final data = response.data;
      if (data != null && data['success'] == true) {
        _updateCartItems(data);
      }
    } catch (e) {
      print('Error selecting item: $e');
    }
  }

  void _updateCartItems(dynamic data) {
    if (data['data'] != null && data['data']['allItems'] != null) {
      cartItems.value = (data['data']['allItems'] as List)
          .map((e) => CartItemModel.fromJson(e))
          .toList();
    }
  }
}
