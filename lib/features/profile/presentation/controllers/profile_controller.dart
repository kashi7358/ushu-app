import 'package:get/get.dart';
import '../../../../core/utils/session_manager.dart';
import '../../../../app/routes/app_routes.dart';

class ProfileController extends GetxController {
  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;

  @override
  void onInit() {
    super.onInit();
    userName.value = SessionManager.fullName ?? 'User';
    userEmail.value = SessionManager.email ?? 'No email';
  }

  Future<void> logout() async {
    await SessionManager.clearSession();
    Get.offAllNamed(AppRoutes.login);
  }
}
