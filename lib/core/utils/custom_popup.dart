import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_text_styles.dart';

class CustomPopup {
  static void showSuccess(String title, String message) {
    _showDialog(
      title: title,
      message: message,
      icon: Icons.check_circle_rounded,
      iconColor: AppColors.success,
      emoji: '🎉',
    );
  }

  static void showError(String title, String message) {
    _showDialog(
      title: title,
      message: message,
      icon: Icons.error_rounded,
      iconColor: AppColors.error,
      emoji: '⚠️',
    );
  }

  static void _showDialog({
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
    required String emoji,
  }) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: TweenAnimationBuilder(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutBack,
          tween: Tween<double>(begin: 0.5, end: 1.0),
          builder: (context, double scale, child) {
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.lg),
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
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
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
                const SizedBox(height: AppDimensions.lg),
                Text(
                  title,
                  style: AppTextStyles.bold.copyWith(fontSize: 22, color: AppColors.darkText),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.sm),
                Text(
                  message,
                  style: AppTextStyles.regular.copyWith(color: AppColors.hintText, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.xl),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: iconColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Got it',
                      style: AppTextStyles.semiBold.copyWith(color: AppColors.white),
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
