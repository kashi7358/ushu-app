import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../controllers/auth_controller.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Mail / OTP Illustration
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.xl),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mark_email_read_rounded,
                        size: 80,
                        color: AppColors.primaryPurple,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.xxl),
                    
                    // Heading
                    Text(
                      'Verify Your Email',
                      style: AppTextStyles.extraBold.copyWith(fontSize: 28),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.md),
                    
                    // Subheading
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sm),
                      child: Text(
                        'We have sent a 6-digit verification code to your email address. Enter it below.',
                        style: AppTextStyles.regular.copyWith(
                          color: AppColors.hintText,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.xxl),
                    
                    // Styled OTP TextField
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: controller.otpController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 6,
                        style: AppTextStyles.extraBold.copyWith(
                          fontSize: 24,
                          letterSpacing: 16.0,
                          color: AppColors.primaryPurple,
                        ),
                        decoration: InputDecoration(
                          counterText: "",
                          hintText: '------',
                          hintStyle: AppTextStyles.extraBold.copyWith(
                            fontSize: 24,
                            letterSpacing: 16.0,
                            color: AppColors.hintText.withOpacity(0.5),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: AppColors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 20),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.xl),
                    
                    // Verify Button
                    Obx(() => AppButton(
                      text: 'Verify Account',
                      onPressed: controller.verifyEmail,
                      isLoading: controller.isLoading.value,
                    )),
                    
                    const SizedBox(height: AppDimensions.xxl),
                    
                    // Resend Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Didn't receive the code? ",
                          style: AppTextStyles.regular.copyWith(color: AppColors.hintText),
                        ),
                        GestureDetector(
                          onTap: controller.resendOtp,
                          child: Text(
                            'Resend OTP',
                            style: AppTextStyles.semiBold.copyWith(color: AppColors.accentOrange),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.lg),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
