import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/utils/custom_popup.dart';
import '../../../../core/utils/session_manager.dart';
import '../../data/models/buyer_profile_model.dart';
import 'profile_controller.dart';

class EditProfileController extends GetxController {
  EditProfileController({int initialTab = 0}) {
    selectedTab.value = initialTab == 1 ? 1 : 0;
  }

  final profileFormKey = GlobalKey<FormState>();
  final passwordFormKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final RxInt selectedTab = 0.obs;
  final RxBool isUpdatingProfile = false.obs;
  final RxBool isChangingPassword = false.obs;
  final RxBool showCurrentPassword = false.obs;
  final RxBool showNewPassword = false.obs;
  final RxBool showConfirmPassword = false.obs;

  @override
  void onInit() {
    super.onInit();
    _hydrateFields();
    _syncFromBackendIfNeeded();
  }

  void _hydrateFields() {
    final profileCtrl = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : null;

    final rawName =
        (profileCtrl?.userName.value ?? SessionManager.fullName ?? '').trim();
    final rawEmail =
        (profileCtrl?.userEmail.value ?? SessionManager.email ?? '').trim();
    final rawPhone = (profileCtrl?.userPhone.value ?? '').trim();
    final rawAddress = (profileCtrl?.userAddress.value ?? '').trim();

    if (rawName.isNotEmpty && rawName != 'Guest User') {
      fullNameController.text = rawName;
    }
    if (rawEmail.isNotEmpty && rawEmail != 'Login to view account details') {
      emailController.text = rawEmail;
    }
    if (rawPhone.isNotEmpty) {
      phoneController.text = rawPhone;
    }
    if (rawAddress.isNotEmpty) {
      addressController.text = rawAddress;
    }
  }

  Future<void> _syncFromBackendIfNeeded() async {
    if (!SessionManager.isLoggedIn) return;
    if (!Get.isRegistered<ProfileController>()) return;
    final profileCtrl = Get.find<ProfileController>();
    if (profileCtrl.buyerProfile.value != null) return;

    await profileCtrl.fetchBuyerProfile(silent: true);
    if (isClosed) return;

    if (fullNameController.text.trim().isEmpty &&
        profileCtrl.userName.value.trim().isNotEmpty &&
        profileCtrl.userName.value.trim() != 'Guest User') {
      fullNameController.text = profileCtrl.userName.value.trim();
    }
    if (emailController.text.trim().isEmpty &&
        profileCtrl.userEmail.value.trim().isNotEmpty &&
        profileCtrl.userEmail.value.trim() != 'Login to view account details') {
      emailController.text = profileCtrl.userEmail.value.trim();
    }
    if (phoneController.text.trim().isEmpty &&
        profileCtrl.userPhone.value.trim().isNotEmpty) {
      phoneController.text = profileCtrl.userPhone.value.trim();
    }
    if (addressController.text.trim().isEmpty &&
        profileCtrl.userAddress.value.trim().isNotEmpty) {
      addressController.text = profileCtrl.userAddress.value.trim();
    }
  }

  void switchTab(int index) {
    selectedTab.value = index == 1 ? 1 : 0;
  }

