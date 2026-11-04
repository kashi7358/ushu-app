import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/utils/custom_popup.dart';
import '../../../../core/utils/session_manager.dart';
import '../../../../core/utils/home_cache_manager.dart';

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

  Future<void> addToCart(String productId, int quantity, String productName, [int? currentStock]) async {
    if (isAddingToCart.value) return;

    final existingIndex = cartItems.indexWhere((item) => item.productId == productId || item.id == productId);
    final availableStock = currentStock ?? (existingIndex != -1 ? cartItems[existingIndex].stock : null);

    if (availableStock != null && availableStock <= 0) {
      CustomPopup.showToast('Out of Stock', 'This item is currently out of stock', isError: true);
      return;
    }

    if (existingIndex != -1) {
      final existingItem = cartItems[existingIndex];
      final itemStock = currentStock ?? existingItem.stock;
      if (itemStock > 0 && existingItem.quantity + quantity > itemStock) {
        CustomPopup.showToast('Stock Limit', 'Cannot add more. You have ${existingItem.quantity} in cart and available stock is $itemStock', isError: true);
        return;
      }
    }

    // Show animation immediately
    CustomPopup.showFastLottie('assets/lotties/add_to_cart_new.json');
    
    try {
      isAddingToCart.value = true;
      final token = SessionManager.token;
      final headers = <String, dynamic>{
        if (token != null && token.isNotEmpty) ...{
          'Authorization': 'Bearer $token',
          'auth-token': token,
        },
      };

      final response = await _apiClient.dio.post(
        ApiEndpoints.addToCart,
        data: {
          "productId": productId,
          "id": productId,
          "quantity": quantity,
        },
        options: Options(
          headers: headers,
          validateStatus: (status) => true,
        ),
      );

      // Dismiss popup as soon as response is received
      CustomPopup.hideFastLottie();

      final statusCode = response.statusCode ?? 500;
      final data = response.data;
      final bool isSuccess = (statusCode >= 200 && statusCode < 300) &&
          (data == null ||
              (data is Map &&
                  data['success'] != false &&
                  data['status'] != 'error' &&
                  data['status'] != 'fail'));

      if (isSuccess) {
        _updateCartItems(data);
        if (currentStock != null) {
          final idx = cartItems.indexWhere((i) => i.productId == productId || i.id == productId);
          if (idx != -1 && cartItems[idx].stock != currentStock) {
            cartItems[idx] = cartItems[idx].copyWith(stock: currentStock < 0 ? 0 : currentStock);
            cartItems.refresh();
          }
        }
        await fetchCart(); // Refresh from real backend
        CustomPopup.showToast('Added to Cart', '$productName added to cart successfully!');
      } else {
        String msg = 'Could not add to cart';
        if (data is Map) {
          msg = data['message']?.toString() ??
              data['error']?.toString() ??
              data['msg']?.toString() ??
              msg;
        } else if (response.statusMessage != null && response.statusMessage!.isNotEmpty) {
          msg = response.statusMessage!;
        }
        CustomPopup.showToast('Failed', msg, isError: true);
      }
    } catch (e) {
      CustomPopup.hideFastLottie();
      debugPrint('Error adding to cart: $e');
      CustomPopup.showToast('Error', 'An error occurred while adding to cart.', isError: true);
    } finally {
      CustomPopup.hideFastLottie();
      isAddingToCart.value = false;
    }
  }

  Future<bool> buyNow(String productId, int quantity, String productName, [int? currentStock]) async {
    if (isAddingToCart.value) return false;

    if (currentStock != null && currentStock <= 0) {
      CustomPopup.showToast('Out of Stock', 'This item is currently out of stock', isError: true);
      return false;
    }

    try {
      isAddingToCart.value = true;
      CustomPopup.showFastLottie('assets/lotties/add_to_cart_new.json');

      final token = SessionManager.token;
      final headers = <String, dynamic>{
        if (token != null && token.isNotEmpty) ...{
          'Authorization': 'Bearer $token',
          'auth-token': token,
        },
      };

      final response = await _apiClient.dio.post(
        ApiEndpoints.addToCart,
        data: {
          "productId": productId,
          "id": productId,
          "quantity": quantity,
        },
        options: Options(
          headers: headers,
          validateStatus: (status) => true,
        ),
      );

      // Dismiss popup as soon as response is received
      CustomPopup.hideFastLottie();

      final statusCode = response.statusCode ?? 500;
      final data = response.data;
      final bool isSuccess = (statusCode >= 200 && statusCode < 300) &&
          (data == null ||
              (data is Map &&
                  data['success'] != false &&
                  data['status'] != 'error' &&
                  data['status'] != 'fail'));

      if (isSuccess) {
        _updateCartItems(data);
        if (currentStock != null) {
          final idx = cartItems.indexWhere((i) => i.productId == productId || i.id == productId);
          if (idx != -1 && cartItems[idx].stock != currentStock) {
            cartItems[idx] = cartItems[idx].copyWith(stock: currentStock < 0 ? 0 : currentStock);
            cartItems.refresh();
          }
        }
        await fetchCart(); // Refresh from real backend

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
        String msg = 'Could not process Buy Now';
        if (data is Map) {
          msg = data['message']?.toString() ??
              data['error']?.toString() ??
              data['msg']?.toString() ??
              msg;
        } else if (response.statusMessage != null && response.statusMessage!.isNotEmpty) {
          msg = response.statusMessage!;
        }
        CustomPopup.showToast('Failed', msg, isError: true);
        return false;
      }
    } catch (e) {
      CustomPopup.hideFastLottie();
      debugPrint('Error during Buy Now: $e');
      CustomPopup.showToast('Error', 'An error occurred during Buy Now', isError: true);
      return false;
    } finally {
      CustomPopup.hideFastLottie();
      isAddingToCart.value = false;
    }
  }

  Future<void> fetchCart() async {
    try {
      isLoadingCart.value = true;
      isNoInternet.value = false;
      final token = SessionManager.token;
      final headers = <String, dynamic>{
        if (token != null && token.isNotEmpty) ...{
          'Authorization': 'Bearer $token',
          'auth-token': token,
        },
      };

      final response = await _apiClient.dio.get(
        ApiEndpoints.getCart,
        options: Options(
          headers: headers,
          validateStatus: (status) => true,
        ),
      );

      final statusCode = response.statusCode ?? 500;
      final data = response.data;
      if (statusCode >= 200 && statusCode < 300 && data != null) {
        _updateCartItems(data);
        await syncCartItemsStockWithProducts();
      }
    } catch (e) {
      if (cartItems.isEmpty) {
        isNoInternet.value = true;
      }
      debugPrint('Error fetching cart: $e');
    } finally {
      isLoadingCart.value = false;
    }
  }

  Future<void> syncCartItemsStockWithProducts() async {
    if (cartItems.isEmpty) return;
    try {
      bool hasChanges = false;
      final cached = await HomeCacheManager.getHomepageProducts();
      final cachedMap = {for (var p in cached) p.id: p.stock};

      for (int i = 0; i < cartItems.length; i++) {
        final item = cartItems[i];
        int? resolvedStock;
        if (cachedMap.containsKey(item.productId)) {
          resolvedStock = cachedMap[item.productId];
        } else {
          try {
            final res = await _apiClient.dio.get(
              '${ApiEndpoints.singleProduct}${item.productId}',
              options: Options(validateStatus: (status) => true),
            );
            if (res.data is Map) {
              dynamic pData = res.data['product'] ?? res.data['data'] ?? res.data['singleProduct'];
              if (pData is Map) {
                dynamic sVal = pData['stock'] ?? pData['stockQuantity'] ?? pData['countInStock'] ?? pData['quantity'];
                if (sVal != null) {
                  resolvedStock = int.tryParse(sVal.toString());
                }
              }
            }
          } catch (_) {}
        }

        if (resolvedStock != null) {
          if (resolvedStock < 0) resolvedStock = 0;
          if (item.stock != resolvedStock) {
            cartItems[i] = item.copyWith(stock: resolvedStock);
            hasChanges = true;
          }
        }
      }

      if (hasChanges) {
        cartItems.refresh();
      }
    } catch (e) {
      debugPrint('Error syncing cart stock: $e');
    }
  }

  Future<void> removeFromCart(String itemId) async {
    // Optimistic UI Update: immediately remove from UI & show lottie
    cartItems.removeWhere((item) => item.id == itemId);
    CustomPopup.showFastLottie('assets/lotties/delete.json');

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
      if (oldItem.stock > 0 && quantity > oldItem.stock) {
        CustomPopup.showToast('Limit Reached', 'Only ${oldItem.stock} items available in stock', isError: true);
        return;
      }
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
      debugPrint('Error updating quantity: $e');
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
      debugPrint('Error selecting item: $e');
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
    if (data == null) return;
    List? itemsList;
    if (data is Map) {
      if (data['data'] != null) {
        final d = data['data'];
        if (d is Map) {
          itemsList = d['allItems'] ?? d['items'] ?? d['cartItems'] ?? d['products'];
        } else if (d is List) {
          itemsList = d;
        }
      }
      if (itemsList == null && data['cart'] != null) {
        final c = data['cart'];
        if (c is Map) {
          itemsList = c['items'] ?? c['allItems'] ?? c['products'];
        } else if (c is List) {
          itemsList = c;
        }
      }
      itemsList ??= data['allItems'] ?? data['items'] ?? data['cartItems'];
    } else if (data is List) {
      itemsList = data;
    }

    if (itemsList != null) {
      cartItems.value = itemsList
          .whereType<Map<String, dynamic>>()
          .map((e) => CartItemModel.fromJson(e))
          .toList();
    }
  }
}
