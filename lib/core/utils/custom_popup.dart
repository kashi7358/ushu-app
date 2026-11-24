import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
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
        insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: _ProLoadingWidget(message: message),
      ),
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.40),
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
    bool barrierDismissible = true,
  }) {
    _showProDialog(
      title: title,
      message: message,
      icon: Icons.check_rounded,
      accentColor: const Color(0xFF10B981),
      buttonText: buttonText,
      onConfirm: onConfirm,
      barrierDismissible: barrierDismissible,
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
    VoidCallback? onConfirm,
    String buttonText = 'Okay',
    bool barrierDismissible = true,
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
                constraints: BoxConstraints(
                  maxHeight: Get.height * 0.78,
                ),
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
                    const SizedBox(height: 12),
                    Flexible(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Text(
                          message,
                          style: const TextStyle(
                            fontSize: 13.0,
                            color: Color(0xFF64748B),
                            height: 1.45,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          onConfirm?.call();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          shadowColor: accentColor.withValues(alpha: 0.35),
                        ),
                        child: Text(
                          buttonText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.2,
                            height: 1.15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Signature Floating Avatar Badge with Spring Bounce Animation
              Positioned(
                top: 0,
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.elasticOut,
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  builder: (context, scale, child) {
                    return Transform.scale(scale: scale, child: child);
                  },
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
                      child: Icon(icon, color: Colors.white, size: 38),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: barrierDismissible,
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
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: OutlinedButton(
                              onPressed: () => Get.back(result: false),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF475569),
                                side: const BorderSide(color: Color(0xFFE2E8F0)),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
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
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () => Get.back(result: true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDanger ? const Color(0xFFEF4444) : accentColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  confirmText,
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
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

  /// Confirmation dialog before switching from Seller to Buyer panel
  static Future<bool?> showSwitchToBuyerConfirmation() {
    return _showProConfirmDialog(
      title: 'Switch to Buyer Panel?',
      message: 'Are you sure you want to leave the Seller Center and go to the Buyer shopping experience?',
      icon: Icons.shopping_bag_outlined,
      accentColor: AppColors.primaryPurple,
      confirmText: 'Switch to Buyer',
      cancelText: 'Stay in Seller',
    );
  }

  static Future<String?> showDeleteAccountDialog({
    required String title,
    required String message,
  }) {
    final passwordController = TextEditingController();
    final isPasswordVisible = false.obs;
    final errorMessage = ''.obs;

    return Get.dialog<String?>(
      Builder(builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
                  padding: const EdgeInsets.fromLTRB(22, 52, 22, 22),
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
                  child: SingleChildScrollView(
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
                            fontSize: 13,
                            color: Color(0xFF64748B),
                            height: 1.45,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 18),
                        Obx(() => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  controller: passwordController,
                                  obscureText: !isPasswordVisible.value,
                                  decoration: InputDecoration(
                                    hintText: 'Enter your password to confirm',
                                    hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                                    prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: Color(0xFF64748B)),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        isPasswordVisible.value ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                        size: 20,
                                        color: const Color(0xFF64748B),
                                      ),
                                      onPressed: () => isPasswordVisible.toggle(),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                                    ),
                                  ),
                                  onChanged: (_) {
                                    if (errorMessage.isNotEmpty) errorMessage.value = '';
                                  },
                                ),
                                if (errorMessage.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    errorMessage.value,
                                    style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ],
                            )),
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: OutlinedButton(
                                  onPressed: () => Get.back(result: null),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF475569),
                                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontSize: 14,
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
                                  onPressed: () {
                                    final pwd = passwordController.text.trim();
                                    if (pwd.isEmpty) {
                                      errorMessage.value = 'Password is required to delete account';
                                      return;
                                    }
                                    Get.back(result: pwd);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFEF4444),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
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
                          color: const Color(0xFFEF4444).withValues(alpha: 0.35),
                          blurRadius: 22,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(4.5),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFEF4444),
                            Color(0xFFDC2626),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Icon(Icons.delete_forever_rounded, color: Colors.white, size: 36),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
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

  static OverlayEntry? _lottieOverlay;
  static Completer<void>? _lottieCompleter;
  static Timer? _lottieSafetyTimer;

  static Future<void> showFastLottie(
    String lottieAsset, {
    double width = 120,
    double height = 120,
    double speed = 1.0,
  }) {
    hideFastLottie();

    final context = Get.overlayContext ?? Get.context;
    if (context == null) return Future.value();

    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return Future.value();

    final completer = Completer<void>();
    _lottieCompleter = completer;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _FastLottieOverlayWidget(
        lottieAsset: lottieAsset,
        width: width,
        height: height,
        speed: speed,
        onCompleted: () => _removeLottieEntry(entry, completer),
      ),
    );

    _lottieOverlay = entry;
    overlay.insert(entry);

    _lottieSafetyTimer = Timer(const Duration(milliseconds: 5000), () {
      _removeLottieEntry(entry, completer);
    });

    return completer.future;
  }

  static void _removeLottieEntry(
    OverlayEntry entry,
    Completer<void> completer,
  ) {
    if (identical(_lottieOverlay, entry)) {
      _lottieSafetyTimer?.cancel();
      _lottieSafetyTimer = null;
      _lottieOverlay = null;
      if (identical(_lottieCompleter, completer)) {
        _lottieCompleter = null;
      }
    }
    try {
      if (entry.mounted) {
        entry.remove();
      }
    } catch (_) {}
    if (!completer.isCompleted) {
      completer.complete();
    }
  }

  static void hideFastLottie() {
    _lottieSafetyTimer?.cancel();
    _lottieSafetyTimer = null;

    final entry = _lottieOverlay;
    final completer = _lottieCompleter;
    _lottieOverlay = null;
    _lottieCompleter = null;

    try {
      if (entry != null && entry.mounted) {
        entry.remove();
      }
    } catch (_) {}
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
  }
}

class _FastLottieOverlayWidget extends StatefulWidget {
  final String lottieAsset;
  final double width;
  final double height;
  final double speed;
  final VoidCallback onCompleted;

  const _FastLottieOverlayWidget({
    required this.lottieAsset,
    required this.width,
    required this.height,
    required this.speed,
    required this.onCompleted,
  });

  @override
  State<_FastLottieOverlayWidget> createState() =>
      _FastLottieOverlayWidgetState();
}

class _FastLottieOverlayWidgetState extends State<_FastLottieOverlayWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _hasCompleted = false;
  Timer? _fallbackErrorTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_hasCompleted) {
        _hasCompleted = true;
        widget.onCompleted();
      }
    });
  }

  @override
  void dispose() {
    _fallbackErrorTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _triggerFallbackDismiss() {
    if (_hasCompleted || _fallbackErrorTimer != null) return;
    _fallbackErrorTimer = Timer(const Duration(milliseconds: 900), () {
      if (mounted && !_hasCompleted) {
        _hasCompleted = true;
        widget.onCompleted();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.15),
      child: Center(
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutBack,
          tween: Tween<double>(begin: 0.6, end: 1.0),
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
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Lottie.asset(
              widget.lottieAsset,
              controller: _controller,
              width: widget.width,
              height: widget.height,
              repeat: false,
              onLoaded: (composition) {
                if (!mounted || _hasCompleted) return;
                final safeSpeed = widget.speed <= 0 ? 1.0 : widget.speed;
                final rawMs = composition.duration.inMilliseconds;
                final effectiveMs =
                    (rawMs > 0 ? (rawMs / safeSpeed).round() : 1200)
                        .clamp(300, 4800);
                _controller.duration = Duration(milliseconds: effectiveMs);
                _controller.forward(from: 0.0);
              },
              errorBuilder: (_, __, ___) {
                _triggerFallbackDismiss();
                return const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primaryPurple,
                  size: 60,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// =========================================================================
// ULTRA-PREMIUM PROFESSIONAL LOADING WIDGET
// =========================================================================

class _ProLoadingWidget extends StatefulWidget {
  final String message;
  const _ProLoadingWidget({required this.message});

  @override
  State<_ProLoadingWidget> createState() => _ProLoadingWidgetState();
}

class _ProLoadingWidgetState extends State<_ProLoadingWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutBack,
        tween: Tween<double>(begin: 0.8, end: 1.0),
        builder: (context, scale, child) {
          return Transform.scale(scale: scale, child: child);
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              width: 270,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: AppColors.primaryPurple.withValues(alpha: 0.12),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.12),
                    blurRadius: 36,
                    offset: const Offset(0, 14),
                  ),
                  BoxShadow(
                    color: AppColors.primaryPurple.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated Rotating Dual-Gradient Spinner
                  SizedBox(
                    width: 62,
                    height: 62,
                    child: AnimatedBuilder(
                      animation: _animController,
                      builder: (context, _) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // Custom Painter Arc
                            CustomPaint(
                              size: const Size(62, 62),
                              painter: _DualRingSpinnerPainter(
                                progress: _animController.value,
                              ),
                            ),
                            // Pulsing Center Glowing Core
                            Transform.scale(
                              scale: 0.88 + 0.12 * math.sin(_animController.value * math.pi * 2),
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF6B46C1),
                                      Color(0xFF9333EA),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF6B46C1).withValues(alpha: 0.35),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.bolt_rounded,
                                    color: Colors.white,
                                    size: 19,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Message Title
                  Text(
                    widget.message,
                    style: AppTextStyles.bold.copyWith(
                      color: const Color(0xFF0F172A),
                      fontSize: 14.5,
                      letterSpacing: -0.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Animated Status / Subtitle with pulsing opacity
                  AnimatedBuilder(
                    animation: _animController,
                    builder: (context, _) {
                      final opacity = 0.45 + 0.55 * (0.5 + 0.5 * math.sin(_animController.value * math.pi * 2));
                      return Opacity(
                        opacity: opacity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryPurple,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Processing, please wait...',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------------
// Custom Painter for 360 Sweep-Gradient Smooth Arc
// -------------------------------------------------------------------------
class _DualRingSpinnerPainter extends CustomPainter {
  final double progress;
  _DualRingSpinnerPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 4;

    // Subtle Track Ring
    final trackPaint = Paint()
      ..color = const Color(0xFF6B46C1).withValues(alpha: 0.10)
      ..strokeWidth = 3.6
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, trackPaint);

    // Glowing Gradient Arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    final startAngle = progress * math.pi * 2;
    const sweepAngle = math.pi * 1.55;

    final gradient = SweepGradient(
      startAngle: 0.0,
      endAngle: math.pi * 2,
      colors: const [
        Color(0x006B46C1),
        Color(0xFFC084FC),
        Color(0xFF9333EA),
        Color(0xFF6B46C1),
      ],
      stops: const [0.0, 0.4, 0.75, 1.0],
      transform: GradientRotation(startAngle),
    );

    final arcPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(rect, startAngle, sweepAngle, false, arcPaint);
  }

  @override
  bool shouldRepaint(covariant _DualRingSpinnerPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
