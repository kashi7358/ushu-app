import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/seller_login_controller.dart';

class SellerLoginScreen extends StatelessWidget {
  const SellerLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SellerLoginController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Get.back(),
        ),
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
                  const SizedBox(height: 28),
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
                    validator: Validators.validatePassword,
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
    );
  }
}
