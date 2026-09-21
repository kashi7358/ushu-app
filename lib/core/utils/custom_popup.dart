import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

class CustomPopup {
  static void showSuccess(String title, String message) {
    _showDialog(
      title: title,
      message: message,
      icon: Icons.check_circle_rounded,
      iconColor: AppColors.success,
      lottieAsset: 'assets/lotties/done.json',
      emoji: '🎉',
    );
  }

  static void showError(String title, String message) {
    _showDialog(
      title: title,
      message: message,
      icon: Icons.error_rounded,
      iconColor: AppColors.error,
      emoji: '❌',
    );
  }

  static void showToast(String title, String message, {bool isError = false}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? AppColors.error : AppColors.success,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
      icon: Icon(
        isError ? Icons.error_outline : Icons.check_circle_outline,
        color: Colors.white,
      ),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }

  static void showFastLottie(String lottieAsset, {double width = 120, double height = 120}) {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
    Get.dialog(
      Center(
        child: TweenAnimationBuilder(
          duration: const Duration(milliseconds: 300),
          curve: Curves.elasticOut,
          tween: Tween<double>(begin: 0.5, end: 1.0),
          builder: (context, double scale, child) {
            return Transform.scale(scale: scale, child: child);
          },
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Lottie.asset(
              lottieAsset,
              width: width,
              height: height,
              repeat: false,
            ),
          ),
        ),
      ),
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.1),
    );

    // Auto close after animation
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    });
  }

  static void showLoginRequired() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: TweenAnimationBuilder(
          duration: const Duration(milliseconds: 500),
          curve: Curves.elasticOut,
          tween: Tween<double>(begin: 0.6, end: 1.0),
          builder: (context, double scale, child) {
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withOpacity(0.15),
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
                    color: AppColors.primaryPurple.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '🔐',
                    style: TextStyle(fontSize: 48),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Login Required',
                  style: AppTextStyles.extraBold.copyWith(fontSize: 22, color: AppColors.darkText),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Please login to perform this action and enjoy full features.',
                  style: AppTextStyles.medium.copyWith(color: AppColors.hintText, height: 1.5, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.hintText,
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: AppTextStyles.bold.copyWith(fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.back();
                            Get.toNamed('/login');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryPurple,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Login',
                            style: AppTextStyles.bold.copyWith(fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 200),
    );
  }

  static void _showDialog({
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
    required String emoji,
    String? lottieAsset,
  }) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: TweenAnimationBuilder(
          duration: const Duration(milliseconds: 500),
          curve: Curves.elasticOut,
          tween: Tween<double>(begin: 0.6, end: 1.0),
          builder: (context, double scale, child) {
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.bounceOut,
                  tween: Tween<double>(begin: -20.0, end: 0.0),
                  builder: (context, double value, child) {
                    return Transform.translate(
                      offset: Offset(0, value),
                      child: child,
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(lottieAsset != null ? 0 : 16),
                    decoration: BoxDecoration(
                      color: lottieAsset != null ? Colors.transparent : iconColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: lottieAsset != null
                        ? Lottie.asset(
                            lottieAsset,
                            width: 100,
                            height: 100,
                            repeat: false,
                          )
                        : Text(
                            emoji,
                            style: const TextStyle(fontSize: 48),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: AppTextStyles.extraBold.copyWith(fontSize: 22, color: AppColors.darkText),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: AppTextStyles.medium.copyWith(color: AppColors.hintText, height: 1.5, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: iconColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Okay',
                      style: AppTextStyles.bold.copyWith(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 200),
    );
  }
}
