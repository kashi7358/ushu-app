import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../controllers/contact_us_controller.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ContactUsController());

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.darkText, size: 18),
          onPressed: () => Get.back(),
        ),
        title: Column(
          children: [
            Text(
              'Customer Assistant',
              style: AppTextStyles.bold.copyWith(fontSize: 17, color: AppColors.darkText),
            ),
            Text(
              '24/7 Support Team',
              style: AppTextStyles.medium.copyWith(fontSize: 11, color: AppColors.hintText),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Hero Assistant Banner Card
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primaryPurple,
                                  AppColors.primaryPurple.withValues(alpha: 0.85),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryPurple.withValues(alpha: 0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.support_agent_rounded,
                                    size: 36,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Ushu Support Assistant',
                                            style: AppTextStyles.bold.copyWith(fontSize: 15, color: Colors.white),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: Colors.greenAccent,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Have a question or feedback? We are here to help you anytime.',
                                        style: AppTextStyles.medium.copyWith(
                                          fontSize: 11.5,
                                          color: Colors.white.withValues(alpha: 0.9),
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Contact Form Container Card
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Send Us a Message',
                                  style: AppTextStyles.bold.copyWith(fontSize: 15, color: AppColors.darkText),
                                ),
                                const SizedBox(height: 12),

                                // Email Input
                                _buildInputField(
                                  controller: controller.emailController,
                                  label: 'Your Email',
                                  hint: 'Enter your email address',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 12),

                                // Subject Input
                                _buildInputField(
                                  controller: controller.subjectController,
                                  label: 'Subject',
                                  hint: 'What is your query about?',
                                  icon: Icons.help_outline_rounded,
                                ),
                                const SizedBox(height: 12),

                                // Message Input
                                _buildInputField(
                                  controller: controller.messageController,
                                  label: 'Message',
                                  hint: 'Type your message details here...',
                                  icon: Icons.chat_bubble_outline_rounded,
                                  maxLines: 3,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Bottom Submit Action Button
                      Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 10),
                        child: Obx(() => AppButton(
                          text: 'Send Message',
                          isLoading: controller.isLoading.value,
                          onPressed: controller.sendMessage,
                        )),
                      ),
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

  Widget _buildInputField({
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
        Text(
          label,
          style: AppTextStyles.bold.copyWith(fontSize: 12.5, color: AppColors.darkText),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: AppTextStyles.medium.copyWith(fontSize: 13.5, color: AppColors.darkText),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.medium.copyWith(color: Colors.grey.shade400, fontSize: 13),
            prefixIcon: maxLines == 1 ? Icon(icon, color: AppColors.hintText, size: 19) : null,
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
          ),
        ),
      ],
    );
  }
}
