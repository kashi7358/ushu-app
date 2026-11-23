import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../../core/utils/session_manager.dart';
import '../../../../core/utils/custom_popup.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../app/routes/app_routes.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/buyer_profile_model.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../../order/presentation/controllers/order_controller.dart';
import '../../../wishlist/presentation/controllers/wishlist_controller.dart';

class ProfileController extends GetxController {
  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;
  final RxInt followedStoresCount = 0.obs;
  final Rxn<BuyerProfileModel> buyerProfile = Rxn<BuyerProfileModel>();
  final RxBool isProfileLoading = false.obs;
  final RxString userPhone = ''.obs;
  final RxString userAvatar = ''.obs;
  final RxString userAddress = ''.obs;
  final RxBool isVerified = false.obs;
  Worker? _authWorker;

  @override
  void onInit() {
    super.onInit();
    _hydrateFromSession();
    _authWorker = ever(SessionManager.isUserLoggedInRx, (bool loggedIn) {
      _hydrateFromSession();
      if (loggedIn) {
        fetchBuyerProfile();
      }
    });
    if (SessionManager.isLoggedIn) {
      fetchBuyerProfile();
    }
    loadFollowedStoresCount();
  }

  @override
  void onClose() {
    _authWorker?.dispose();
    super.onClose();
  }

  void _hydrateFromSession() {
    if (SessionManager.isLoggedIn) {
      userName.value = (SessionManager.fullName ?? '').trim();
      userEmail.value = (SessionManager.email ?? '').trim();
    } else {
      buyerProfile.value = null;
      userName.value = 'Guest User';
      userEmail.value = 'Login to view account details';
      userPhone.value = '';
      userAvatar.value = '';
      userAddress.value = '';
      isVerified.value = false;
    }
  }

  Future<void> fetchBuyerProfile({bool silent = false}) async {
    if (!SessionManager.isLoggedIn ||
        SessionManager.token == null ||
        SessionManager.token!.trim().isEmpty) {
      return;
    }
    if (isProfileLoading.value) return;

    try {
      isProfileLoading.value = true;
      final response = await ApiClient().dio.get(
        ApiEndpoints.buyerProfile,
        options: Options(validateStatus: (status) => true),
      );

      final data = response.data;
      if ((response.statusCode == 200 || response.statusCode == 201) && data is Map) {
        if (data['success'] == false) return;

        final profile = BuyerProfileModel.fromJson(data);
        buyerProfile.value = profile;

        userName.value = profile.fullName.isNotEmpty
            ? profile.fullName
            : (userName.value.isNotEmpty ? userName.value : profile.displayName);

        if (profile.email.isNotEmpty) {
          userEmail.value = profile.email;
        }
        userPhone.value = profile.phone;
        userAvatar.value = profile.avatar;
        userAddress.value = profile.address;
        isVerified.value = profile.isVerified;

        if (userAddress.value.isEmpty) {
          final saved = await SessionManager.getSavedAddress();
          if (saved != null) {
            final city = (saved['city'] ?? '').trim();
            final province = (saved['province'] ?? '').trim();
            final concise = [city, province].where((e) => e.isNotEmpty).join(', ');
            if (concise.isNotEmpty) {
              userAddress.value = concise;
            } else {
              final line = (saved['addressLine'] ?? '').trim();
              if (line.isNotEmpty) {
                userAddress.value = line;
              }
            }
          }
        }

        await SessionManager.updateBuyerInfo(
          userId: profile.id,
          fullName: profile.fullName,
          email: profile.email,
        );
      }
    } catch (e) {
      debugPrint('Error fetching buyer profile: $e');
    } finally {
      isProfileLoading.value = false;
    }
  }

  Future<void> applyLocalProfileUpdate({
    BuyerProfileModel? parsedProfile,
    String? fullName,
    String? phone,
    String? address,
  }) async {
    if (parsedProfile != null) {
      buyerProfile.value = parsedProfile;
      if (parsedProfile.fullName.isNotEmpty) {
        userName.value = parsedProfile.fullName;
      }
      if (parsedProfile.email.isNotEmpty) {
        userEmail.value = parsedProfile.email;
      }
      if (parsedProfile.phone.isNotEmpty) {
        userPhone.value = parsedProfile.phone;
      }
      if (parsedProfile.avatar.isNotEmpty) {
        userAvatar.value = parsedProfile.avatar;
      }
      if (parsedProfile.address.isNotEmpty) {
        userAddress.value = parsedProfile.address;
      }
      isVerified.value = parsedProfile.isVerified;
    }

    final cleanName = fullName?.trim();
    if (cleanName != null && cleanName.isNotEmpty) {
      userName.value = cleanName;
    }

    final cleanPhone = phone?.trim();
    if (cleanPhone != null && cleanPhone.isNotEmpty) {
      userPhone.value = cleanPhone;
    }

    final cleanAddress = address?.trim();
    if (cleanAddress != null && cleanAddress.isNotEmpty) {
      userAddress.value = cleanAddress;
    }

    final current = buyerProfile.value;
    if (current != null && parsedProfile == null) {
      buyerProfile.value = BuyerProfileModel(
        id: current.id,
        fullName: (cleanName != null && cleanName.isNotEmpty) ? cleanName : current.fullName,
        email: current.email,
        phone: (cleanPhone != null && cleanPhone.isNotEmpty) ? cleanPhone : current.phone,
        address: (cleanAddress != null && cleanAddress.isNotEmpty) ? cleanAddress : current.address,
        role: current.role,
        avatar: current.avatar,
        isVerified: current.isVerified,
        createdAt: current.createdAt,
      );
    }

    await SessionManager.updateBuyerInfo(
      userId: parsedProfile?.id,
      fullName: (cleanName != null && cleanName.isNotEmpty)
          ? cleanName
          : parsedProfile?.fullName,
      email: parsedProfile?.email,
    );
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
    buyerProfile.value = null;
    userName.value = 'Guest User';
    userEmail.value = 'Login to view account details';
    userPhone.value = '';
    userAvatar.value = '';
    userAddress.value = '';
    isVerified.value = false;
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
