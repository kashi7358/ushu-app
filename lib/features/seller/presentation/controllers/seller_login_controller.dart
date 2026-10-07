import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/errors/exception_handler.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/custom_popup.dart';
import '../../../../core/utils/session_manager.dart';
import '../../data/datasources/seller_remote_data_source.dart';
import '../../data/repositories/seller_repository_impl.dart';
import '../../domain/repositories/seller_repository.dart';

class SellerLoginController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;

  late final SellerRepository _repository;

  @override
  void onInit() {
    super.onInit();
    final apiClient = ApiClient();
    final remoteDataSource = SellerRemoteDataSourceImpl(apiClient);
    _repository = SellerRepositoryImpl(remoteDataSource);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      final response = await _repository.loginSeller(
        emailController.text.trim(),
        passwordController.text,
      );

      // Check if backend returned explicit failure (e.g. Invalid password, Seller not found)
      if (response is Map) {
        final isSuccess = response['success'] == true;
        final rawMsg = response['message']?.toString() ?? '';

        if (!isSuccess && response['success'] != null) {
          final msgLower = rawMsg.toLowerCase();
          // ONLY trigger approval dialog if backend specifically states account approval is pending
          final isPendingMsg = (msgLower.contains('approv') || msgLower.contains('under review')) &&
              !msgLower.contains('password') &&
              !msgLower.contains('found') &&
              !msgLower.contains('credential') &&
              !msgLower.contains('email') &&
              !msgLower.contains('incorrect');

          if (isPendingMsg) {
            _showPendingApprovalDialog(rawMsg);
          } else {
            CustomPopup.showError('Login Failed', rawMsg.isNotEmpty ? rawMsg : 'Invalid email or password');
          }
          return;
        }
      }

      String? token;
      String? sellerId;
      String? name;
      String? status;
      bool? isApproved;

      if (response is Map) {
        if (response['token'] != null) token = response['token'].toString();
        if (response['sellerId'] != null) sellerId = response['sellerId'].toString();
        if (response['status'] != null) status = response['status'].toString();
        if (response['isApproved'] is bool) isApproved = response['isApproved'] as bool;
        if (response['approved'] is bool) isApproved = response['approved'] as bool;

        final sellerData = response['seller'] ?? response['data'];
        if (sellerData is Map) {
          sellerId ??= sellerData['_id']?.toString() ?? sellerData['id']?.toString() ?? sellerData['sellerId']?.toString();
          token ??= sellerData['token']?.toString();
          name ??= sellerData['fullName']?.toString() ?? sellerData['DisplayName']?.toString();
          status ??= sellerData['status']?.toString();
          if (sellerData['isApproved'] is bool) isApproved = sellerData['isApproved'] as bool;
          if (sellerData['approved'] is bool) isApproved = sellerData['approved'] as bool;
        }
      }

      // If neither token nor sellerId exists, credentials were not accepted
      if (token == null && sellerId == null) {
        final errorMsg = response is Map && response['message'] != null
            ? response['message'].toString()
            : 'Invalid email or password';
        CustomPopup.showError('Login Failed', errorMsg);
        return;
      }

      // 1. Check if Admin has approved the account
      final statusLower = status?.toLowerCase() ?? '';
      final isPending = statusLower == 'pending' ||
          statusLower == 'under review' ||
          statusLower == 'in review' ||
          isApproved == false;
      final isRejected = statusLower == 'rejected' || statusLower == 'declined';

      if (isPending) {
        _showPendingApprovalDialog();
        return;
      }

      if (isRejected) {
        CustomPopup.showError(
          'Application Rejected',
          'Your seller registration has been rejected by Admin. Please contact support.',
        );
        return;
      }

      // If approved, save session
      await SessionManager.saveSellerSession(
        sellerId: sellerId ?? '',
        token: token,
        email: emailController.text.trim(),
        name: name,
        status: status ?? 'Approved',
      );

      // 2. Check if Store is Created
      bool hasStore = false;
      if (response is Map) {
        if (response['hasStore'] == true || response['storeCreated'] == true) {
          hasStore = true;
        } else if (response['store'] != null && response['store'] is Map && (response['store'] as Map).isNotEmpty) {
          hasStore = true;
        }
      }

      // Navigate directly without intermediate popup button
      if (!hasStore) {
        Get.offAllNamed(
          AppRoutes.sellerCreateStore,
          arguments: {
            'sellerId': sellerId ?? '',
            'email': emailController.text.trim(),
            'name': name,
          },
        );
      } else {
        Get.offAllNamed(AppRoutes.mainLayout);
      }
    } catch (e) {
      final error = ExceptionHandler.handle(e);
      final msgLower = error.message.toLowerCase();

      // Detect if the exception is genuinely due to pending admin approval
      final isPendingMsg = (msgLower.contains('approv') || msgLower.contains('under review')) &&
          !msgLower.contains('password') &&
          !msgLower.contains('found') &&
          !msgLower.contains('credential') &&
          !msgLower.contains('email') &&
          !msgLower.contains('incorrect');

      if (isPendingMsg) {
        _showPendingApprovalDialog(error.message);
      } else {
        CustomPopup.showError('Login Failed', error.message);
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _showPendingApprovalDialog([String? customMessage]) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: TweenAnimationBuilder(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutBack,
          tween: Tween<double>(begin: 0.7, end: 1.0),
          builder: (context, double scale, child) {
            return Transform.scale(scale: scale, child: child);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.accentOrange.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.hourglass_top_rounded,
                    size: 44,
                    color: AppColors.accentOrange,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Account Approval Pending',
                  style: AppTextStyles.extraBold.copyWith(fontSize: 19, color: AppColors.darkText),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  customMessage != null &&
                          customMessage.isNotEmpty &&
                          !customMessage.toLowerCase().contains('failed') &&
                          !customMessage.toLowerCase().contains('error')
                      ? customMessage
                      : 'Apka seller account abhi tak admin se approve nahi hua hai. Admin approval milne ke baad hi aap login kar sakenge.',
                  style: AppTextStyles.medium.copyWith(
                    color: AppColors.hintText,
                    height: 1.45,
                    fontSize: 13.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      alignment: Alignment.center,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Understood',
                        style: AppTextStyles.bold.copyWith(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  void navigateToRegister() {
    Get.toNamed(AppRoutes.sellerRegister);
  }

  void navigateToForgetPassword() {
    Get.toNamed(AppRoutes.sellerForgetPassword);
  }
}
