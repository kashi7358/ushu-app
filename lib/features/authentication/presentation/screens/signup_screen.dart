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

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: Form(
              key: controller.signupFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: AppLogo(size: 80)),
                  const SizedBox(height: AppDimensions.lg),
                  Text(
                    'Create Account',
                    style: AppTextStyles.extraBold,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Text(
                    'Join USHU as a Buyer',
                    style: AppTextStyles.regular.copyWith(color: AppColors.hintText),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.xl),
                  AppTextField(
                    controller: controller.signupNameController,
                    hintText: 'Full Name',
                    validator: Validators.validateName,
                    prefixIcon: const Icon(Icons.person_outline, color: AppColors.primaryPurple),
                  ),
                  const SizedBox(height: AppDimensions.md),
                  AppTextField(
                    controller: controller.signupEmailController,
                    hintText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                    prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primaryPurple),
                  ),
                  const SizedBox(height: AppDimensions.md),
                  AppTextField(
                    controller: controller.signupPhoneController,
                    hintText: 'Phone',
                    keyboardType: TextInputType.phone,
                    validator: Validators.validatePhone,
                    prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.primaryPurple),
                  ),
                  const SizedBox(height: AppDimensions.md),
                  AppTextField(
                    controller: controller.signupAddressController,
                    hintText: 'Address',
                    maxLines: 3,
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 30.0),
                      child: Icon(Icons.location_on_outlined, color: AppColors.primaryPurple),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.md),
                  Obx(() => AppTextField(
                    controller: controller.signupPasswordController,
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
                  const SizedBox(height: AppDimensions.md),
                  Obx(() => AppTextField(
                    controller: controller.signupConfirmPasswordController,
                    hintText: 'Confirm Password',
                    isPassword: !controller.isConfirmPasswordVisible.value,
                    validator: (val) {
                      if (val != controller.signupPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return Validators.validatePassword(val);
                    },
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryPurple),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isConfirmPasswordVisible.value 
                          ? Icons.visibility 
                          : Icons.visibility_off,
                        color: AppColors.hintText,
                      ),
                      onPressed: controller.toggleConfirmPasswordVisibility,
                    ),
                  )),
                  const SizedBox(height: AppDimensions.md),
                  Row(
                    children: [
                      Obx(() => Checkbox(
                        value: controller.termsAccepted.value,
                        onChanged: (val) => controller.toggleTerms(),
                        activeColor: AppColors.primaryPurple,
                      )),
                      Expanded(
                        child: Text(
                          'I agree to the Terms and Conditions',
                          style: AppTextStyles.regular,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.lg),
                  Obx(() => AppButton(
                    text: 'Sign Up',
                    onPressed: controller.signup,
                    isLoading: controller.isLoading.value,
                  )),
                  const SizedBox(height: AppDimensions.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: AppTextStyles.regular,
                      ),
                      GestureDetector(
                        onTap: controller.navigateToLogin,
                        child: Text(
                          'Login',
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
