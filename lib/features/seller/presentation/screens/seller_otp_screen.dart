import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../controllers/seller_otp_controller.dart';

class SellerOtpScreen extends StatelessWidget {
  const SellerOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SellerOtpController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Email Verification',
          style: AppTextStyles.bold.copyWith(color: AppColors.darkText, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Email / Security Illustration Container
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_read_outlined,
                  size: 46,
                  color: AppColors.primaryPurple,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Verify Seller Email',
                style: AppTextStyles.extraBold.copyWith(
                  fontSize: 22,
                  color: AppColors.darkText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the 6-digit verification code sent to',
                style: AppTextStyles.medium.copyWith(fontSize: 13, color: AppColors.hintText),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // Compact Email Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.email_outlined, size: 15, color: AppColors.primaryPurple),
                    const SizedBox(width: 6),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 240),
                      child: Text(
                        controller.email.isNotEmpty ? controller.email : 'your email',
                        style: AppTextStyles.bold.copyWith(fontSize: 13, color: AppColors.primaryPurple),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // 6-digit OTP Box Input
              _buildOtpPinInput(controller),
              const SizedBox(height: 24),
              // Resend Timer Row
              Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive code? ",
                    style: AppTextStyles.medium.copyWith(fontSize: 13, color: AppColors.hintText),
                  ),
                  controller.isResendEnabled.value
                      ? GestureDetector(
                          onTap: controller.resendOtp,
                          child: Text(
                            'Resend Code',
                            style: AppTextStyles.bold.copyWith(fontSize: 13, color: AppColors.primaryPurple),
                          ),
                        )
                      : Text(
                          'Resend in ${controller.resendTimer.value}s',
                          style: AppTextStyles.bold.copyWith(fontSize: 13, color: AppColors.accentOrange),
                        ),
                ],
              )),
              const SizedBox(height: 36),
              Obx(() => AppButton(
                text: 'Verify & Continue',
                isLoading: controller.isLoading.value,
                onPressed: controller.verifyOtp,
              )),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpPinInput(SellerOtpController controller) {
    return Obx(() {
      final text = controller.otpText.value;
      return GestureDetector(
        onTap: () {
          controller.otpFocusNode.requestFocus();
        },
        behavior: HitTestBehavior.opaque,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Visual 6 pin boxes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                final isFilled = index < text.length;
                final isCurrent = index == text.length;
                final digit = isFilled ? text[index] : '';

                return Container(
                  width: 48,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? Colors.white
                        : (isFilled ? AppColors.primaryPurple.withValues(alpha: 0.04) : Colors.grey.shade50),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCurrent
                          ? AppColors.primaryPurple
                          : (isFilled ? AppColors.primaryPurple.withValues(alpha: 0.5) : Colors.grey.shade300),
                      width: isCurrent ? 2.0 : 1.2,
                    ),
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: AppColors.primaryPurple.withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  alignment: Alignment.center,
                  child: isCurrent && text.length < 6
                      ? Container(
                          width: 2.2,
                          height: 22,
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        )
                      : Text(
                          digit,
                          style: AppTextStyles.extraBold.copyWith(
                            fontSize: 22,
                            color: AppColors.primaryPurple,
                          ),
                        ),
                );
              }),
            ),
            // Hidden transparent textfield that captures keyboard input
            Opacity(
              opacity: 0.0,
              child: TextField(
                controller: controller.otpController,
                focusNode: controller.otpFocusNode,
                autofocus: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
