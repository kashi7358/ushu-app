import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';

class SellerPendingApprovalScreen extends StatelessWidget {
  const SellerPendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Get.offAllNamed(AppRoutes.mainLayout),
        ),
        title: Text(
          'Seller Verification',
          style: AppTextStyles.bold.copyWith(color: AppColors.darkText, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Icon / Visual
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.accentOrange.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_top_rounded,
                  size: 50,
                  color: AppColors.accentOrange,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accentOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.accentOrange.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'APPLICATION UNDER REVIEW',
                  style: AppTextStyles.bold.copyWith(
                    color: AppColors.accentOrange,
                    fontSize: 12,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Registration Submitted!',
                style: AppTextStyles.extraBold.copyWith(
                  fontSize: 22,
                  color: AppColors.darkText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Thank you for registering to become a seller on USHU! Our compliance and admin team is reviewing your CNIC and business details.',
                style: AppTextStyles.medium.copyWith(
                  fontSize: 14,
                  color: AppColors.hintText,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              // Status Timeline
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _buildStepRow(
                      icon: Icons.check_circle,
                      iconColor: AppColors.success,
                      title: 'Application Received',
                      subtitle: 'Your shop information has been received',
                      isCompleted: true,
                    ),
                    const SizedBox(height: 12),
                    _buildStepRow(
                      icon: Icons.pending,
                      iconColor: AppColors.accentOrange,
                      title: 'Admin Verification',
                      subtitle: 'Document verification in progress (usually 24-48 hrs)',
                      isCompleted: false,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              AppButton(
                text: 'Okay, Got It',
                onPressed: () => Get.offAllNamed(AppRoutes.mainLayout),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isCompleted,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bold.copyWith(fontSize: 14, color: AppColors.darkText),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.medium.copyWith(fontSize: 12, color: AppColors.hintText),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
