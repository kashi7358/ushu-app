import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../controllers/auth_controller.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primaryPurple),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 50),
                child: Form(
                  key: controller.forgetPasswordFormKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Lock Icon / Illustration Graphic
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.xl),
                        decoration: BoxDecoration(
                          color: AppColors.primaryPurple.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_reset_rounded,
                          size: 80,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.xxl),
                      
                      // Heading
                      Text(
                        'Forgot Password?',
                        style: AppTextStyles.extraBold.copyWith(fontSize: 28),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDimensions.md),
                      
                      // Subheading
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sm),
                        child: Text(
                          'No worries! Enter your registered email address and we will send you a secure password reset link.',
                          style: AppTextStyles.regular.copyWith(
                            color: AppColors.hintText,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.xxl),
                      
                      // Email Input
                      AppTextField(
                        controller: controller.forgetPasswordEmailController,
                        hintText: 'Enter your email',
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.validateEmail,
                        prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primaryPurple),
                      ),
                      const SizedBox(height: AppDimensions.xl),
                      
                      // Submit Button
                      Obx(() => AppButton(
                        text: 'Send Reset Link',
                        onPressed: controller.forgetPassword,
                        isLoading: controller.isLoading.value,
                      )),
                      
                      const SizedBox(height: AppDimensions.xxl),
                      
                      // Back to login helper
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Remember your password? ",
                            style: AppTextStyles.regular.copyWith(color: AppColors.hintText),
                          ),
                          GestureDetector(
                            onTap: () => Get.back(),
                            child: Text(
                              'Log In',
                              style: AppTextStyles.semiBold.copyWith(color: AppColors.accentOrange),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.lg),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
