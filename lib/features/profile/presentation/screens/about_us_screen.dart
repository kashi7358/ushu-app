import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'About Us',
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Logo & Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shopping_bag_outlined, color: AppColors.primaryPurple, size: 36),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'USHU',
                    style: AppTextStyles.extraBold.copyWith(fontSize: 24, color: AppColors.primaryPurple, letterSpacing: 1),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your Preferred Shopping Experience',
                    style: AppTextStyles.medium.copyWith(fontSize: 13, color: AppColors.hintText),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Version 1.0.0',
                      style: AppTextStyles.bold.copyWith(fontSize: 11, color: AppColors.primaryPurple),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Mission Statement
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.rocket_launch_outlined, color: AppColors.primaryPurple, size: 22),
                      const SizedBox(width: 8),
                      Text('Our Mission', style: AppTextStyles.bold.copyWith(fontSize: 16, color: AppColors.darkText)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'USHU is committed to providing customers across Pakistan with high-quality products, competitive prices, authentic reviews, and lightning-fast delivery. We bring convenience to your doorstep through technology and dedicated service.',
                    style: AppTextStyles.regular.copyWith(fontSize: 13, color: AppColors.darkText, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Key Pillars / Features
            Row(
              children: [
                Expanded(
                  child: _buildFeatureCard(
                    icon: Icons.verified_outlined,
                    title: '100% Authentic',
                    subtitle: 'Genuine items',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFeatureCard(
                    icon: Icons.local_shipping_outlined,
                    title: 'Fast Shipping',
                    subtitle: 'All over Pakistan',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildFeatureCard(
                    icon: Icons.lock_outline,
                    title: 'Secure Checkout',
                    subtitle: 'COD & Payment options',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFeatureCard(
                    icon: Icons.support_agent_outlined,
                    title: '24/7 Support',
                    subtitle: 'Customer assistance',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Contact & Location Card
            Container(
              padding: const EdgeInsets.all(18),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Head Office & Contact Info', style: AppTextStyles.bold.copyWith(fontSize: 15, color: AppColors.darkText)),
                  const Divider(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.location_city_outlined, size: 18, color: AppColors.primaryPurple),
                      const SizedBox(width: 10),
                      Text('Address: Abbottabad, Pakistan', style: AppTextStyles.medium.copyWith(fontSize: 13, color: AppColors.darkText)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.email_outlined, size: 18, color: AppColors.primaryPurple),
                      const SizedBox(width: 10),
                      Text('Email: Ushupk26@gmail.com', style: AppTextStyles.medium.copyWith(fontSize: 13, color: AppColors.primaryPurple)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.public_outlined, size: 18, color: AppColors.primaryPurple),
                      const SizedBox(width: 10),
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

  Widget _buildFeatureCard({required IconData icon, required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryPurple, size: 24),
          const SizedBox(height: 8),
          Text(title, style: AppTextStyles.bold.copyWith(fontSize: 13, color: AppColors.darkText)),
          const SizedBox(height: 2),
          Text(subtitle, style: AppTextStyles.medium.copyWith(fontSize: 11, color: AppColors.hintText)),
        ],
      ),
    );
  }
}
