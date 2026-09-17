import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: Form(
              key: controller.loginFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: AppLogo(size: 100)),
                  const SizedBox(height: AppDimensions.xl),
                  Text(
                    'Welcome Back',
                    style: AppTextStyles.extraBold,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Text(
                    'Login to continue using USHU',
                    style: AppTextStyles.regular.copyWith(color: AppColors.hintText),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.xl),
                  AppTextField(
                    controller: controller.loginEmailController,
                    hintText: 'Email or Phone',
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail, // assuming email for now
                    prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primaryPurple),
                  ),
                  const SizedBox(height: AppDimensions.md),
                  Obx(() => AppTextField(
                    controller: controller.loginPasswordController,
                    hintText: 'Password',
                    isPassword: !controller.isPasswordVisible.value,
                    validator: Validators.validatePassword,
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryPurple),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isPasswordVisible.value 
                          ? Icons.visibility 
                          : Icons.visibility_off,
                        color: AppColors.hintText,
                      ),
                      onPressed: controller.togglePasswordVisibility,
                    ),
                  )),
                  const SizedBox(height: AppDimensions.sm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: controller.navigateToForgetPassword,
                      child: Text(
                        'Forgot Password?',
                        style: AppTextStyles.semiBold.copyWith(color: AppColors.accentOrange),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.lg),
                  Obx(() => AppButton(
                    text: 'Login',
                    onPressed: controller.login,
                    isLoading: controller.isLoading.value,
                  )),
                  const SizedBox(height: AppDimensions.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: AppTextStyles.regular,
                      ),
                      GestureDetector(
                        onTap: controller.navigateToSignup,
                        child: Text(
                          'Sign Up',
                          style: AppTextStyles.semiBold.copyWith(color: AppColors.primaryPurple),
                        ),
                      ),
                    ],
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
