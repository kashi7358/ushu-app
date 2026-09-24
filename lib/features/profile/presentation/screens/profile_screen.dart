import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uhsu_buy/features/wishlist/presentation/controllers/wishlist_controller.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../controllers/profile_controller.dart';
import 'browsing_history_screen.dart';
import '../../../../core/utils/custom_popup.dart';
import '../../../../core/utils/session_manager.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import 'package:dio/dio.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());
    controller.loadFollowedStoresCount(); // Refresh count when screen is built

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
                            GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => Get.toNamed('/my-orders'), child: _buildOrderIcon(Icons.inventory_2_outlined, 'Active')),
                            GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => Get.toNamed('/my-orders'), child: _buildOrderIcon(Icons.check_circle_outline, 'Completed')),
                            GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => Get.toNamed('/my-orders'), child: _buildOrderIcon(Icons.cancel_outlined, 'Cancelled')),
                            GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => Get.toNamed('/my-returns'), child: _buildOrderIcon(Icons.assignment_return_outlined, 'Returns')),
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
                    _buildMenuTile(Icons.history, 'Browsing History', '', onTap: () {
                      Get.to(() => const BrowsingHistoryScreen());
                    }),
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
                    _buildMenuTile(Icons.location_on_outlined, 'Shipping Addresses', '', onTap: () => _showAddAddressSheet(context)),
                    _buildDivider(),
                    _buildMenuTile(Icons.credit_card_outlined, 'Payment Methods', ''),
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
                    _buildMenuTile(
                      Icons.assignment_return_outlined,
                      'My Returns',
                      '',
                      onTap: () => Get.toNamed('/my-returns'),
                    ),
                    _buildDivider(),
                    SessionManager.isLoggedIn 
                      ? _buildMenuTile(
                          Icons.logout_outlined, 
                          'Logout', 
                          '', 
                          color: AppColors.error,
                          onTap: () async {
                            final confirm = await CustomPopup.showLogoutConfirmation();
                            if (confirm ?? false) {
                              controller.logout();
                            }
                          }
                        )
                      : _buildMenuTile(
                          Icons.login_outlined,
                          'Login / Register',
                          '',
                          color: AppColors.primaryPurple,
                          onTap: () => Get.toNamed('/login'),
                        ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const SizedBox(height: 120), // Bottom padding for navbar
          ],
        ),
      ),
    );
  }

  void _showAddAddressSheet(BuildContext context) {
    if (!SessionManager.isLoggedIn) {
      CustomPopup.showLoginRequired();
      return;
    }

    final fullNameCtrl = TextEditingController(text: SessionManager.fullName ?? '');
    final phoneCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final provinceCtrl = TextEditingController();
    final countryCtrl = TextEditingController(text: 'Pakistan');
    final postalCtrl = TextEditingController();
    final isDefault = false.obs;
    final isSaving = false.obs;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Text('Add Delivery Address', style: AppTextStyles.bold.copyWith(fontSize: 18, color: AppColors.darkText)),
              const SizedBox(height: 16),
              TextField(controller: fullNameCtrl, decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Address Line', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: TextField(controller: cityCtrl, decoration: const InputDecoration(labelText: 'City', border: OutlineInputBorder()))),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(controller: provinceCtrl, decoration: const InputDecoration(labelText: 'Province', border: OutlineInputBorder()))),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: TextField(controller: countryCtrl, decoration: const InputDecoration(labelText: 'Country', border: OutlineInputBorder()))),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(controller: postalCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Postal Code', border: OutlineInputBorder()))),
                ],
              ),
              const SizedBox(height: 16),
              Obx(() => CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: isDefault.value,
                onChanged: (val) => isDefault.value = val ?? false,
                title: const Text('Set as default address'),
              )),
              const SizedBox(height: 16),
              Obx(() => SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPurple, foregroundColor: Colors.white),
                  onPressed: isSaving.value ? null : () async {
                    if (fullNameCtrl.text.trim().isEmpty || phoneCtrl.text.trim().isEmpty || addressCtrl.text.trim().isEmpty) {
                      CustomPopup.showToast('Validation Error', 'Please fill required fields', isError: true);
                      return;
                    }
                    try {
                      isSaving.value = true;
                      final apiClient = ApiClient();
                      final response = await apiClient.dio.post(
                        ApiEndpoints.addAddress,
                        data: {
                          'fullName': fullNameCtrl.text.trim(),
                          'phone': phoneCtrl.text.trim(),
                          'addressLine': addressCtrl.text.trim(),
                          'city': cityCtrl.text.trim(),
                          'province': provinceCtrl.text.trim(),
                          'country': countryCtrl.text.trim(),
                          'postalCode': postalCtrl.text.trim(),
                          'isDefault': isDefault.value,
                        },
                        options: Options(validateStatus: (status) => true),
                      );
                      
                      if (response.data != null && response.data['success'] == true) {
                        Get.back();
                        CustomPopup.showFastLottie('assets/lotties/done.json');
                        CustomPopup.showToast('Success', 'Address Added Successfully!');
                      } else {
                        CustomPopup.showToast('Failed', response.data?['message'] ?? 'Could not add address', isError: true);
                      }
                    } catch (e) {
                      CustomPopup.showToast('Error', 'An error occurred', isError: true);
                    } finally {
                      isSaving.value = false;
                    }
                  },
                  child: isSaving.value ? const CircularProgressIndicator(color: Colors.white) : const Text('Save Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              )),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
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
