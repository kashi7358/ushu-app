import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool isDialogShowing = false;

  @override
  void onInit() {
    super.onInit();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(List<ConnectivityResult> connectivityResult) {
    if (connectivityResult.contains(ConnectivityResult.none)) {
      if (!isDialogShowing) {
        isDialogShowing = true;
        _showNoInternetDialog();
      }
    } else {
      if (isDialogShowing) {
        isDialogShowing = false;
        if (Get.isDialogOpen == true) {
          Get.back();
        }
      }
    }
  }

  void _showNoInternetDialog() {
    Get.dialog(
      PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off_rounded, size: 100, color: AppColors.primaryPurple),
                  const SizedBox(height: 24),
                  Text(
                    'No Internet Connection',
                    style: AppTextStyles.extraBold.copyWith(fontSize: 22, color: AppColors.darkText),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Please check your internet connection and try again.',
                    style: AppTextStyles.medium.copyWith(color: AppColors.hintText, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        final result = await _connectivity.checkConnectivity();
                        if (!result.contains(ConnectivityResult.none)) {
                          isDialogShowing = false;
                          Get.back();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Try Again',
                        style: AppTextStyles.bold.copyWith(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
      useSafeArea: false,
    );
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    super.onClose();
  }
}
