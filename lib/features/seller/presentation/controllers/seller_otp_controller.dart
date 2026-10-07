import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/errors/exception_handler.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/custom_popup.dart';
import '../../data/datasources/seller_remote_data_source.dart';
import '../../data/repositories/seller_repository_impl.dart';
import '../../domain/repositories/seller_repository.dart';

class SellerOtpController extends GetxController {
  final otpController = TextEditingController();
  final FocusNode otpFocusNode = FocusNode();
  final RxString otpText = ''.obs;
  final RxBool isLoading = false.obs;

  late final SellerRepository _repository;

  String sellerId = '';
  String email = '';

  // Resend Timer
  final RxInt resendTimer = 60.obs;
  final RxBool isResendEnabled = false.obs;
  Timer? _timer;

  Map<String, dynamic> signupData = {};

  @override
  void onInit() {
    super.onInit();
    final apiClient = ApiClient();
    final remoteDataSource = SellerRemoteDataSourceImpl(apiClient);
    _repository = SellerRepositoryImpl(remoteDataSource);

    otpController.addListener(() {
      otpText.value = otpController.text;
    });

    // Extract dynamic arguments
    final args = Get.arguments;
    if (args is Map) {
      signupData = Map<String, dynamic>.from(args);
      sellerId = args['sellerId']?.toString() ?? '';
      email = args['email']?.toString() ?? '';
    }

    startResendTimer();
  }

  @override
  void onClose() {
    _timer?.cancel();
    otpFocusNode.dispose();
    otpController.dispose();
    super.onClose();
  }

  void startResendTimer() {
    _timer?.cancel();
    resendTimer.value = 60;
    isResendEnabled.value = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendTimer.value > 0) {
        resendTimer.value--;
      } else {
        isResendEnabled.value = true;
        _timer?.cancel();
      }
    });
  }

  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();
    if (otp.isEmpty) {
      CustomPopup.showError('Required', 'Please enter the 6-digit OTP code sent to your email.');
      return;
    }

    if (otp.length < 6) {
      CustomPopup.showError('Incomplete OTP', 'Please enter all 6 digits of the OTP code.');
      return;
    }

    if (sellerId.isEmpty) {
      CustomPopup.showError('Error', 'Missing Seller ID. Please try registering again.');
      return;
    }

    try {
      isLoading.value = true;

      final response = await _repository.verifySellerEmail(
        sellerId: sellerId,
        otp: otp,
      );

      final message = (response is Map && response['message'] != null)
          ? response['message'].toString()
          : 'Email verified successfully!';

      CustomPopup.showSuccess(
        'Email Verified!',
        message,
        buttonText: 'View Status',
        onConfirm: () {
          // Flow: Signup -> Verify Email OTP -> Pending Admin Approval Screen
          Get.offAllNamed(AppRoutes.sellerPendingApproval);
        },
      );
    } catch (e) {
      final error = ExceptionHandler.handle(e);
      CustomPopup.showError('Verification Failed', error.message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOtp() async {
    if (!isResendEnabled.value) return;

    if (sellerId.isEmpty) {
      CustomPopup.showError('Error', 'Missing Seller ID. Please try registering again.');
      return;
    }

    try {
      CustomPopup.showLoading('Resending verification code...');

      final response = await _repository.resendSellerOtp(
        sellerId: sellerId,
      );

      CustomPopup.hideLoading();

      final message = (response is Map && response['message'] != null)
          ? response['message'].toString()
          : 'A new OTP has been sent to your email!';

      CustomPopup.showSuccess('Code Resent', message);

      startResendTimer();
    } catch (e) {
      CustomPopup.hideLoading();
      final error = ExceptionHandler.handle(e);
      CustomPopup.showError('Resend Failed', error.message);
    }
  }
}
