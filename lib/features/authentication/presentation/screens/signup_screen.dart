import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Form(
              key: controller.signupFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Logo Clean Header
                  const Center(
                    child: AppLogo(height: 115),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Create Account',
                    style: AppTextStyles.extraBold.copyWith(
                      fontSize: 22,
                      color: AppColors.darkText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Join USHU as a Customer',
                    style: AppTextStyles.medium.copyWith(
                      fontSize: 13,
                      color: AppColors.hintText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Buyer / Seller Role Toggle Switcher
                  _buildRoleToggle(
                    isBuyer: true,
                    onRoleChanged: (isBuyerSelected) {
                      if (!isBuyerSelected) {
                        Get.offNamed(AppRoutes.sellerRegister);
                      }
                    },
                  ),

                  const SizedBox(height: 8),
                  AppTextField(
                    controller: controller.signupNameController,
                    hintText: 'Full Name',
                    validator: Validators.validateName,
                    prefixIcon: const Icon(Icons.person_outline, color: AppColors.primaryPurple, size: 22),
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: controller.signupEmailController,
                    hintText: 'Email address',
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                    prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primaryPurple, size: 22),
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: controller.signupPhoneController,
                    hintText: 'Phone number (11 digits)',
                    keyboardType: TextInputType.phone,
                    validator: Validators.validatePhone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(11),
                    ],
                    prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.primaryPurple, size: 22),
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: controller.signupAddressController,
                    hintText: 'Delivery address',
                    maxLines: 2,
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 20.0),
                      child: Icon(Icons.location_on_outlined, color: AppColors.primaryPurple, size: 22),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Obx(() => AppTextField(
                    controller: controller.signupPasswordController,
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
                  const SizedBox(height: 14),
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
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryPurple, size: 22),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isConfirmPasswordVisible.value 
                          ? Icons.visibility_outlined 
                          : Icons.visibility_off_outlined,
                        color: AppColors.hintText,
                        size: 20,
                      ),
                      onPressed: controller.toggleConfirmPasswordVisibility,
                    ),
                  )),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Obx(() => SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: controller.termsAccepted.value,
                          onChanged: (val) => controller.toggleTerms(),
                          activeColor: AppColors.primaryPurple,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                      )),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: controller.toggleTerms,
                          child: Text(
                            'I agree to the Terms and Conditions',
                            style: AppTextStyles.medium.copyWith(fontSize: 13, color: AppColors.darkText),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Obx(() => AppButton(
                    text: 'Sign Up',
                    onPressed: controller.signup,
                    isLoading: controller.isLoading.value,
                  )),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: AppTextStyles.regular.copyWith(fontSize: 14, color: AppColors.hintText),
                      ),
                      GestureDetector(
                        onTap: controller.navigateToLogin,
                        child: Text(
                          'Login',
                          style: AppTextStyles.bold.copyWith(fontSize: 14, color: AppColors.primaryPurple),
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
                        'Buyer Sign Up',
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
                        'Seller Sign Up',
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
