import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uhsu_buy/features/wishlist/presentation/controllers/wishlist_controller.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../controllers/profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Header Section
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Purple Background Gradient
                Container(
                  height: 220,
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryPurple, AppColors.primaryPurple.withValues(alpha: 0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 3),
                        ),
                        child: const Icon(Icons.person, size: 40, color: AppColors.primaryPurple),
                      ),
                      const SizedBox(width: 16),
                      // User Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Obx(() => Text(
                              controller.userName.value,
                              style: AppTextStyles.extraBold.copyWith(fontSize: 20, color: Colors.white),
                            )),
                            const SizedBox(height: 4),
                            Obx(() => Text(
                              controller.userEmail.value,
                              style: AppTextStyles.medium.copyWith(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
                            )),
                          ],
                        ),
                      ),
                      // Edit Icon
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.edit_outlined, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                
                // Floating Orders Card
                Positioned(
                  top: 150,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () => Get.toNamed('/my-orders'),
                          behavior: HitTestBehavior.opaque,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('My Orders', style: AppTextStyles.bold.copyWith(fontSize: 16, color: AppColors.darkText)),
                              Row(
                                children: [
                                  Text('View All', style: AppTextStyles.medium.copyWith(fontSize: 13, color: AppColors.hintText)),
                                  const Icon(Icons.chevron_right, size: 16, color: AppColors.hintText),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(onTap: () => Get.toNamed('/my-orders'), child: _buildOrderIcon(Icons.payment_outlined, 'To Pay', badge: 1)),
                            GestureDetector(onTap: () => Get.toNamed('/my-orders'), child: _buildOrderIcon(Icons.inventory_2_outlined, 'To Ship', badge: 0)),
                            GestureDetector(onTap: () => Get.toNamed('/my-orders'), child: _buildOrderIcon(Icons.local_shipping_outlined, 'To Receive', badge: 2)),
                            GestureDetector(onTap: () => Get.toNamed('/my-orders'), child: _buildOrderIcon(Icons.rate_review_outlined, 'To Review', badge: 0)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // Spacer for floating card
            const SizedBox(height: 80),
            
            // First Menu Group
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Obx(() {
                      final count = Get.isRegistered<WishlistController>() 
                          ? Get.find<WishlistController>().wishlistedProductIds.length 
                          : 0;
                      return _buildMenuTile(
                        Icons.favorite_border, 
                        'My Wishlist', 
                        '$count items',
                        onTap: () => Get.toNamed('/wishlist'),
                      );
                    }),
                    _buildDivider(),
                    _buildMenuTile(Icons.storefront_outlined, 'Followed Stores', '4 stores'),
                    _buildDivider(),
                    _buildMenuTile(Icons.history, 'Browsing History', ''),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Second Menu Group
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildMenuTile(Icons.location_on_outlined, 'Shipping Addresses', ''),
                    _buildDivider(),
                    _buildMenuTile(Icons.credit_card_outlined, 'Payment Methods', ''),
                    _buildDivider(),
                    _buildMenuTile(Icons.confirmation_number_outlined, 'My Vouchers', '2 available', color: AppColors.primaryPurple),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Third Menu Group
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildMenuTile(Icons.support_agent_outlined, 'Contact Us', '', onTap: () => Get.toNamed('/contact-us')),
                    _buildDivider(),
                    _buildMenuTile(Icons.settings_outlined, 'Settings', ''),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: InkWell(
                onTap: () {
                  Get.dialog(
                    AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: Text('Logout', style: AppTextStyles.bold),
                      content: Text('Are you sure you want to logout?', style: AppTextStyles.regular),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: Text('Cancel', style: AppTextStyles.semiBold.copyWith(color: AppColors.hintText)),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.back();
                            controller.logout();
                          },
                          child: Text('Logout', style: AppTextStyles.bold.copyWith(color: AppColors.error)),
                        ),
                      ],
                    )
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
                  ),
                  child: Center(
                    child: Text('Logout', style: AppTextStyles.bold.copyWith(color: AppColors.error, fontSize: 16)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 120), // Bottom padding for navbar
          ],
        ),
      ),
    );
  }

  Widget _buildOrderIcon(IconData icon, String label, {int badge = 0}) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon, size: 28, color: AppColors.darkText),
            if (badge > 0)
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    badge.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(label, style: AppTextStyles.medium.copyWith(fontSize: 12, color: AppColors.darkText)),
      ],
    );
  }

  Widget _buildMenuTile(IconData icon, String title, String subtitle, {Color? color, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.darkText, size: 24),
      title: Text(title, style: AppTextStyles.semiBold.copyWith(fontSize: 15, color: AppColors.darkText)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (subtitle.isNotEmpty)
            Text(subtitle, style: AppTextStyles.medium.copyWith(fontSize: 13, color: color ?? AppColors.hintText)),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.hintText),
        ],
      ),
      onTap: onTap ?? () {},
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 56, right: 16),
      child: Divider(height: 1, color: Colors.grey.shade200),
    );
  }
}
