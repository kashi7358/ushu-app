import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Privacy Policy',
          style: AppTextStyles.bold.copyWith(fontSize: 18, color: AppColors.darkText),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryPurple, Color(0xFF6B21A8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPurple.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shield_outlined, color: Colors.white, size: 28),
                      const SizedBox(width: 10),
                      Text(
                        'USHU Privacy Policy',
                        style: AppTextStyles.bold.copyWith(fontSize: 18, color: Colors.white),
                      ),
                    ],
                  ),
                                  ],
              ),
            ),
            const SizedBox(height: 16),

            // Preamble Notice
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                'USHU respects your privacy and is committed to handling personal information responsibly. This Privacy Policy explains what information we may collect, how we use it, when we may share it, how we protect it, and the choices and rights available to you when you use USHU\'s website, mobile application, products, features, and services. Please read this Privacy Policy carefully before using the Services.',
                style: AppTextStyles.medium.copyWith(fontSize: 13, color: AppColors.darkText, height: 1.5),
              ),
            ),
            const SizedBox(height: 20),

            // 1. About This Privacy Policy
            _buildSection(
              title: '1. About This Privacy Policy',
              content:
                  '1.1 Scope\nThis Privacy Policy applies to personal information collected through the USHU Services and through other interactions you may have with USHU, including customer support, communications, promotions, surveys, or other activities connected with our Services.\n\n'
                  '1.2 Information Covered\n"Personal information" means information that identifies, relates to, describes, or can reasonably be associated with an identifiable individual, where such information is protected as personal information under applicable law.\n\n'
                  '1.3 Changes to This Privacy Policy\nWe may update this Privacy Policy from time to time to reflect changes in our Services, technology, business operations, or legal requirements. Updated versions will indicate their effective date.',
            ),

            // 2. Information We May Collect
            _buildSection(
              title: '2. Information We May Collect',
              content:
                  '2.1 Information You Provide\nYou may provide information when creating a USHU account, placing an order, contacting support, or interacting with our Services:\n'
                  '• Name, username, and account credentials\n'
                  '• Email address and telephone number\n'
                  '• Billing, shipping, and delivery address\n'
                  '• Payment status and order records\n'
                  '• Communications and support history\n\n'
                  '2.2 Transaction Information\nWe collect order details, transaction amounts, delivery data, refunds, and return records.\n\n'
                  '2.3 Automatically Collected Technical Data\nIP address, device identifiers, operating system, app usage analytics, session logs, and diagnostic information.',
            ),

            // 3. How We Use Personal Information
            _buildSection(
              title: '3. How We Use Personal Information',
              content:
                  '• Providing & Fulfilling Services: Administering accounts, processing orders, arranging delivery, and providing customer support.\n'
                  '• Platform Improvements: Analyzing performance, troubleshooting bugs, and enhancing user experience.\n'
                  '• Security & Fraud Prevention: Protecting user accounts, investigating suspicious transactions, and detecting unauthorized activity.\n'
                  '• Service Communications: Sending critical transactional messages, order status updates, and security notices.',
            ),

            // 4. Sharing Information
            _buildSection(
              title: '4. When We May Share Personal Information',
              content:
                  'We may share necessary data with:\n'
                  '• Logistics & Delivery Partners: To deliver your ordered packages.\n'
                  '• Payment Providers: To process payments securely.\n'
                  '• Legal Authorities: When required by applicable laws, court orders, or valid legal processes.\n'
                  '• Corporate Transactions: In connection with mergers, acquisition, or asset transfers.',
            ),

            // 5. Data Security
            _buildSection(
              title: '5. Data Security',
              content:
                  'USHU employs administrative, technical, and physical safeguards designed to protect personal information from unauthorized access, misuse, loss, or alteration. These include access controls, encrypted transmissions, and system monitoring.',
            ),

            // 6. Retention & Rights
            _buildSection(
              title: '6. Retention & Your Privacy Rights',
              content:
                  'We retain personal data only as long as necessary to fulfill service requirements and legal obligations. Depending on applicable law, you may request access to, correction of, or deletion of your personal data by contacting customer support.',
            ),

            // 7. Contact Us Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.contact_mail_outlined, color: AppColors.primaryPurple, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        '13. Contact Us',
                        style: AppTextStyles.bold.copyWith(fontSize: 16, color: AppColors.darkText),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Text('USHU Ecommerce Platform', style: AppTextStyles.bold.copyWith(fontSize: 14, color: AppColors.darkText)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: AppColors.hintText),
                      const SizedBox(width: 6),
                      Text('Address: ABBOTTABAD, Pakistan', style: AppTextStyles.medium.copyWith(fontSize: 13, color: AppColors.darkText)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.email_outlined, size: 16, color: AppColors.hintText),
                      const SizedBox(width: 6),
                      Text('Ushupk26@gmail.com', style: AppTextStyles.medium.copyWith(fontSize: 13, color: AppColors.primaryPurple)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.language_outlined, size: 16, color: AppColors.hintText),
                      const SizedBox(width: 6),
                      Text('Website: https://ushu.pk', style: AppTextStyles.medium.copyWith(fontSize: 13, color: AppColors.primaryPurple)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bold.copyWith(fontSize: 15, color: AppColors.primaryPurple),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: AppTextStyles.regular.copyWith(fontSize: 13, color: AppColors.darkText, height: 1.5),
          ),
        ],
      ),
    );
  }
}
