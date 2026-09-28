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
  final RxBool isNoInternet = false.obs;

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
    if (isAddingToCart.value) return;
    
    // Optimistic UI: Show animation immediately for best UX
    CustomPopup.showFastLottie('assets/lotties/add_to_cart_new.json');
    
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
      } else {
        CustomPopup.showToast('Failed', data['message'] ?? 'Could not add to cart', isError: true);
      }
    } catch (e) {
      CustomPopup.showToast('Error', 'An error occurred while adding to cart.', isError: true);
    } finally {
      isAddingToCart.value = false;
    }
  }

  Future<bool> buyNow(String productId, int quantity, String productName) async {
    if (isAddingToCart.value) return false;
    
    try {
      isAddingToCart.value = true;
      CustomPopup.showFastLottie('assets/lotties/add_to_cart_new.json');
      
      final response = await _apiClient.dio.post(
        ApiEndpoints.addToCart,
        data: {
          "productId": productId,
          "quantity": quantity
        },
        options: Options(validateStatus: (status) => true),
      );
      
      final data = response.data;
      if (data != null && data['success'] == true) {
        _updateCartItems(data);
        
        final index = cartItems.indexWhere((item) => item.productId == productId || item.id == productId);
        if (index != -1) {
          final targetItem = cartItems[index];
          if (!targetItem.isSelected) {
            cartItems[index] = targetItem.copyWith(isSelected: true);
            cartItems.refresh();
          }
          // Fire select call asynchronously so navigation is not blocked
          _apiClient.dio.patch(
            ApiEndpoints.selectCartItem,
            data: {"itemId": targetItem.id},
            options: Options(validateStatus: (status) => true),
          );
        }
        return true;
      } else {
        CustomPopup.showToast('Failed', data?['message'] ?? 'Could not process Buy Now', isError: true);
        return false;
      }
    } catch (e) {
      print('Error during Buy Now: $e');
      CustomPopup.showToast('Error', 'An error occurred during Buy Now', isError: true);
      return false;
    } finally {
      isAddingToCart.value = false;
    }
  }

  Future<void> fetchCart() async {
    try {
      isLoadingCart.value = true;
      isNoInternet.value = false;
      final response = await _apiClient.dio.get(
        ApiEndpoints.getCart,
        options: Options(validateStatus: (status) => true),
      );
      
      final data = response.data;
      if (data != null && data['success'] == true) {
        _updateCartItems(data);
      }
    } catch (e) {
      if (cartItems.isEmpty) {
        isNoInternet.value = true;
      }
      print('Error fetching cart: $e');
    } finally {
      isLoadingCart.value = false;
    }
  }

  Future<void> removeFromCart(String itemId) async {
    // Optimistic UI Update: immediately remove from UI & show lottie
    cartItems.removeWhere((item) => item.id == itemId);
    CustomPopup.showFastLottie('assets/lotties/done.json');

    try {
      final response = await _apiClient.dio.delete(
        ApiEndpoints.removeCartItem(itemId),
        options: Options(validateStatus: (status) => true),
      );
      
      final data = response.data;
      if (data != null && data['success'] == true) {
        _updateCartItems(data);
      } else {
        fetchCart(); // Revert on fail
        CustomPopup.showToast('Failed', data['message'] ?? 'Could not remove item', isError: true);
      }
    } catch (e) {
      fetchCart(); // Revert on fail
      CustomPopup.showToast('Error', 'An error occurred while removing item.', isError: true);
    }
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    // Optimistic UI Update
    final index = cartItems.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      final oldItem = cartItems[index];
      cartItems[index] = oldItem.copyWith(quantity: quantity);
      cartItems.refresh();
    }

    try {
      await _apiClient.dio.patch(
        ApiEndpoints.updateCartQuantity(itemId),
        data: {"quantity": quantity},
        options: Options(validateStatus: (status) => true),
      );
      // Fire and forget - DO NOT update from backend here to prevent bouncing UI
    } catch (e) {
      print('Error updating quantity: $e');
    }
  }

  Future<void> selectCartItem(String itemId) async {
    // Optimistic UI Update - We only rely on local state for selection to avoid race conditions
    final index = cartItems.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      final oldItem = cartItems[index];
      cartItems[index] = oldItem.copyWith(isSelected: !oldItem.isSelected);
      cartItems.refresh();
    }

    try {
      await _apiClient.dio.patch(
        ApiEndpoints.selectCartItem,
        data: {"itemId": itemId},
        options: Options(validateStatus: (status) => true),
      );
      // Removed _updateCartItems(data) here to prevent multiple-select race conditions from backend
    } catch (e) {
      print('Error selecting item: $e');
    }
  }

  Future<void> toggleSelectAll() async {
    bool areAllSelected = cartItems.isNotEmpty && cartItems.every((item) => item.isSelected);
    bool targetState = !areAllSelected;

    for (int i = 0; i < cartItems.length; i++) {
      if (cartItems[i].isSelected != targetState) {
        cartItems[i] = cartItems[i].copyWith(isSelected: targetState);
        // Fire and forget backend updates
        _apiClient.dio.patch(
          ApiEndpoints.selectCartItem,
          data: {"itemId": cartItems[i].id},
          options: Options(validateStatus: (status) => true),
        );
      }
    }
    cartItems.refresh();
  }

  void _updateCartItems(dynamic data) {
    if (data['data'] != null && data['data']['allItems'] != null) {
      cartItems.value = (data['data']['allItems'] as List)
          .map((e) => CartItemModel.fromJson(e))
          .toList();
    }
  }
}
