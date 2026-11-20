import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/seller_login_controller.dart';

import '../../../../core/utils/session_manager.dart';
import '../../../../core/utils/custom_popup.dart';
import '../../../../app/routes/app_routes.dart';

class SellerLoginScreen extends StatelessWidget {
  const SellerLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SellerLoginController());

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final confirm = await CustomPopup.showSwitchToBuyerConfirmation();
        if (confirm ?? false) {
          SessionManager.setLastScreen(null);
          if (context.mounted) {
            if (Navigator.of(context).canPop()) {
              Get.back();
            } else {
              Get.offAllNamed(AppRoutes.mainLayout);
            }
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            'Seller Center',
            style: AppTextStyles.bold.copyWith(color: AppColors.darkText, fontSize: 17),
          ),
          centerTitle: true,
        ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: controller.formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(
                    child: AppLogo(height: 115),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Welcome to Seller Center',
                    style: AppTextStyles.extraBold.copyWith(
                      fontSize: 23,
                      color: AppColors.darkText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage your store, track sales, and grow your business',
                    style: AppTextStyles.medium.copyWith(
                      fontSize: 13,
                      color: AppColors.hintText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Buyer / Seller Role Toggle Switcher
                  _buildRoleToggle(
                    isBuyer: false,
                    onRoleChanged: (isBuyerSelected) {
                      if (isBuyerSelected) {
                        Get.offNamed(AppRoutes.login);
                      }
                    },
                  ),

                  const SizedBox(height: 8),
                  AppTextField(
                    controller: controller.emailController,
                    hintText: 'Seller Email Address',
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                    prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primaryPurple, size: 22),
                  ),
                  const SizedBox(height: 16),
                  Obx(() => AppTextField(
                    controller: controller.passwordController,
                    hintText: 'Seller Password',
                    isPassword: !controller.isPasswordVisible.value,
                    validator: Validators.validateLoginPassword,
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryPurple, size: 22),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isPasswordVisible.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.hintText,
                        size: 20,
                      ),
                      onPressed: controller.togglePasswordVisibility,
                    ),
                  )),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: controller.navigateToForgetPassword,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Forgot Password?',
                        style: AppTextStyles.bold.copyWith(
                          fontSize: 13,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Obx(() => AppButton(
                    text: 'Login to Seller Center',
                    isLoading: controller.isLoading.value,
                    onPressed: controller.login,
                  )),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have a seller account? ",
                        style: AppTextStyles.regular.copyWith(
                          fontSize: 14,
                          color: AppColors.hintText,
                        ),
                      ),
                      GestureDetector(
                        onTap: controller.navigateToRegister,
                        child: Text(
                          'Sign Up',
                          style: AppTextStyles.bold.copyWith(
                            fontSize: 14,
                            color: AppColors.primaryPurple,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildRoleToggle({required bool isBuyer, required Function(bool) onRoleChanged}) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onRoleChanged(true),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isBuyer ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isBuyer
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 18,
                        color: isBuyer ? AppColors.primaryPurple : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Buyer Login',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: isBuyer ? FontWeight.w700 : FontWeight.w500,
                          color: isBuyer ? AppColors.primaryPurple : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onRoleChanged(false),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: !isBuyer ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: !isBuyer
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.storefront_outlined,
                        size: 18,
                        color: !isBuyer ? AppColors.primaryPurple : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Seller Login',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: !isBuyer ? FontWeight.w700 : FontWeight.w500,
                          color: !isBuyer ? AppColors.primaryPurple : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
