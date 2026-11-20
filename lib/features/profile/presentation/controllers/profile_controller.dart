import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../../core/utils/session_manager.dart';
import '../../../../core/utils/custom_popup.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../app/routes/app_routes.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../../order/presentation/controllers/order_controller.dart';
import '../../../wishlist/presentation/controllers/wishlist_controller.dart';

class ProfileController extends GetxController {
  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;
  final RxInt followedStoresCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    userName.value = SessionManager.isLoggedIn ? (SessionManager.fullName ?? 'User') : 'Guest User';
    userEmail.value = SessionManager.isLoggedIn ? (SessionManager.email ?? 'No email') : 'Login to view account details';
    loadFollowedStoresCount();
  }

  void loadFollowedStoresCount() async {
    final prefs = await SharedPreferences.getInstance();
    final followedStores = prefs.getStringList('followed_stores') ?? [];
    followedStoresCount.value = followedStores.length;
  }

  Future<void> logout() async {
    await SessionManager.clearSession();
    await SessionManager.clearSellerSession();
    await SessionManager.setLastScreen(null);
    // Reset in-memory state to protect privacy between accounts
    if (Get.isRegistered<CartController>()) {
      Get.find<CartController>().cartItems.clear();
    }
    if (Get.isRegistered<OrderController>()) {
      Get.find<OrderController>().orders.clear();
    }
    if (Get.isRegistered<WishlistController>()) {
      Get.find<WishlistController>().wishlistProducts.clear();
      Get.find<WishlistController>().wishlistedProductIds.clear();
    }
    userName.value = 'Guest User';
    userEmail.value = 'Login to view account details';
    Get.offAllNamed(AppRoutes.login);
  }

  Future<void> deleteAccount() async {
    final String? password = await CustomPopup.showDeleteAccountDialog(
      title: 'Delete Buyer Account',
      message: 'Are you sure you want to delete your account? All your personal information, active orders, and saved addresses will be permanently deleted.',
    );

    if (password == null || password.trim().isEmpty) {
      return;
    }

    CustomPopup.showLoading('Deleting account...');
    try {
      final response = await ApiClient().dio.delete(
        ApiEndpoints.deleteBuyerAccount,
        data: {
          'Password': password.trim(),
        },
      );

      CustomPopup.hideLoading();

      final data = response.data;
      if (data is Map && data['success'] == false) {
        CustomPopup.showToast('Error', data['message']?.toString() ?? 'Failed to delete account', isError: true);
        return;
      }

      CustomPopup.showToast('Success', data is Map ? (data['message']?.toString() ?? 'Account deleted successfully') : 'Account deleted successfully');
      await logout();
    } catch (e) {
      CustomPopup.hideLoading();
      String errorMsg = 'Failed to delete account. Please verify your password and try again.';
      if (e is DioException) {
        if (e.response?.data is Map && e.response?.data['message'] != null) {
          errorMsg = e.response!.data['message'].toString();
        } else if (e.response?.statusCode == 400 || e.response?.statusCode == 401) {
          errorMsg = 'Incorrect password. Please enter your correct password.';
        }
      }
      CustomPopup.showToast('Error', errorMsg, isError: true);
    }
  }
}
