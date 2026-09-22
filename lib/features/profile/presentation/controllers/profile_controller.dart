import 'package:get/get.dart';
import '../../../../core/utils/session_manager.dart';
import '../../../../app/routes/app_routes.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ProfileController extends GetxController {
  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;
  final RxInt followedStoresCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    userName.value = SessionManager.fullName ?? 'User';
    userEmail.value = SessionManager.email ?? 'No email';
    loadFollowedStoresCount();
  }

  void loadFollowedStoresCount() async {
    final prefs = await SharedPreferences.getInstance();
    final followedStores = prefs.getStringList('followed_stores') ?? [];
    followedStoresCount.value = followedStores.length;
  }

  Future<void> logout() async {
    await SessionManager.clearSession();
    Get.offAllNamed(AppRoutes.login);
  }
}
