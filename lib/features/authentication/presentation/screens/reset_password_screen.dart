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

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryPurple),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: Form(
              key: controller.resetPasswordFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: AppLogo(size: 80)),
                  const SizedBox(height: AppDimensions.xl),
                  Text(
                    'Reset Password',
                    style: AppTextStyles.extraBold,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Text(
                    'Enter the reset token sent to your email and your new password.',
                    style: AppTextStyles.regular.copyWith(color: AppColors.hintText),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.xl),
                  AppTextField(
                    controller: controller.resetTokenController,
                    hintText: 'Reset Token',
                    validator: (val) => val == null || val.isEmpty ? 'Token is required' : null,
                    prefixIcon: const Icon(Icons.key, color: AppColors.primaryPurple),
                  ),
                  const SizedBox(height: AppDimensions.md),
                  Obx(() => AppTextField(
                    controller: controller.resetNewPasswordController,
                    hintText: 'New Password',
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
                  const SizedBox(height: AppDimensions.lg),
                  Obx(() => AppButton(
                    text: 'Confirm Reset',
                    onPressed: controller.resetPassword,
                    isLoading: controller.isLoading.value,
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
