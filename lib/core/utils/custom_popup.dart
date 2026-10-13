import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

class CustomPopup {
  // ==========================================
  // LOADING PRO DIALOG
  // ==========================================

  static void showLoading([String message = 'Please wait...']) {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            tween: Tween<double>(begin: 0.7, end: 1.0),
            builder: (context, scale, child) {
              return Transform.scale(scale: scale, child: child);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 26),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.14),
                    blurRadius: 32,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          strokeWidth: 3.5,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryPurple),
                          backgroundColor: AppColors.primaryPurple.withValues(alpha: 0.12),
                        ),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryPurple.withValues(alpha: 0.15),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    message,
                    style: AppTextStyles.bold.copyWith(
                      color: const Color(0xFF0F172A),
                      fontSize: 14.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.45),
    );
  }

  static void hideLoading() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  // ==========================================
  // SUCCESS, ERROR & WARNING PRO DIALOGS
  // ==========================================

  static void showSuccess(
    String title,
    String message, {
    VoidCallback? onConfirm,
    String buttonText = 'Continue',
  }) {
    _showProDialog(
      title: title,
      message: message,
      icon: Icons.check_rounded,
      accentColor: const Color(0xFF10B981),
      lottieAsset: 'assets/lotties/done.json',
      buttonText: buttonText,
      onConfirm: onConfirm,
    );
  }

  static void showError(
    String title,
    String message, {
    VoidCallback? onConfirm,
    String buttonText = 'Okay',
  }) {
    _showProDialog(
      title: title,
      message: message,
      icon: Icons.close_rounded,
      accentColor: const Color(0xFFEF4444),
      buttonText: buttonText,
      onConfirm: onConfirm,
    );
  }

  static void showWarning(
    String title,
    String message, {
    VoidCallback? onConfirm,
    String buttonText = 'Understood',
  }) {
    _showProDialog(
      title: title,
      message: message,
      icon: Icons.priority_high_rounded,
      accentColor: const Color(0xFFF59E0B),
      buttonText: buttonText,
      onConfirm: onConfirm,
    );
  }

  static void showInfo(
    String title,
    String message, {
    VoidCallback? onConfirm,
    String buttonText = 'Got It',
  }) {
    _showProDialog(
      title: title,
      message: message,
      icon: Icons.info_outline_rounded,
      accentColor: const Color(0xFF3B82F6),
      buttonText: buttonText,
      onConfirm: onConfirm,
    );
  }

  // ==========================================
  // PRO DIALOG CORE ENGINE (FLOATING BADGE LOOK)
  // ==========================================

  static void _showProDialog({
    required String title,
    required String message,
    required IconData icon,
    required Color accentColor,
    String? lottieAsset,
    VoidCallback? onConfirm,
    String buttonText = 'Okay',
  }) {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 26, vertical: 24),
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 360),
          curve: Curves.easeOutBack,
          tween: Tween<double>(begin: 0.65, end: 1.0),
          builder: (context, scale, child) {
            return Transform.scale(scale: scale, child: child);
          },
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              // Main Rounded Card
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 38),
                padding: const EdgeInsets.fromLTRB(22, 54, 22, 22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.14),
                      blurRadius: 36,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.extraBold.copyWith(
                        fontSize: 19.5,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF64748B),
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          onConfirm?.call();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          shadowColor: accentColor.withValues(alpha: 0.35),
                        ),
                        child: Text(
                          buttonText,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Signature Floating Avatar Badge
              Positioned(
                top: 0,
                child: Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.35),
                        blurRadius: 22,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(4.5),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          accentColor,
                          accentColor.withValues(alpha: 0.85),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: lottieAsset != null
                        ? ClipOval(
                            child: Lottie.asset(
                              lottieAsset,
                              repeat: false,
                              errorBuilder: (_, __, ___) => Icon(icon, color: Colors.white, size: 38),
                            ),
                          )
                        : Icon(icon, color: Colors.white, size: 38),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
    );
  }

  // ==========================================
  // CONFIRMATION PRO DIALOGS
  // ==========================================

  static Future<bool?> _showProConfirmDialog({
    required String title,
    required String message,
    required IconData icon,
    required Color accentColor,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDanger = false,
  }) {
    return Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 26, vertical: 24),
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 360),
          curve: Curves.easeOutBack,
          tween: Tween<double>(begin: 0.65, end: 1.0),
          builder: (context, scale, child) {
            return Transform.scale(scale: scale, child: child);
          },
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              // Main Card
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 38),
                padding: const EdgeInsets.fromLTRB(22, 54, 22, 22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.14),
                      blurRadius: 36,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.extraBold.copyWith(
                        fontSize: 19.5,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF64748B),
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () => Get.back(result: false),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF475569),
                                side: const BorderSide(color: Color(0xFFE2E8F0)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                cancelText,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () => Get.back(result: true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDanger ? const Color(0xFFEF4444) : accentColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                confirmText,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Floating Icon Avatar
              Positioned(
                top: 0,
                child: Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.35),
                        blurRadius: 22,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(4.5),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          accentColor,
                          accentColor.withValues(alpha: 0.85),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Icon(icon, color: Colors.white, size: 36),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
    );
  }

  static Future<bool?> showLogoutConfirmation() {
    return _showProConfirmDialog(
      title: 'Logout Account',
      message: 'Are you sure you want to logout from your seller session?',
      icon: Icons.logout_rounded,
      accentColor: const Color(0xFFEF4444),
      confirmText: 'Logout',
      cancelText: 'Stay Logged In',
      isDanger: true,
    );
  }

  static Future<bool?> showExitConfirmation() {
    return _showProConfirmDialog(
      title: 'Exit Application?',
      message: 'Are you sure you want to close and exit the app?',
      icon: Icons.power_settings_new_rounded,
      accentColor: const Color(0xFFEF4444),
      confirmText: 'Exit App',
      cancelText: 'Stay',
      isDanger: true,
    );
  }

  static Future<bool?> showClearHistoryConfirmation() {
    return _showProConfirmDialog(
      title: 'Clear History?',
      message: 'This will permanently remove all your recently viewed products from history.',
      icon: Icons.delete_sweep_rounded,
      accentColor: const Color(0xFFEF4444),
      confirmText: 'Clear All',
      cancelText: 'Cancel',
      isDanger: true,
    );
  }

  static void showLoginRequired() {
    _showProConfirmDialog(
      title: 'Login Required',
      message: 'Please login to perform this action and enjoy full features.',
      icon: Icons.lock_outline_rounded,
      accentColor: AppColors.primaryPurple,
      confirmText: 'Login Now',
      cancelText: 'Cancel',
    ).then((confirmed) {
      if (confirmed == true) {
        Get.toNamed('/login');
      }
    });
  }

  // ==========================================
  // FLOATING TOASTS & SNACKBARS
  // ==========================================

  static void showToast(String title, String message, {bool isError = false}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
      colorText: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      borderRadius: 14,
      duration: const Duration(seconds: 3),
      icon: Icon(
        isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
        color: Colors.white,
        size: 24,
      ),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack,
      boxShadows: [
        BoxShadow(
          color: (isError ? const Color(0xFFEF4444) : const Color(0xFF10B981)).withValues(alpha: 0.35),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  static void showFastLottie(String lottieAsset, {double width = 120, double height = 120}) {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
    Get.dialog(
      Center(
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          curve: Curves.elasticOut,
          tween: Tween<double>(begin: 0.5, end: 1.0),
          builder: (context, scale, child) {
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
                ),
              ],
            ),
            child: Lottie.asset(
              lottieAsset,
              width: width,
              height: height,
              repeat: false,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primaryPurple,
                size: 60,
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.1),
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    });
  }
}
