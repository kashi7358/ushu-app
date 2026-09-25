import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uhsu_buy/features/wishlist/presentation/controllers/wishlist_controller.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../controllers/profile_controller.dart';
import '../../../order/presentation/controllers/order_controller.dart';
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
                        Obx(() {
                          final orderController = Get.isRegistered<OrderController>() 
                              ? Get.find<OrderController>() 
                              : Get.put(OrderController());
                          final activeCount = orderController.activeOrdersCount;
                          final completedCount = orderController.completedOrdersCount;
                          final cancelledCount = orderController.cancelledOrdersCount;

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildOrderShortcut(
                                icon: Icons.local_shipping_outlined,
                                label: 'Active',
                                badge: activeCount,
                                onTap: () => Get.toNamed('/my-orders', arguments: {'tab': 'active'}),
                              ),
                              _buildOrderShortcut(
                                icon: Icons.task_alt_outlined,
                                label: 'Completed',
                                badge: completedCount,
                                onTap: () => Get.toNamed('/my-orders', arguments: {'tab': 'completed'}),
                              ),
                              _buildOrderShortcut(
                                icon: Icons.highlight_off_outlined,
                                label: 'Cancelled',
                                badge: cancelledCount,
                                onTap: () => Get.toNamed('/my-orders', arguments: {'tab': 'cancelled'}),
                              ),
                              _buildOrderShortcut(
                                icon: Icons.assignment_return_outlined,
                                label: 'Returns',
                                badge: 0,
                                onTap: () => Get.toNamed('/my-returns'),
                              ),
                            ],
                          );
                        }),
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

  Future<void> _showAddAddressSheet(BuildContext context) async {
    if (!SessionManager.isLoggedIn) {
      CustomPopup.showLoginRequired();
      return;
    }

    final savedAddress = await SessionManager.getSavedAddress();
    final hasSavedAddress = (savedAddress != null && (savedAddress['addressLine']?.isNotEmpty ?? false)).obs;
    final isEditing = (!hasSavedAddress.value).obs;

    final fullNameCtrl = TextEditingController(text: savedAddress?['fullName'] ?? SessionManager.fullName ?? '');
    final phoneCtrl = TextEditingController(text: savedAddress?['phone'] ?? '');
    final addressCtrl = TextEditingController(text: savedAddress?['addressLine'] ?? '');
    final cityCtrl = TextEditingController(text: savedAddress?['city'] ?? '');
    final provinceCtrl = TextEditingController(text: savedAddress?['province'] ?? 'Punjab');
    final countryCtrl = TextEditingController(text: savedAddress?['country'] ?? 'Pakistan');
    final postalCtrl = TextEditingController(text: savedAddress?['postalCode'] ?? '');
    final isDefault = true.obs;
    final isSaving = false.obs;

    if (!context.mounted) return;

    Get.bottomSheet(
      isScrollControlled: true,
      Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Obx(() {
              if (hasSavedAddress.value && !isEditing.value) {
                // VIEW SAVED ADDRESS CARD
                return Column(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Saved Shipping Address', style: AppTextStyles.bold.copyWith(fontSize: 18, color: AppColors.darkText)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade300),
                          ),
                          child: Text(
                            'Default',
                            style: AppTextStyles.bold.copyWith(fontSize: 11, color: Colors.green.shade700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Address Card Widget
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.person, size: 18, color: AppColors.primaryPurple),
                              const SizedBox(width: 8),
                              Text(
                                fullNameCtrl.text.isNotEmpty ? fullNameCtrl.text : 'Valued Customer',
                                style: AppTextStyles.bold.copyWith(fontSize: 15, color: AppColors.darkText),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.phone_android, size: 16, color: AppColors.hintText),
                              const SizedBox(width: 8),
                              Text(
                                phoneCtrl.text.isNotEmpty ? phoneCtrl.text : 'N/A',
                                style: AppTextStyles.medium.copyWith(fontSize: 13, color: AppColors.darkText),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.location_on_outlined, size: 18, color: AppColors.primaryPurple),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${addressCtrl.text}, ${cityCtrl.text}, ${provinceCtrl.text} ${postalCtrl.text}, ${countryCtrl.text}',
                                  style: AppTextStyles.medium.copyWith(fontSize: 13, color: AppColors.darkText),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Edit & Close Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.edit_location_alt_rounded, size: 18),
                            label: const Text('Edit Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            onPressed: () => isEditing.value = true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => Get.back(),
                          child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkText)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                );
              }

              // EDIT / ADD FORM VIEW
              return Column(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        hasSavedAddress.value ? 'Edit Shipping Address' : 'Add Delivery Address',
                        style: AppTextStyles.bold.copyWith(fontSize: 18, color: AppColors.darkText),
                      ),
                      if (hasSavedAddress.value)
                        TextButton(
                          onPressed: () => isEditing.value = false,
                          child: const Text('Cancel', style: TextStyle(color: AppColors.primaryPurple)),
                        ),
                    ],
                  ),
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
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: [
                            'Punjab',
                            'Sindh',
                            'Khyber Pakhtunkhwa',
                            'Balochistan',
                            'Islamabad (Capital)',
                            'Gilgit-Baltistan & AJK',
                          ].contains(provinceCtrl.text)
                              ? provinceCtrl.text
                              : 'Punjab',
                          decoration: const InputDecoration(labelText: 'Province', border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: 'Punjab', child: Text('Punjab', style: TextStyle(fontSize: 12))),
                            DropdownMenuItem(value: 'Sindh', child: Text('Sindh', style: TextStyle(fontSize: 12))),
                            DropdownMenuItem(value: 'Khyber Pakhtunkhwa', child: Text('KPK', style: TextStyle(fontSize: 12))),
                            DropdownMenuItem(value: 'Balochistan', child: Text('Balochistan', style: TextStyle(fontSize: 12))),
                            DropdownMenuItem(value: 'Islamabad (Capital)', child: Text('Islamabad', style: TextStyle(fontSize: 12))),
                            DropdownMenuItem(value: 'Gilgit-Baltistan & AJK', child: Text('GB & AJK', style: TextStyle(fontSize: 12))),
                          ],
                          onChanged: (val) {
                            if (val != null) provinceCtrl.text = val;
                          },
                        ),
                      ),
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
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: isDefault.value,
                    onChanged: (val) => isDefault.value = val ?? false,
                    title: const Text('Set as default address'),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: isSaving.value ? null : () async {
                        if (countryCtrl.text.trim().isEmpty) countryCtrl.text = 'Pakistan';
                        if (provinceCtrl.text.trim().isEmpty) provinceCtrl.text = 'Punjab';
                        if (cityCtrl.text.trim().isEmpty) cityCtrl.text = 'Lahore';
                        if (postalCtrl.text.trim().isEmpty) postalCtrl.text = '54000';

                        if (fullNameCtrl.text.trim().isEmpty || phoneCtrl.text.trim().isEmpty || addressCtrl.text.trim().isEmpty) {
                          CustomPopup.showToast('Validation Error', 'Please fill required fields (Name, Phone, Address)', isError: true);
                          return;
                        }

                        final finalFullName = fullNameCtrl.text.trim();
                        final finalPhone = phoneCtrl.text.trim();
                        final finalAddress = addressCtrl.text.trim();
                        final finalCity = cityCtrl.text.trim();
                        final finalProvince = provinceCtrl.text.trim();
                        final finalCountry = countryCtrl.text.trim();
                        final finalPostalCode = postalCtrl.text.trim();

                        try {
                          isSaving.value = true;
                          final apiClient = ApiClient();
                          await apiClient.dio.post(
                            ApiEndpoints.addAddress,
                            data: {
                              'fullName': finalFullName,
                              'phone': finalPhone,
                              'addressLine': finalAddress,
                              'address': finalAddress,
                              'street': finalAddress,
                              'city': finalCity,
                              'province': finalProvince,
                              'state': finalProvince,
                              'country': finalCountry,
                              'postalCode': finalPostalCode,
                              'zipCode': finalPostalCode,
                              'isDefault': isDefault.value,
                            },
                            options: Options(validateStatus: (status) => true),
                          );
                          
                          await SessionManager.saveAddressData(
                            fullName: finalFullName,
                            phone: finalPhone,
                            addressLine: finalAddress,
                            city: finalCity,
                            province: finalProvince,
                            country: finalCountry,
                            postalCode: finalPostalCode,
                          );

                          hasSavedAddress.value = true;
                          isEditing.value = false;

                          Get.back();
                          CustomPopup.showToast('Success', 'Address Saved Successfully!');
                        } catch (e) {
                          CustomPopup.showToast('Error', 'An error occurred while saving address', isError: true);
                        } finally {
                          isSaving.value = false;
                        }
                      },
                      child: isSaving.value 
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : const Text('Save Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderShortcut({
    required IconData icon,
    required String label,
    required int badge,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 22, color: AppColors.primaryPurple),
              ),
              if (badge > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      badge.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(label, style: AppTextStyles.bold.copyWith(fontSize: 12, color: AppColors.darkText)),
        ],
      ),
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
