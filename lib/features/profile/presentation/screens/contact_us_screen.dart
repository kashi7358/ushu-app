import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../controllers/contact_us_controller.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ContactUsController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Contact Us', style: AppTextStyles.bold.copyWith(fontSize: 18, color: AppColors.darkText)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.support_agent_rounded, size: 64, color: AppColors.primaryPurple),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Get in Touch',
                style: AppTextStyles.extraBold.copyWith(fontSize: 24, color: AppColors.darkText),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'We are here to help you. Send us a message and we will get back to you as soon as possible.',
                style: AppTextStyles.medium.copyWith(fontSize: 14, color: AppColors.hintText, height: 1.5),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            
            const SizedBox(height: 32),
            Text('Send a Message', style: AppTextStyles.extraBold.copyWith(fontSize: 18, color: AppColors.darkText)),
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: controller.emailController,
              label: 'Email Address',
              hint: 'Enter your email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: controller.subjectController,
              label: 'Subject',
              hint: 'What is this regarding?',
              icon: Icons.subject_rounded,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: controller.messageController,
              label: 'Message',
              hint: 'Type your message here...',
              icon: Icons.message_outlined,
              maxLines: 5,
            ),
            const SizedBox(height: 32),
            Obx(() => AppButton(
              text: 'Send Message',
              isLoading: controller.isLoading.value,
              onPressed: controller.sendMessage,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bold.copyWith(fontSize: 14, color: AppColors.darkText)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: AppTextStyles.medium.copyWith(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.regular.copyWith(color: AppColors.hintText),
            prefixIcon: maxLines == 1 ? Icon(icon, color: AppColors.hintText) : null,
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryPurple, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}
