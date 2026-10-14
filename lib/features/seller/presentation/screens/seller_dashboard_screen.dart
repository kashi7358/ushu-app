import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/utils/session_manager.dart';
import '../controllers/seller_dashboard_controller.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  late final SellerDashboardController controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    controller = Get.put(SellerDashboardController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: _buildSidebarDrawer(context, controller),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: IconButton(
            icon: const Icon(Icons.menu_rounded, color: AppColors.darkText, size: 26),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            tooltip: 'Open Menu',
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            Text(
              'Seller Center',
              style: AppTextStyles.bold.copyWith(color: AppColors.darkText, fontSize: 17.5),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: CircleAvatar(
              radius: 17,
              backgroundColor: AppColors.primaryPurple.withValues(alpha: 0.1),
              child: const Icon(Icons.person, color: AppColors.primaryPurple, size: 20),
            ),
            onPressed: () => _showStoreProfileBottomSheet(context, controller),
            tooltip: 'Store & Profile Details',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildDashboardShimmer();
        }

        return RefreshIndicator(
          color: AppColors.primaryPurple,
          onRefresh: controller.fetchDashboardStats,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Error message banner if any
                if (controller.errorMessage.value.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
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

                // Welcome Store Greeting Header Card
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.primaryPurple.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Obx(() {
                          final logo = controller.storeLogo.value;
                          final sName = controller.storeName.value;
                          return _buildAdaptiveImage(
                            path: logo,
                            fit: BoxFit.cover,
                            placeholder: Center(
                              child: Text(
                                sName.isNotEmpty ? sName[0].toUpperCase() : 'S',
                                style: AppTextStyles.bold.copyWith(color: AppColors.primaryPurple, fontSize: 17),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Obx(() => Text(
                                    controller.storeName.value.isNotEmpty ? controller.storeName.value : 'My Store',
                                    style: AppTextStyles.bold.copyWith(fontSize: 15, color: AppColors.darkText),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                                ),
                                const SizedBox(width: 5),
                                const Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 15),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                const Expanded(
                                  child: Text(
                                    'Store Live & Active',
                                    style: TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w500),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => _showStoreProfileBottomSheet(context, controller),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Profile',
                                style: TextStyle(color: Color(0xFF334155), fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                              Icon(Icons.chevron_right_rounded, size: 15, color: Color(0xFF64748B)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 1. Executive Total Earnings Banner Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E1B4B), Color(0xFF312E81), Color(0xFF3730A3)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF312E81).withValues(alpha: 0.28),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.greenAccent,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'TOTAL SETTLED REVENUE',
                                    style: AppTextStyles.bold.copyWith(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      fontSize: 10.5,
                                      letterSpacing: 1.0,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => Get.toNamed(AppRoutes.sellerFinancialReport),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Report',
                                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Colors.white),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Obx(() => Text(
                          'Rs. ${controller.stats.value.earningAmount.toStringAsFixed(controller.stats.value.earningAmount.truncateToDouble() == controller.stats.value.earningAmount ? 0 : 2)}',
                          style: AppTextStyles.extraBold.copyWith(
                            fontSize: 27,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        )),
                      ),
                      const SizedBox(height: 14),
                      const Divider(height: 1, color: Colors.white24),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.verified_rounded, size: 15, color: Colors.greenAccent),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Obx(() => Text(
                                    'Settled: Rs. ${controller.paidAmount.value.toStringAsFixed(0)}',
                                    style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                                ),
                              ],
                            ),
                          ),
                          Container(width: 1, height: 16, color: Colors.white24),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.hourglass_top_rounded, size: 15, color: Colors.amberAccent),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Obx(() => Text(
                                    'Pending: Rs. ${controller.unpaidAmount.value.toStringAsFixed(0)}',
                                    style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 2. Quick Action Shortcuts Row
                Container(
                  margin: const EdgeInsets.only(top: 14, bottom: 18),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionItem(
                          icon: Icons.add_box_rounded,
                          label: 'Add Product',
                          color: const Color(0xFF2563EB),
                          bgColor: const Color(0xFFEFF6FF),
                          onTap: controller.navigateToAddProduct,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildQuickActionItem(
                          icon: Icons.local_shipping_rounded,
                          label: 'Orders',
                          color: const Color(0xFFF59E0B),
                          bgColor: const Color(0xFFFFFBEB),
                          onTap: () => Get.toNamed(AppRoutes.sellerOrders),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildQuickActionItem(
                          icon: Icons.bolt_rounded,
                          label: 'Flash Sale',
                          color: const Color(0xFF7C3AED),
                          bgColor: const Color(0xFFF5F3FF),
                          onTap: () => Get.toNamed(AppRoutes.sellerCreateFlashSale),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildQuickActionItem(
                          icon: Icons.assessment_rounded,
                          label: 'Financials',
                          color: const Color(0xFF10B981),
                          bgColor: const Color(0xFFECFDF5),
                          onTap: () => Get.toNamed(AppRoutes.sellerFinancialReport),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                // 3. Stats Section Header
                Text(
                  'STORE OVERVIEW',
                  style: AppTextStyles.bold.copyWith(
                    color: AppColors.hintText,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),

                // Row 1: Products & Sales Products
                Row(
                  children: [
                    Expanded(
                      child: _buildModernStatCard(
                        title: 'Total Products',
                        value: '${controller.stats.value.totalProducts}',
                        icon: Icons.inventory_2_rounded,
                        accentColor: const Color(0xFF2563EB),
                        bgColor: const Color(0xFFEFF6FF),
                        onTap: () {
                          Get.toNamed(
                            AppRoutes.sellerManageProducts,
                            arguments: {'storeId': SessionManager.sellerStoreId ?? ''},
                          )?.then((_) => controller.fetchDashboardStats());
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildModernStatCard(
                        title: 'Sales Products',
                        value: '${controller.stats.value.totalSalesProducts}',
                        icon: Icons.shopping_bag_rounded,
                        accentColor: const Color(0xFF7C3AED),
                        bgColor: const Color(0xFFF5F3FF),
                        onTap: () {
                          Get.toNamed(AppRoutes.sellerManageFlashSales);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Row 2: Active Orders & Delivered Orders
                Row(
                  children: [
                    Expanded(
                      child: _buildModernStatCard(
                        title: 'Active Orders',
                        value: '${controller.stats.value.activeOrders}',
                        icon: Icons.local_shipping_rounded,
                        accentColor: const Color(0xFFF59E0B),
                        bgColor: const Color(0xFFFFFBEB),
                        onTap: () {
                          Get.toNamed(
                            AppRoutes.sellerOrders,
                            arguments: {'tab': 'Processing'},
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildModernStatCard(
                        title: 'Delivered Orders',
                        value: '${controller.stats.value.deliveredOrders}',
                        icon: Icons.verified_rounded,
                        accentColor: const Color(0xFF10B981),
                        bgColor: const Color(0xFFECFDF5),
                        onTap: () {
                          Get.toNamed(
                            AppRoutes.sellerOrders,
                            arguments: {'tab': 'Completed'},
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Row 3: Cancelled Orders & Returned Orders
                Row(
                  children: [
                    Expanded(
                      child: _buildModernStatCard(
                        title: 'Cancelled Orders',
                        value: '${controller.stats.value.cancelledOrders}',
                        icon: Icons.cancel_rounded,
                        accentColor: const Color(0xFFEF4444),
                        bgColor: const Color(0xFFFEF2F2),
                        onTap: () {
                          Get.toNamed(
                            AppRoutes.sellerOrders,
                            arguments: {'tab': 'Cancelled'},
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildModernStatCard(
                        title: 'Returned Orders',
                        value: '${controller.stats.value.returnedOrders}',
                        icon: Icons.assignment_return_rounded,
                        accentColor: const Color(0xFF06B6D4),
                        bgColor: const Color(0xFFECFEFF),
                        onTap: () {
                          Get.toNamed(
                            AppRoutes.sellerOrders,
                            arguments: {'tab': 'Cancelled'},
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 4. Graphical Analytics Section (Optimized for Mobile)
                _buildOrderStatusGraphCard(controller),
                const SizedBox(height: 16),

                _buildPayoutBreakdownCard(controller),
                const SizedBox(height: 16),

                _buildDeliveredProductsCard(controller),
                const SizedBox(height: 16),

                _buildRefundedProductsCard(controller),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF334155),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Modern Stat Card with custom accent color
  Widget _buildModernStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
    required Color bgColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
                    fontSize: 11.5,
                    color: AppColors.hintText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: accentColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: AppTextStyles.extraBold.copyWith(
              fontSize: 22,
              color: AppColors.darkText,
            ),
          ),
        ],
      ),
    ),
  );
}

  // Balanced & Professional Navigation Sidebar Drawer
  Widget _buildSidebarDrawer(BuildContext context, SellerDashboardController controller) {
    return Drawer(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 16,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
      ),
      child: Column(
        children: [
          // 1. Professional Header with Store Logo, Badge & Seller Info
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).padding.top + 22,
              20,
              18,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryPurple,
                  AppColors.secondaryViolet,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.white, width: 2.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Obx(() {
                        final logo = controller.storeLogo.value;
                        final storeName = controller.storeName.value;
                        return _buildAdaptiveImage(
                          path: logo,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          placeholder: Center(
                            child: Text(
                              storeName.isNotEmpty ? storeName[0].toUpperCase() : 'S',
                              style: AppTextStyles.extraBold.copyWith(
                                fontSize: 22,
                                color: AppColors.primaryPurple,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() => Text(
                            controller.storeName.value.isNotEmpty
                                ? controller.storeName.value
                                : 'My Store',
                            style: AppTextStyles.extraBold.copyWith(
                              color: Colors.white,
                              fontSize: 16.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.verified_rounded, size: 12, color: Color(0xFF4ADE80)),
                                SizedBox(width: 4),
                                Text(
                                  'Verified Seller',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Divider(height: 1, color: Colors.white.withValues(alpha: 0.18)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.mail_outline_rounded,
                      size: 14,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Obx(() => Text(
                        controller.sellerEmail.value.isNotEmpty
                            ? controller.sellerEmail.value
                            : (controller.sellerName.value.isNotEmpty
                                ? controller.sellerName.value
                                : 'Seller Account'),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. Clean Professional Navigation List (No Boxy Cards)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              children: [
                _buildDrawerItem(
                  icon: Icons.grid_view_rounded,
                  title: 'Dashboard',
                  isSelected: true,
                  onTap: () => Navigator.of(context).pop(),
                ),
                _buildDrawerDropdownItem(
                  icon: Icons.inventory_2_outlined,
                  title: 'Products',
                  subItems: [
                    _buildDrawerSubItem(
                      icon: Icons.view_list_rounded,
                      title: 'Manage Products',
                      onTap: () {
                        Navigator.of(context).pop();
                        Get.toNamed(
                          AppRoutes.sellerManageProducts,
                          arguments: {'storeId': SessionManager.sellerStoreId ?? ''},
                        )?.then((_) => controller.fetchDashboardStats());
                      },
                    ),
                    _buildDrawerSubItem(
                      icon: Icons.add_circle_outline_rounded,
                      title: 'Add Product',
                      onTap: () {
                        Navigator.of(context).pop();
                        controller.navigateToAddProduct();
                      },
                    ),
                    _buildDrawerSubItem(
                      icon: Icons.bolt_rounded,
                      title: 'Create Flash Sale',
                      onTap: () {
                        Navigator.of(context).pop();
                        Get.toNamed(AppRoutes.sellerCreateFlashSale);
                      },
                    ),
                    _buildDrawerSubItem(
                      icon: Icons.local_offer_outlined,
                      title: 'Manage Sales Products',
                      onTap: () {
                        Navigator.of(context).pop();
                        Get.toNamed(AppRoutes.sellerManageFlashSales);
                      },
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                ),
                _buildDrawerItem(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Order Management',
                  isSelected: false,
                  onTap: () {
                    Navigator.of(context).pop();
                    Get.toNamed(AppRoutes.sellerOrders);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.assignment_return_outlined,
                  title: 'Returned Orders',
                  isSelected: false,
                  onTap: () {
                    Navigator.of(context).pop();
                    Get.toNamed(
                      AppRoutes.sellerOrders,
                      arguments: {'tab': 'Cancelled'},
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.bar_chart_rounded,
                  title: 'Financial Report',
                  isSelected: false,
                  onTap: () {
                    Navigator.of(context).pop();
                    Get.toNamed(AppRoutes.sellerFinancialReport);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.campaign_outlined,
                  title: 'Promotion Campaign',
                  isSelected: false,
                  onTap: () {
                    Navigator.of(context).pop();
                    Get.toNamed(AppRoutes.sellerPromotions);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.panorama_outlined,
                  title: 'Create Banner',
                  isSelected: false,
                  onTap: () {
                    Navigator.of(context).pop();
                    Get.toNamed(AppRoutes.sellerCreateBanner);
                  },
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // 3. Clean Professional Logout Button
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  controller.logout();
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Icon(Icons.logout_rounded, color: Colors.red, size: 17),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.redAccent,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryPurple.withValues(alpha: 0.09)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryPurple
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? AppColors.primaryPurple : const Color(0xFF1E293B),
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: isSelected ? AppColors.primaryPurple : const Color(0xFFCBD5E1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerDropdownItem({
    required IconData icon,
    required String title,
    required List<Widget> subItems,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent,
          splashColor: AppColors.primaryPurple.withValues(alpha: 0.05),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          childrenPadding: const EdgeInsets.only(left: 28, right: 8, bottom: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          leading: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: const Color(0xFF475569), size: 18),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          iconColor: AppColors.primaryPurple,
          collapsedIconColor: const Color(0xFF94A3B8),
          children: [
            Container(
              padding: const EdgeInsets.only(left: 12),
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                ),
              ),
              child: Column(
                children: subItems,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerSubItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primaryPurple),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF475569),
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 15,
              color: Color(0xFFCBD5E1),
            ),
          ],
        ),
      ),
    );
  }

  // Professional Store & Seller Profile BottomSheet
  void _showStoreProfileBottomSheet(BuildContext context, SellerDashboardController controller) {
    final detailsMap = SessionManager.getSellerStoreDetailsMap() ?? {};

    final storeName = controller.storeName.value.isNotEmpty
        ? controller.storeName.value
        : (detailsMap['StoreName'] ?? detailsMap['storeName'] ?? SessionManager.sellerStoreName ?? 'My Store');
    final tagline = detailsMap['Storetagline']?.toString() ?? detailsMap['tagline']?.toString() ?? 'Official Seller Store';
    final description = detailsMap['description']?.toString() ?? '';
    final contactEmail = detailsMap['StoreContactEmail']?.toString() ?? detailsMap['email']?.toString() ?? controller.sellerEmail.value;
    final whatsapp = detailsMap['StoreWhatsapp']?.toString() ?? detailsMap['whatsapp']?.toString() ?? '';
    final city = detailsMap['PrimaryCity']?.toString() ?? detailsMap['city']?.toString() ?? '';
    final warehouse = detailsMap['WarehouseAddress']?.toString() ?? detailsMap['warehouseAddress']?.toString() ?? '';
    final language = detailsMap['language']?.toString() ?? 'Urdu';
    final returnPolicy = detailsMap['ReturnPolicy']?.toString() ?? detailsMap['returnPolicy']?.toString() ?? '14 days';
    final warranty = detailsMap['Warrenty']?.toString() ?? detailsMap['warranty']?.toString() ?? '6 months';
    final processingTime = detailsMap['ProcessingTime']?.toString() ?? detailsMap['processingTime']?.toString() ?? '5-6 working days';
    final cancellationPolicy = detailsMap['CancellationPolicy']?.toString() ?? detailsMap['cancellationPolicy']?.toString() ?? 'No';
    final shippingMethod = detailsMap['ShippingMethod']?.toString() ?? detailsMap['shippingMethod']?.toString() ?? 'Ecom Courier';
    final deliveryZones = detailsMap['DeliveryZones']?.toString() ?? detailsMap['deliveryZones']?.toString() ?? 'All over Pakistan';
    final shippingCharges = detailsMap['ShippingCharges']?.toString() ?? detailsMap['shippingCharges']?.toString() ?? '200';
    final logoPath = (detailsMap['logo'] != null && detailsMap['logo'].toString().isNotEmpty)
        ? detailsMap['logo'].toString()
        : (controller.storeLogo.value.isNotEmpty ? controller.storeLogo.value : SessionManager.sellerStoreLogo);
    final bannerPath = controller.storeBanner.value.isNotEmpty
        ? controller.storeBanner.value
        : (detailsMap['StoreBanner']?.toString() ?? detailsMap['storeBanner'] ?? detailsMap['banner']?.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.88,
        minChildSize: 0.5,
        maxChildSize: 0.96,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // Header bar with drag handle and close icon
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 10, 12, 12),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4.5,
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: AppColors.primaryPurple.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.storefront_rounded, color: AppColors.primaryPurple, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Store Profile',
                                  style: AppTextStyles.bold.copyWith(fontSize: 17, color: AppColors.darkText),
                                ),
                                Text(
                                  'Verified Business Details',
                                  style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close_rounded, size: 18, color: Colors.black87),
                          ),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

              // Scrollable Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
                  children: [
                    // Premium Store Hero Card (Banner + Overlapping Logo + Badges)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Cover Banner
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                height: 135,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primaryPurple,
                                      AppColors.secondaryViolet,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: _buildAdaptiveImage(
                                  path: bannerPath,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 135,
                                  placeholder: Center(
                                    child: Icon(
                                      Icons.storefront_rounded,
                                      size: 46,
                                      color: Colors.white.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ),
                              ),
                              // Floating Status Pill on Banner
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.verified_rounded, size: 14, color: Colors.greenAccent),
                                      SizedBox(width: 4),
                                      Text(
                                        'Active Store',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Overlapping Circle Logo
                              Positioned(
                                bottom: -30,
                                left: 16,
                                child: Container(
                                  width: 68,
                                  height: 68,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    border: Border.all(color: Colors.white, width: 3),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.12),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: _buildAdaptiveImage(
                                    path: logoPath,
                                    fit: BoxFit.cover,
                                    placeholder: Center(
                                      child: Text(
                                        storeName.isNotEmpty ? storeName[0].toUpperCase() : 'S',
                                        style: AppTextStyles.extraBold.copyWith(
                                          fontSize: 26,
                                          color: AppColors.primaryPurple,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 38),

                          // Store Name & Tagline
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  storeName,
                                  style: AppTextStyles.extraBold.copyWith(
                                    fontSize: 19,
                                    color: AppColors.darkText,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                if (tagline.isNotEmpty) ...[
                                  const SizedBox(height: 3),
                                  Text(
                                    tagline,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                                if (description.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: Text(
                                      description,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: Colors.grey.shade800,
                                        height: 1.45,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Section: Contact & Location Info Card
                    _buildModernInfoCard(
                      title: 'Contact & Location',
                      icon: Icons.contact_mail_outlined,
                      items: [
                        _CardInfoItem(
                          icon: Icons.person_outline_rounded,
                          label: 'Store Owner',
                          value: controller.sellerName.value.isNotEmpty ? controller.sellerName.value : 'Owner',
                        ),
                        _CardInfoItem(
                          icon: Icons.email_outlined,
                          label: 'Contact Email',
                          value: contactEmail.isNotEmpty ? contactEmail : 'Not set',
                        ),
                        if (whatsapp.isNotEmpty)
                          _CardInfoItem(
                            icon: Icons.chat_bubble_outline_rounded,
                            label: 'WhatsApp',
                            value: whatsapp,
                            highlightValue: true,
                          ),
                        if (city.isNotEmpty)
                          _CardInfoItem(
                            icon: Icons.location_city_rounded,
                            label: 'Primary City',
                            value: city,
                          ),
                        if (warehouse.isNotEmpty)
                          _CardInfoItem(
                            icon: Icons.warehouse_outlined,
                            label: 'Warehouse Address',
                            value: warehouse,
                          ),
                        _CardInfoItem(
                          icon: Icons.language_rounded,
                          label: 'Language',
                          value: language,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Section: Shipping & Delivery Card
                    _buildModernInfoCard(
                      title: 'Shipping & Delivery',
                      icon: Icons.local_shipping_outlined,
                      items: [
                        _CardInfoItem(
                          icon: Icons.delivery_dining_outlined,
                          label: 'Shipping Method',
                          value: shippingMethod,
                        ),
                        _CardInfoItem(
                          icon: Icons.map_outlined,
                          label: 'Delivery Coverage',
                          value: deliveryZones,
                        ),
                        _CardInfoItem(
                          icon: Icons.payments_outlined,
                          label: 'Delivery Charges',
                          value: 'Rs. $shippingCharges',
                          highlightValue: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Section: Policies & Guarantees Card
                    _buildModernInfoCard(
                      title: 'Store Policies',
                      icon: Icons.gavel_outlined,
                      items: [
                        _CardInfoItem(
                          icon: Icons.keyboard_return_rounded,
                          label: 'Return Policy',
                          value: returnPolicy,
                        ),
                        _CardInfoItem(
                          icon: Icons.verified_user_outlined,
                          label: 'Warranty',
                          value: warranty,
                        ),
                        _CardInfoItem(
                          icon: Icons.access_time_rounded,
                          label: 'Processing Time',
                          value: processingTime,
                        ),
                        _CardInfoItem(
                          icon: Icons.highlight_off_rounded,
                          label: 'Cancellation Policy',
                          value: cancellationPolicy,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernInfoCard({
    required String title,
    required IconData icon,
    required List<_CardInfoItem> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primaryPurple),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppTextStyles.bold.copyWith(
                    fontSize: 13.5,
                    color: AppColors.darkText,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
          // Items
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            itemCount: items.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
            itemBuilder: (context, index) {
              final item = items[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Icon(item.icon, size: 18, color: const Color(0xFF64748B)),
                    const SizedBox(width: 10),
                    Text(
                      item.label,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Flexible(
                      child: Text(
                        item.value,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: item.highlightValue ? AppColors.primaryPurple : AppColors.darkText,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdaptiveImage({
    required String? path,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    required Widget placeholder,
  }) {
    if (path == null || path.trim().isEmpty) {
      return placeholder;
    }

    final trimmed = path.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return Image.network(
        trimmed,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: width != null && width.isFinite ? (width * 2.5).toInt() : 720,
        errorBuilder: (context, error, stackTrace) => placeholder,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primaryPurple,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        (loadingProgress.expectedTotalBytes ?? 1)
                    : null,
              ),
            ),
          );
        },
      );
    }

    return Image.file(
      File(trimmed),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => placeholder,
    );
  }

  Widget _buildDashboardShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF8FAFC),
      period: const Duration(milliseconds: 1300),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Total Earnings Skeleton Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildSkeletonBox(width: 8, height: 8, borderRadius: 4),
                            const SizedBox(width: 6),
                            _buildSkeletonBox(width: 110, height: 11, borderRadius: 4),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildSkeletonBox(width: 160, height: 26, borderRadius: 6),
                        const SizedBox(height: 8),
                        _buildSkeletonBox(width: 140, height: 11, borderRadius: 4),
                      ],
                    ),
                  ),
                  _buildSkeletonBox(width: 54, height: 54, borderRadius: 16),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. STORE OVERVIEW Header Skeleton
            _buildSkeletonBox(width: 120, height: 12, borderRadius: 4),
            const SizedBox(height: 12),

            // 3. Overview Stat Cards (3 Rows of 2)
            Row(
              children: [
                Expanded(child: _buildStatCardSkeleton()),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCardSkeleton()),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildStatCardSkeleton()),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCardSkeleton()),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildStatCardSkeleton()),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCardSkeleton()),
              ],
            ),
            const SizedBox(height: 20),

            // 4. Order Status Donut Chart Card Skeleton
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildSkeletonBox(width: 32, height: 32, borderRadius: 8),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSkeletonBox(width: 100, height: 14, borderRadius: 4),
                          const SizedBox(height: 5),
                          _buildSkeletonBox(width: 170, height: 11, borderRadius: 4),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  // Donut Ring Silhouette
                  Center(
                    child: Container(
                      width: 170,
                      height: 170,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFF1F5F9),
                      ),
                      child: Center(
                        child: Container(
                          width: 118,
                          height: 118,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildSkeletonBox(width: 42, height: 20, borderRadius: 4),
                              const SizedBox(height: 5),
                              _buildSkeletonBox(width: 68, height: 9, borderRadius: 3),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  // 2x2 Status Legend Grid Skeleton
                  Row(
                    children: [
                      Expanded(child: _buildStatusChipSkeleton()),
                      const SizedBox(width: 10),
                      Expanded(child: _buildStatusChipSkeleton()),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _buildStatusChipSkeleton()),
                      const SizedBox(width: 10),
                      Expanded(child: _buildStatusChipSkeleton()),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 5. Payout Breakdown Card Skeleton
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildSkeletonBox(width: 32, height: 32, borderRadius: 8),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSkeletonBox(width: 120, height: 14, borderRadius: 4),
                          const SizedBox(height: 5),
                          _buildSkeletonBox(width: 190, height: 11, borderRadius: 4),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildPayoutPillarSkeleton(),
                      _buildPayoutPillarSkeleton(),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 6. Delivered Products Card Skeleton
            _buildProductsCardSkeleton('Delivered Products'),
            const SizedBox(height: 16),

            // 7. Refunded Products Card Skeleton
            _buildProductsCardSkeleton('Refunded Products'),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonBox({
    required double width,
    required double height,
    double borderRadius = 6,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  Widget _buildStatCardSkeleton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSkeletonBox(width: 75, height: 11, borderRadius: 4),
              _buildSkeletonBox(width: 28, height: 28, borderRadius: 8),
            ],
          ),
          const SizedBox(height: 12),
          _buildSkeletonBox(width: 45, height: 20, borderRadius: 5),
        ],
      ),
    );
  }

  Widget _buildStatusChipSkeleton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          _buildSkeletonBox(width: 9, height: 9, borderRadius: 5),
          const SizedBox(width: 8),
          Expanded(child: _buildSkeletonBox(width: 45, height: 10, borderRadius: 3)),
          _buildSkeletonBox(width: 18, height: 12, borderRadius: 3),
        ],
      ),
    );
  }

  Widget _buildPayoutPillarSkeleton() {
    return Column(
      children: [
        _buildSkeletonBox(width: 60, height: 13, borderRadius: 4),
        const SizedBox(height: 10),
        Container(
          width: 58,
          height: 118,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
        ),
        const SizedBox(height: 9),
        _buildSkeletonBox(width: 36, height: 11, borderRadius: 3),
      ],
    );
  }

  Widget _buildProductsCardSkeleton(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSkeletonBox(width: 130, height: 14, borderRadius: 4),
                    const SizedBox(height: 5),
                    _buildSkeletonBox(width: 180, height: 11, borderRadius: 4),
                  ],
                ),
              ),
              _buildSkeletonBox(width: 58, height: 20, borderRadius: 8),
            ],
          ),
          const SizedBox(height: 16),
          _buildProductRowSkeleton(),
          const SizedBox(height: 8),
          _buildProductRowSkeleton(),
        ],
      ),
    );
  }

  Widget _buildProductRowSkeleton() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          _buildSkeletonBox(width: 44, height: 44, borderRadius: 8),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSkeletonBox(width: 120, height: 12, borderRadius: 4),
                const SizedBox(height: 6),
                _buildSkeletonBox(width: 80, height: 10, borderRadius: 3),
              ],
            ),
          ),
          _buildSkeletonBox(width: 50, height: 14, borderRadius: 4),
        ],
      ),
    );
  }

  // ==========================================
  // GRAPHICAL ANALYTICS WIDGETS (MOBILE OPTIMIZED)
  // ==========================================

  Widget _buildOrderStatusGraphCard(SellerDashboardController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.pie_chart_outline_rounded, size: 18, color: Color(0xFF0F172A)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Status',
                      style: AppTextStyles.bold.copyWith(
                        fontSize: 15,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 1),
                    const Text(
                      'Distribution across all order statuses',
                      style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Native Donut Chart for Mobile
          Obx(() {
            final active = controller.stats.value.activeOrders;
            final delivered = controller.stats.value.deliveredOrders;
            final cancelled = controller.stats.value.cancelledOrders;
            final returned = controller.stats.value.returnedOrders;
            final total = controller.stats.value.totalOrders > 0
                ? controller.stats.value.totalOrders
                : (controller.deliveredOrders.length + controller.refundedOrders.length);

            return Center(
              child: SizedBox(
                width: 170,
                height: 170,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(170, 170),
                      painter: _DonutChartPainter(
                        active: active,
                        delivered: delivered,
                        cancelled: cancelled,
                        returned: returned,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$total',
                          style: AppTextStyles.extraBold.copyWith(
                            fontSize: 28,
                            color: const Color(0xFF0F172A),
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'TOTAL ORDERS',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF64748B),
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 20),

          // Interactive Status Indicators Grid
          Obx(() => Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatusLegendChip(
                      label: 'Active',
                      count: controller.stats.value.activeOrders,
                      color: const Color(0xFFF59E0B),
                      onTap: () => Get.toNamed(
                        AppRoutes.sellerOrders,
                        arguments: {'tab': 'Processing'},
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatusLegendChip(
                      label: 'Delivered',
                      count: controller.stats.value.deliveredOrders,
                      color: const Color(0xFF10B981),
                      onTap: () => Get.toNamed(
                        AppRoutes.sellerOrders,
                        arguments: {'tab': 'Completed'},
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildStatusLegendChip(
                      label: 'Cancelled',
                      count: controller.stats.value.cancelledOrders,
                      color: const Color(0xFFEF4444),
                      onTap: () => Get.toNamed(
                        AppRoutes.sellerOrders,
                        arguments: {'tab': 'Cancelled'},
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatusLegendChip(
                      label: 'Returned',
                      count: controller.stats.value.returnedOrders,
                      color: const Color(0xFF06B6D4),
                      onTap: () => Get.toNamed(
                        AppRoutes.sellerOrders,
                        arguments: {'tab': 'Cancelled'},
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildStatusLegendChip({
    required String label,
    required int count,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayoutBreakdownCard(SellerDashboardController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.bar_chart_rounded, size: 18, color: Color(0xFFF59E0B)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payout Breakdown',
                      style: AppTextStyles.bold.copyWith(
                        fontSize: 15,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 1),
                    const Text(
                      'How much of your earning has been paid out',
                      style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Two Bar Pillars matching web dashboard screenshot
          Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPayoutBarColumn(
                label: 'Paid',
                amount: controller.paidAmount.value,
                bottomColor: const Color(0xFFF59E0B),
              ),
              _buildPayoutBarColumn(
                label: 'Unpaid',
                amount: controller.unpaidAmount.value,
                bottomColor: const Color(0xFF0F172A),
              ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildPayoutBarColumn({
    required String label,
    required double amount,
    required Color bottomColor,
  }) {
    final String formatted = 'Rs. ${amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2)}';

    return Column(
      children: [
        Text(
          formatted,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: 58,
          height: 118,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            height: 7,
            decoration: BoxDecoration(
              color: bottomColor,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(9)),
            ),
          ),
        ),
        const SizedBox(height: 9),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveredProductsCard(SellerDashboardController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivered Products',
                      style: AppTextStyles.bold.copyWith(
                        fontSize: 15,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Recent orders fulfilled from your store',
                      style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              Obx(() => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Text(
                      '${controller.deliveredOrders.length} item(s)',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFD97706),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => Get.toNamed(
                      AppRoutes.sellerOrders,
                      arguments: {'tab': 'Completed'},
                    ),
                    child: const Text(
                      'View all',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ],
              )),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            final orders = controller.deliveredOrders;
            if (orders.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: const Center(
                  child: Text(
                    'No delivered products yet.',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: orders.take(3).map((order) {
                final firstItem = order.items.isNotEmpty ? order.items.first : null;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 44,
                          height: 44,
                          color: const Color(0xFFE2E8F0),
                          child: firstItem != null && firstItem.image.isNotEmpty
                              ? Image.network(firstItem.image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.inventory_2_outlined, size: 20))
                              : const Icon(Icons.inventory_2_outlined, size: 20),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              firstItem?.productName ?? order.displayOrderId,
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${order.displayOrderId} • ${order.buyerName.isNotEmpty ? order.buyerName : "Customer"}',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Rs. ${order.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF10B981)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRefundedProductsCard(SellerDashboardController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Refunded Products',
                      style: AppTextStyles.bold.copyWith(
                        fontSize: 15,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Orders that were refunded after delivery',
                      style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              Obx(() => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Text(
                      '${controller.refundedOrders.length} item(s)',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFD97706),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => Get.toNamed(
                      AppRoutes.sellerOrders,
                      arguments: {'tab': 'Cancelled'},
                    ),
                    child: const Text(
                      'View all',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ],
              )),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            final orders = controller.refundedOrders;
            if (orders.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: const Center(
                  child: Text(
                    'No refunded products.',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: orders.take(3).map((order) {
                final firstItem = order.items.isNotEmpty ? order.items.first : null;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 44,
                          height: 44,
                          color: const Color(0xFFE2E8F0),
                          child: firstItem != null && firstItem.image.isNotEmpty
                              ? Image.network(firstItem.image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.assignment_return_outlined, size: 20))
                              : const Icon(Icons.assignment_return_outlined, size: 20),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              firstItem?.productName ?? order.displayOrderId,
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${order.displayOrderId} • Refunded / Cancelled',
                              style: const TextStyle(fontSize: 11, color: Color(0xFFEF4444)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Rs. ${order.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFFEF4444)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final int active;
  final int delivered;
  final int cancelled;
  final int returned;

  const _DonutChartPainter({
    required this.active,
    required this.delivered,
    required this.cancelled,
    required this.returned,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 24) / 2;
    const strokeWidth = 14.0;

    final backgroundPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    final total = active + delivered + cancelled + returned;
    if (total == 0) return;

    final segments = [
      {'val': active, 'color': const Color(0xFFF59E0B)},
      {'val': delivered, 'color': const Color(0xFF10B981)},
      {'val': cancelled, 'color': const Color(0xFFEF4444)},
      {'val': returned, 'color': const Color(0xFF06B6D4)},
    ];

    double startAngle = -3.1415926535 / 2;
    for (final seg in segments) {
      final val = seg['val'] as int;
      if (val <= 0) continue;
      final sweepAngle = (val / total) * 2 * 3.1415926535;
      final paint = Paint()
        ..color = seg['color'] as Color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + 0.03,
        (sweepAngle - 0.06).clamp(0.01, 2 * 3.1415926535),
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.active != active ||
        oldDelegate.delivered != delivered ||
        oldDelegate.cancelled != cancelled ||
        oldDelegate.returned != returned;
  }
}

class _CardInfoItem {
  final IconData icon;
  final String label;
  final String value;
  final bool highlightValue;

  const _CardInfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.highlightValue = false,
  });
}