  Future<void> updateProfile() async {
    if (!(profileFormKey.currentState?.validate() ?? false)) return;

    if (!SessionManager.isLoggedIn ||
        SessionManager.token == null ||
        SessionManager.token!.trim().isEmpty) {
      CustomPopup.showLoginRequired();
      return;
    }
    if (isUpdatingProfile.value) return;

    final fullName = fullNameController.text.trim();
    final phone = phoneController.text.replaceAll(RegExp(r'\D'), '').trim();
    final address = addressController.text.trim();

    if (phone.isNotEmpty && phone.length != 11) {
      CustomPopup.showToast(
        'Validation Error',
        'Phone number must be exactly 11 digits (e.g. 03001234567)',
        isError: true,
      );
      return;
    }

    final Map<String, dynamic> payload = {
      'FullName': fullName,
      'fullName': fullName,
      if (phone.isNotEmpty) 'Phone': phone,
      if (phone.isNotEmpty) 'phone': phone,
      if (address.isNotEmpty) 'address': address,
      if (address.isNotEmpty) 'Address': address,
    };

    try {
      isUpdatingProfile.value = true;
      final response = await ApiClient().dio.put(
        ApiEndpoints.updateBuyerProfile,
        data: payload,
        options: Options(validateStatus: (status) => true),
      );

      final data = response.data;
      final bool hasFailedFlag = data is Map && data['success'] == false;
      final bool isSuccess =
          (response.statusCode == 200 || response.statusCode == 201) &&
              !hasFailedFlag;

      if (isSuccess) {
        BuyerProfileModel? parsed;
        if (data is Map) {
          final hasNestedProfile = data['buyer'] is Map ||
              data['profile'] is Map ||
              data['user'] is Map ||
              data['data'] is Map ||
              data['FullName'] != null ||
              data['fullName'] != null;
          if (hasNestedProfile) {
            parsed = BuyerProfileModel.fromJson(data);
          }
        }

        if (Get.isRegistered<ProfileController>()) {
          final profileCtrl = Get.find<ProfileController>();
          await profileCtrl.applyLocalProfileUpdate(
            parsedProfile: parsed,
            fullName: fullName,
            phone: phone,
            address: address,
          );
          profileCtrl.fetchBuyerProfile(silent: true);
        } else {
          await SessionManager.updateBuyerInfo(fullName: fullName);
        }

        final String msg = (data is Map &&
                data['message'] != null &&
                data['message'].toString().trim().isNotEmpty)
            ? data['message'].toString().trim()
            : 'Your profile has been updated successfully.';
        CustomPopup.showSuccess('Profile Updated', msg);
      } else {
        final String errorMsg = _extractErrorMessage(
          data,
          fallback:
              'Could not update profile. Please check your details and try again.',
        );
        CustomPopup.showToast('Update Failed', errorMsg, isError: true);
      }
    } catch (e) {
      debugPrint('Update profile error: $e');
      CustomPopup.showToast(
        'Update Failed',
        'An unexpected error occurred while updating your profile.',
        isError: true,
      );
    } finally {
      isUpdatingProfile.value = false;
    }
  }

  Future<void> changePassword() async {
    if (!(passwordFormKey.currentState?.validate() ?? false)) return;

    if (!SessionManager.isLoggedIn ||
        SessionManager.token == null ||
        SessionManager.token!.trim().isEmpty) {
      CustomPopup.showLoginRequired();
      return;
    }
    if (isChangingPassword.value) return;

    final currentPassword = currentPasswordController.text;
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (newPassword != confirmPassword) {
      CustomPopup.showToast(
        'Validation Error',
        'New password and confirm password do not match.',
        isError: true,
      );
      return;
    }
    if (newPassword == currentPassword) {
      CustomPopup.showToast(
        'Validation Error',
        'New password must be different from your current password.',
        isError: true,
      );
      return;
    }

    final payload = {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    };

    try {
      isChangingPassword.value = true;
      final response = await ApiClient().dio.put(
        ApiEndpoints.updateBuyerProfile,
        data: payload,
        options: Options(validateStatus: (status) => true),
      );

      final data = response.data;
      final bool hasFailedFlag = data is Map && data['success'] == false;
      final bool isSuccess =
          (response.statusCode == 200 || response.statusCode == 201) &&
              !hasFailedFlag;

      if (isSuccess) {
        currentPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();

        final String msg = (data is Map &&
                data['message'] != null &&
                data['message'].toString().trim().isNotEmpty)
            ? data['message'].toString().trim()
            : 'Your password has been changed successfully.';
        CustomPopup.showSuccess('Password Changed', msg);
      } else {
        final String errorMsg = _extractErrorMessage(
          data,
          fallback:
              'Could not change password. Please verify your current password.',
        );
        CustomPopup.showToast('Password Change Failed', errorMsg, isError: true);
      }
    } catch (e) {
      debugPrint('Change password error: $e');
      CustomPopup.showToast(
        'Password Change Failed',
        'An unexpected error occurred while changing your password.',
        isError: true,
      );
    } finally {
      isChangingPassword.value = false;
    }
  }

  String _extractErrorMessage(dynamic data, {required String fallback}) {
    if (data is Map) {
      final msg = data['message'] ?? data['error'] ?? data['msg'];
      if (msg != null && msg.toString().trim().isNotEmpty) {
        return msg.toString().trim();
      }
      if (data['errors'] is List && (data['errors'] as List).isNotEmpty) {
        final first = (data['errors'] as List).first;
        if (first is Map && first['message'] != null) {
          return first['message'].toString().trim();
        }
        return first.toString().trim();
      }
    }
    return fallback;
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
