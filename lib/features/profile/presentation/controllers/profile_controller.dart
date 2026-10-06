import 'package:get/get.dart';
import '../../../../core/utils/session_manager.dart';
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
}
