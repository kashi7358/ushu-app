import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: controller.loginFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  // App Logo Clean Header
                  const Center(
                    child: AppLogo(height: 85),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Welcome Back',
                    style: AppTextStyles.extraBold.copyWith(
                      fontSize: 24,
                      color: AppColors.darkText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Login to your USHU BUY account',
                    style: AppTextStyles.medium.copyWith(
                      fontSize: 14,
                      color: AppColors.hintText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  AppTextField(
                    controller: controller.loginEmailController,
                    hintText: 'Email address',
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                    prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primaryPurple, size: 22),
                  ),
                  const SizedBox(height: 16),
                  Obx(() => AppTextField(
                    controller: controller.loginPasswordController,
                    hintText: 'Password',
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
                    text: 'Login',
                    onPressed: controller.login,
                    isLoading: controller.isLoading.value,
                  )),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: AppTextStyles.regular.copyWith(
                          fontSize: 14,
                          color: AppColors.hintText,
                        ),
                      ),
                      GestureDetector(
                        onTap: controller.navigateToSignup,
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
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
