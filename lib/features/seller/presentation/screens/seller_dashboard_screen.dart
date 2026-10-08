import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../controllers/seller_dashboard_controller.dart';

class SellerDashboardScreen extends StatelessWidget {
  const SellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SellerDashboardController());
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFF8F9FA),
      drawer: _buildSidebarDrawer(context, controller),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.darkText),
          onPressed: () => scaffoldKey.currentState?.openDrawer(),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'S',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'SellerHub',
              style: AppTextStyles.bold.copyWith(color: AppColors.darkText, fontSize: 17),
            ),
          ],
        ),
        actions: [
          // User profile pill on the right
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primaryPurple.withValues(alpha: 0.1),
                  child: const Icon(Icons.person, color: AppColors.primaryPurple, size: 20),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () => Text(
                        controller.sellerName.value.isNotEmpty ? controller.sellerName.value : 'Seller Account',
                        style: AppTextStyles.bold.copyWith(fontSize: 12, color: AppColors.darkText),
                      ),
                    ),
                    Obx(
                      () => Text(
                        controller.sellerEmail.value.isNotEmpty ? controller.sellerEmail.value : 'seller@store.pk',
                        style: AppTextStyles.medium.copyWith(fontSize: 10, color: AppColors.hintText),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryPurple),
          );
        }

        return RefreshIndicator(
          color: AppColors.primaryPurple,
          onRefresh: controller.fetchDashboardStats,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Subtitle & Store Title
                Text(
                  'DASHBOARD',
                  style: AppTextStyles.bold.copyWith(
                    color: const Color(0xFFE65100),
                    fontSize: 12,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        controller.storeName.value.isNotEmpty ? controller.storeName.value : 'Fashion Store',
                        style: AppTextStyles.extraBold.copyWith(
                          fontSize: 22,
                          color: AppColors.darkText,
                          decoration: TextDecoration.underline,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: controller.navigateToAddProduct,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Product', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Performance overview for your store',
                  style: AppTextStyles.medium.copyWith(fontSize: 13, color: AppColors.hintText),
                ),
                const SizedBox(height: 20),

                // Error message banner if any
                if (controller.errorMessage.value.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            controller.errorMessage.value,
                            style: const TextStyle(color: Colors.red, fontSize: 12.5),
                          ),
                        ),
                        TextButton(
                          onPressed: controller.fetchDashboardStats,
                          child: const Text('Retry', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),

                // Row 1: TOTAL PRODUCTS & TOTAL SALES PRODUCTS
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'TOTAL PRODUCTS',
                        value: '${controller.stats.value.totalProducts}',
                        icon: Icons.inventory_2_outlined,
                        iconColor: const Color(0xFFF57C00),
                        iconBgColor: const Color(0xFFFFF3E0),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: 'TOTAL SALES PRODUCTS',
                        value: '${controller.stats.value.totalSalesProducts}',
                        icon: Icons.shopping_bag_outlined,
                        iconColor: const Color(0xFFF57C00),
                        iconBgColor: const Color(0xFFFFF3E0),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Row 2: ACTIVE ORDERS & DELIVERED ORDERS
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'ACTIVE ORDERS',
                        value: '${controller.stats.value.activeOrders}',
                        icon: Icons.access_time_rounded,
                        iconColor: const Color(0xFFF57C00),
                        iconBgColor: const Color(0xFFFFF3E0),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: 'DELIVERED ORDERS',
                        value: '${controller.stats.value.deliveredOrders}',
                        icon: Icons.check_circle_outline,
                        iconColor: const Color(0xFFF57C00),
                        iconBgColor: const Color(0xFFFFF3E0),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Row 3: CANCELLED ORDERS & RETURNED ORDERS
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'CANCELLED ORDERS',
                        value: '${controller.stats.value.cancelledOrders}',
                        icon: Icons.cancel_outlined,
                        iconColor: const Color(0xFFF57C00),
                        iconBgColor: const Color(0xFFFFF3E0),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: 'RETURNED ORDERS',
                        value: '${controller.stats.value.returnedOrders}',
                        icon: Icons.undo_outlined,
                        iconColor: const Color(0xFFF57C00),
                        iconBgColor: const Color(0xFFFFF3E0),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Row 4: EARNING AMOUNT
                _buildStatCard(
                  title: 'EARNING AMOUNT',
                  value: 'Rs. ${controller.stats.value.earningAmount.toStringAsFixed(controller.stats.value.earningAmount.truncateToDouble() == controller.stats.value.earningAmount ? 0 : 2)}',
                  icon: Icons.account_balance_wallet_outlined,
                  iconColor: const Color(0xFFF57C00),
                  iconBgColor: const Color(0xFFFFF3E0),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
    );
  }

  // Stat Card matching the web portal screenshot
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
  }) {
    return Container(
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
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bold.copyWith(
                    fontSize: 10.5,
                    color: const Color(0xFF78909C),
                    letterSpacing: 0.6,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.extraBold.copyWith(
              fontSize: 22,
              color: AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }

  // Professional Navigation Sidebar matching the web layout
  Widget _buildSidebarDrawer(BuildContext context, SellerDashboardController controller) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'S',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'SellerHub',
                    style: AppTextStyles.bold.copyWith(color: AppColors.darkText, fontSize: 18),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Sidebar Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                children: [
                  _buildDrawerItem(
                    icon: Icons.dashboard_outlined,
                    title: 'Dashboard',
                    isSelected: true,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  _buildDrawerDropdownItem(
                    icon: Icons.inventory_2_outlined,
                    title: 'Products',
                    subItems: [
                      _buildDrawerSubItem(
                        icon: Icons.inventory_outlined,
                        title: 'Manage Products',
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      _buildDrawerSubItem(
                        icon: Icons.add_box_outlined,
                        title: 'Add Product',
                        onTap: () {
                          Navigator.of(context).pop();
                          controller.navigateToAddProduct();
                        },
                      ),
                      _buildDrawerSubItem(
                        icon: Icons.discount_outlined,
                        title: 'Add Sales On Product',
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      _buildDrawerSubItem(
                        icon: Icons.percent_outlined,
                        title: 'Manage Sales Products',
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                  _buildDrawerItem(
                    icon: Icons.shopping_cart_outlined,
                    title: 'Order Management',
                    isSelected: false,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  _buildDrawerItem(
                    icon: Icons.assignment_return_outlined,
                    title: 'Returned Orders',
                    isSelected: false,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  _buildDrawerItem(
                    icon: Icons.bar_chart_outlined,
                    title: 'Financial Report',
                    isSelected: false,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  _buildDrawerItem(
                    icon: Icons.campaign_outlined,
                    title: 'Promotion Campaign',
                    isSelected: false,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Logout at the bottom
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: ListTile(
                onTap: controller.logout,
                leading: const Icon(Icons.logout, color: Colors.red),
                title: Text(
                  'Logout',
                  style: AppTextStyles.bold.copyWith(color: Colors.red, fontSize: 14),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.grey.shade100 : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        onTap: onTap,
        dense: true,
        leading: Icon(
          icon,
          color: isSelected ? AppColors.darkText : AppColors.hintText,
          size: 20,
        ),
        title: Text(
          title,
          style: isSelected
              ? AppTextStyles.bold.copyWith(color: AppColors.darkText, fontSize: 14)
              : AppTextStyles.medium.copyWith(color: AppColors.hintText, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildDrawerDropdownItem({
    required IconData icon,
    required String title,
    required List<Widget> subItems,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: Icon(icon, color: AppColors.hintText, size: 20),
          title: Text(
            title,
            style: AppTextStyles.medium.copyWith(color: AppColors.hintText, fontSize: 14),
          ),
          children: subItems,
        ),
      ),
    );
  }

  Widget _buildDrawerSubItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 36, bottom: 2, right: 12),
      child: ListTile(
        dense: true,
        onTap: onTap,
        leading: Icon(icon, size: 18, color: AppColors.hintText),
        title: Text(
          title,
          style: AppTextStyles.medium.copyWith(fontSize: 13, color: AppColors.darkText),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
