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

    // If seller is already logged in AND has a created store, redirect directly to Seller Dashboard
    final hasStore = SessionManager.sellerStoreId != null &&
        SessionManager.sellerStoreId!.trim().isNotEmpty;
    if (SessionManager.isSellerLoggedIn && hasStore) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed(AppRoutes.sellerDashboard);
      });
    } else {
      SessionManager.setLastScreen(AppRoutes.sellerLogin);
    }
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

      // 1. Check if Admin has specifically blocked or pending the account
      final statusLower = status?.toLowerCase() ?? '';
      final isPending = (statusLower == 'pending' || statusLower == 'under review' || statusLower == 'in review') ||
          (isApproved == false && (statusLower.isNotEmpty && statusLower != 'active' && statusLower != 'approved'));
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

      // 2. Check if Store is Created
      bool hasStore = false;
      String? storeId;

      final userEmail = emailController.text.trim();

      // Check if store ID was previously saved for this specific email or in current session
      final emailSavedStoreId = await SessionManager.getSavedStoreIdForEmail(userEmail);
      if (emailSavedStoreId != null && emailSavedStoreId.isNotEmpty) {
        storeId = emailSavedStoreId;
        hasStore = true;
      } else if (SessionManager.sellerStoreId != null && SessionManager.sellerStoreId!.isNotEmpty) {
        storeId = SessionManager.sellerStoreId;
        hasStore = true;
      }

      if (response is Map) {
        if (response['hasStore'] == true || response['storeCreated'] == true || response['isStoreCreated'] == true) {
          hasStore = true;
        }
        if (response['storeId'] != null && response['storeId'].toString().isNotEmpty) {
          storeId = response['storeId'].toString();
          hasStore = true;
        }
        if (response['store_id'] != null && response['store_id'].toString().isNotEmpty) {
          storeId = response['store_id'].toString();
          hasStore = true;
        }
        if (response['store'] != null) {
          if (response['store'] is Map && (response['store'] as Map).isNotEmpty) {
            hasStore = true;
            final storeMap = response['store'] as Map;
            storeId ??= storeMap['_id']?.toString() ?? storeMap['id']?.toString();
          } else if (response['store'] is String && response['store'].toString().isNotEmpty && response['store'] != 'null') {
            storeId ??= response['store'].toString();
            hasStore = true;
          }
        }

        // Also inspect nested seller or data payload
        final sellerPayload = response['seller'] ?? response['data'];
        if (sellerPayload is Map) {
          if (sellerPayload['hasStore'] == true || sellerPayload['storeCreated'] == true || sellerPayload['isStoreCreated'] == true) {
            hasStore = true;
          }
          if (sellerPayload['storeId'] != null && sellerPayload['storeId'].toString().isNotEmpty) {
            storeId = sellerPayload['storeId'].toString();
            hasStore = true;
          }
          if (sellerPayload['store_id'] != null && sellerPayload['store_id'].toString().isNotEmpty) {
            storeId = sellerPayload['store_id'].toString();
            hasStore = true;
          }
          if (sellerPayload['store'] != null) {
            if (sellerPayload['store'] is Map && (sellerPayload['store'] as Map).isNotEmpty) {
              hasStore = true;
              final sMap = sellerPayload['store'] as Map;
              storeId ??= sMap['_id']?.toString() ?? sMap['id']?.toString();
            } else if (sellerPayload['store'] is String && sellerPayload['store'].toString().isNotEmpty && sellerPayload['store'] != 'null') {
              storeId ??= sellerPayload['store'].toString();
              hasStore = true;
            }
          }
        }
      }

      // Check backend stats API with token explicitly attached
      try {
        final statsResponse = await _repository.getDashboardStats(token);
        if (statsResponse is Map) {
          final statsMap = statsResponse['stats'] is Map
              ? statsResponse['stats'] as Map
              : (statsResponse['data'] is Map ? statsResponse['data'] as Map : statsResponse);

          final sName = statsResponse['storeName']?.toString() ??
              statsMap['storeName']?.toString() ??
              statsResponse['store']?['StoreName']?.toString() ??
              statsResponse['store']?['storeName']?.toString() ??
              statsMap['store']?['StoreName']?.toString() ??
              statsMap['store']?['storeName']?.toString();

          final sId = statsResponse['storeId']?.toString() ??
              statsMap['storeId']?.toString() ??
              statsResponse['store']?['_id']?.toString() ??
              statsResponse['store']?['id']?.toString() ??
              statsMap['store']?['_id']?.toString() ??
              statsMap['store']?['id']?.toString();

          if ((sName != null && sName.isNotEmpty && sName != 'null') || (sId != null && sId.isNotEmpty)) {
            hasStore = true;
            if (sId != null && sId.isNotEmpty) {
              storeId = sId;
              await SessionManager.saveStoreIdForEmail(userEmail, sId);
              await SessionManager.saveSellerStoreId(sId);
            }
            if (sName != null && sName.isNotEmpty && sName != 'null') {
              await SessionManager.saveStoreNameForEmail(userEmail, sName);
              await SessionManager.saveSellerStoreDetails(storeName: sName);
            }
          } else if (statsResponse['success'] == true && (statsResponse['data'] != null || statsResponse['stats'] != null)) {
            // Stats API succeeded which means seller account is already active with store
            hasStore = true;
          }
        }
      } catch (_) {
        // Ignored, check my-store below
      }

      // Check /store/my-store API directly
      try {
        final myStoreResponse = await _repository.getMyStore(token);
        if (myStoreResponse is Map && myStoreResponse['success'] == true) {
          final storeData = myStoreResponse['data'];
          if (storeData is Map && storeData.isNotEmpty) {
            hasStore = true;
            final fetchedStoreId = storeData['_id']?.toString() ?? storeData['id']?.toString();
            final fetchedStoreName = storeData['StoreName']?.toString() ?? storeData['storeName']?.toString();
            final fetchedLogo = storeData['logo']?.toString();

            if (fetchedStoreId != null && fetchedStoreId.isNotEmpty) {
              storeId = fetchedStoreId;
              await SessionManager.saveStoreIdForEmail(userEmail, fetchedStoreId);
              await SessionManager.saveSellerStoreId(fetchedStoreId);
            }
            if (fetchedStoreName != null && fetchedStoreName.isNotEmpty) {
              await SessionManager.saveStoreNameForEmail(userEmail, fetchedStoreName);
              await SessionManager.saveSellerStoreDetails(
                storeName: fetchedStoreName,
                logoPath: fetchedLogo,
                fullDetails: Map<String, dynamic>.from(storeData),
              );
            }
          }
        }
      } catch (_) {
        // Store genuinely does not exist yet
      }

      if (storeId != null && storeId.isNotEmpty) {
        await SessionManager.saveStoreIdForEmail(userEmail, storeId);
      }

      await SessionManager.setLastScreen(null);

      // Navigate based on whether store exists
      if (!hasStore) {
        // Save session with isLoggedIn: false so user CANNOT bypass to dashboard on restart
        await SessionManager.saveSellerSession(
          sellerId: sellerId ?? '',
          token: token,
          email: emailController.text.trim(),
          name: name,
          status: status ?? 'Approved',
          storeId: null,
          isLoggedIn: false,
        );

        Get.offAllNamed(
          AppRoutes.sellerCreateStore,
          arguments: {
            'sellerId': sellerId ?? '',
            'email': emailController.text.trim(),
            'name': name,
          },
        );
      } else {
        // Store genuinely exists -> save full session and allow dashboard
        await SessionManager.saveSellerSession(
          sellerId: sellerId ?? '',
          token: token,
          email: emailController.text.trim(),
          name: name,
          status: status ?? 'Approved',
          storeId: storeId,
          isLoggedIn: true,
        );

        Get.offAllNamed(AppRoutes.sellerDashboard);
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
