import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/utils/session_manager.dart';
import '../../../../core/utils/custom_popup.dart';
import '../../../../core/widgets/report_modal_bottom_sheet.dart';
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
          _scaffoldKey.currentState?.closeDrawer();
          return;
        }
        final confirm = await CustomPopup.showSwitchToBuyerConfirmation();
        if (confirm ?? false) {
          SessionManager.setLastScreen(AppRoutes.mainLayout);
          Get.offAllNamed(AppRoutes.mainLayout);
        }
      },
      child: Scaffold(
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
                gradient: const LinearGradient(
                  colors: [AppColors.primaryPurple, AppColors.secondaryViolet],
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPurple.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            Text(
              'Seller Center',
              style: AppTextStyles.bold.copyWith(color: AppColors.darkText, fontSize: 17),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14.0),
            child: InkWell(
              onTap: () => _showStoreProfileBottomSheet(context, controller),
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: AppColors.primaryPurple.withValues(alpha: 0.25),
                        width: 1.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryPurple.withValues(alpha: 0.12),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
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
                            style: AppTextStyles.bold.copyWith(
                              color: AppColors.primaryPurple,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryPurple.withValues(alpha: 0.04),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Store Avatar with verified active ring
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [AppColors.primaryPurple, AppColors.secondaryViolet],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryPurple.withValues(alpha: 0.22),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(2), // border width
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
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
                                      style: AppTextStyles.extraBold.copyWith(
                                        color: AppColors.primaryPurple,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 13,
                              height: 13,
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      // Store Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Obx(() => Text(
                                    controller.storeName.value.isNotEmpty ? controller.storeName.value : 'My Store',
                                    style: AppTextStyles.bold.copyWith(fontSize: 15.5, color: AppColors.darkText),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 16),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFFA7F3D0)),
                                  ),
                                  child: const Text(
                                    '● Live & Active',
                                    style: TextStyle(
                                      color: Color(0xFF059669),
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Obx(() {
                                  final sellerName = controller.sellerName.value;
                                  if (sellerName.isEmpty) return const SizedBox.shrink();
                                  return Flexible(
                                    child: Text(
                                      sellerName,
                                      style: const TextStyle(
                                        color: Color(0xFF64748B),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ],
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
                        value: '${controller.stats.value.deliveredOrders > 0 ? controller.stats.value.deliveredOrders : controller.deliveredOrders.length}',
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
                        value: '${controller.stats.value.returnedOrders > 0 ? controller.stats.value.returnedOrders : controller.refundedOrders.length}',
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
    ),
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

  void _navigateFromDrawer(Future<dynamic>? Function() navigate) {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
    navigate()?.then((_) {
      if (mounted) {
        controller.fetchDashboardStats();
      }
    });
  }

  // Executive Navigation Sidebar Drawer
  Widget _buildSidebarDrawer(BuildContext context, SellerDashboardController controller) {
    return Drawer(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 20,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // 1. Executive Modern Header with Store Branding & Quick Details Action
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              18,
              MediaQuery.of(context).padding.top + 16,
              16,
              18,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1E1B4B),
                  Color(0xFF312E81),
                  AppColors.primaryPurple,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row with USHU Partner badge & close icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.verified_rounded, size: 12, color: Color(0xFF4ADE80)),
                          SizedBox(width: 4),
                          Text(
                            'USHU Partner Store',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded, size: 17, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Store Logo & Name
                Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: Colors.white, width: 2.2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 10,
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
                              width: 54,
                              height: 54,
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
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 13,
                            height: 13,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() => Text(
                            controller.storeName.value.isNotEmpty
                                ? controller.storeName.value
                                : 'My Store',
                            style: AppTextStyles.bold.copyWith(
                              color: Colors.white,
                              fontSize: 16.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )),
                          const SizedBox(height: 5),
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                              _showStoreProfileBottomSheet(context, controller);
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.storefront_rounded, size: 12, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text(
                                    'Store Details',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 2),
                                  Icon(Icons.arrow_forward_ios_rounded, size: 8, color: Colors.white70),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Divider(height: 1, color: Colors.white.withValues(alpha: 0.16)),
                const SizedBox(height: 9),
                Row(
                  children: [
                    Icon(
                      Icons.mail_outline_rounded,
                      size: 13.5,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Obx(() => Text(
                        controller.sellerEmail.value.isNotEmpty
                            ? controller.sellerEmail.value
                            : (controller.sellerName.value.isNotEmpty
                                ? controller.sellerName.value
                                : 'Seller Account'),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 11.5,
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

          // 2. Executive Navigation List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              children: [
                _buildDrawerSectionHeader('MAIN MENU'),
                _buildDrawerItem(
                  icon: Icons.grid_view_rounded,
                  title: 'Dashboard',
                  isSelected: true,
                  onTap: () {
                    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.person_outline_rounded,
                  title: 'Seller Profile & Password',
                  isSelected: false,
                  onTap: () {
                    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
                      Navigator.of(context).pop();
                    }
                    _showEditSellerProfileDialog(
                      context: context,
                      controller: controller,
                      currentFullName: controller.sellerName.value.isNotEmpty
                          ? controller.sellerName.value
                          : controller.sellerProfile.value.fullName,
                      currentPhone: controller.sellerPhone.value.isNotEmpty
                          ? controller.sellerPhone.value
                          : controller.sellerProfile.value.phoneNumber,
                      onUpdated: () {},
                    );
                  },
                ),
                const SizedBox(height: 10),

                _buildDrawerSectionHeader('INVENTORY & SALES'),
                _buildDrawerDropdownItem(
                  icon: Icons.inventory_2_outlined,
                  title: 'Products',
                  subItems: [
                    _buildDrawerSubItem(
                      icon: Icons.view_list_rounded,
                      title: 'Manage Products',
                      onTap: () => _navigateFromDrawer(() => Get.toNamed(
                        AppRoutes.sellerManageProducts,
                        arguments: {'storeId': SessionManager.sellerStoreId ?? ''},
                      )),
                    ),
                    _buildDrawerSubItem(
                      icon: Icons.add_circle_outline_rounded,
                      title: 'Add Product',
                      onTap: () {
                        if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
                          Navigator.of(context).pop();
                        }
                        controller.navigateToAddProduct();
                      },
                    ),
                    _buildDrawerSubItem(
                      icon: Icons.bolt_rounded,
                      title: 'Create Flash Sale',
                      onTap: () => _navigateFromDrawer(() => Get.toNamed(AppRoutes.sellerCreateFlashSale)),
                    ),
                    _buildDrawerSubItem(
                      icon: Icons.local_offer_outlined,
                      title: 'Manage Sales Products',
                      onTap: () => _navigateFromDrawer(() => Get.toNamed(AppRoutes.sellerManageFlashSales)),
                    ),
                  ],
                ),
                _buildDrawerItem(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Order Management',
                  isSelected: false,
                  onTap: () => _navigateFromDrawer(() => Get.toNamed(AppRoutes.sellerOrders)),
                ),
                _buildDrawerItem(
                  icon: Icons.assignment_return_outlined,
                  title: 'Returned Orders',
                  isSelected: false,
                  onTap: () => _navigateFromDrawer(() => Get.toNamed(
                    AppRoutes.sellerOrders,
                    arguments: {'tab': 'Cancelled'},
                  )),
                ),
                const SizedBox(height: 10),

                _buildDrawerSectionHeader('GROWTH & MARKETING'),
                _buildDrawerItem(
                  icon: Icons.bar_chart_rounded,
                  title: 'Financial Report',
                  isSelected: false,
                  onTap: () => _navigateFromDrawer(() => Get.toNamed(AppRoutes.sellerFinancialReport)),
                ),
                _buildDrawerItem(
                  icon: Icons.campaign_outlined,
                  title: 'Promotion Campaign',
                  isSelected: false,
                  onTap: () => _navigateFromDrawer(() => Get.toNamed(AppRoutes.sellerPromotions)),
                ),
                const SizedBox(height: 10),

                _buildDrawerSectionHeader('SWITCH & SUPPORT'),
                _buildDrawerItem(
                  icon: Icons.swap_horiz_rounded,
                  title: 'Switch to Buyer App',
                  isSelected: false,
                  onTap: () async {
                    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
                      Navigator.of(context).pop();
                    }
                    final confirm = await CustomPopup.showSwitchToBuyerConfirmation();
                    if (confirm ?? false) {
                      SessionManager.setLastScreen(AppRoutes.mainLayout);
                      Get.offAllNamed(AppRoutes.mainLayout);
                    }
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.flag_outlined,
                  title: 'Report Buyer / Issue',
                  isSelected: false,
                  onTap: () {
                    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
                      Navigator.of(context).pop();
                    }
                    ReportModalBottomSheet.show(
                      context: context,
                      targetType: 'Buyer',
                      targetId: '',
                      initialReason: 'Unfair Review',
                      isSeller: true,
                    );
                  },
                ),
                const SizedBox(height: 10),

                _buildDrawerSectionHeader('ACCOUNT SECURITY'),
                _buildDrawerItem(
                  icon: Icons.delete_outline_rounded,
                  title: 'Delete Seller Account',
                  isSelected: false,
                  textColor: const Color(0xFFDC2626),
                  iconColor: const Color(0xFFDC2626),
                  containerBgColor: const Color(0xFFFEF2F2),
                  onTap: () {
                    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
                      Navigator.of(context).pop();
                    }
                    controller.deleteSellerAccount();
                  },
                ),
              ],
            ),
          ),

          // 3. Clean Professional Logout & App Info Footer
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDrawerItem(
                    icon: Icons.logout_rounded,
                    title: 'Logout Account',
                    isSelected: false,
                    textColor: const Color(0xFFDC2626),
                    iconColor: const Color(0xFFDC2626),
                    containerBgColor: const Color(0xFFFEF2F2),
                    onTap: () {
                      if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
                        Navigator.of(context).pop();
                      }
                      controller.logout();
                    },
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'USHU Seller Center • v1.0.0',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Colors.grey.shade400,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
    Color? containerBgColor,
  }) {
    final effectiveIconColor = iconColor ?? (isSelected ? Colors.white : AppColors.primaryPurple);
    final effectiveTextColor = textColor ?? (isSelected ? AppColors.primaryPurple : const Color(0xFF1E293B));
    final effectiveBg = containerBgColor ?? (isSelected ? AppColors.primaryPurple : const Color(0xFFF8FAFC));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryPurple.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(13),
            border: isSelected
                ? Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.2))
                : Border.all(color: Colors.transparent),
          ),
          child: Row(
            children: [
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: effectiveBg,
                  borderRadius: BorderRadius.circular(10),
                  border: isSelected
                      ? null
                      : Border.all(color: containerBgColor != null ? containerBgColor.withValues(alpha: 0.4) : const Color(0xFFE2E8F0)),
                ),
                child: Icon(
                  icon,
                  color: effectiveIconColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: effectiveTextColor,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 17,
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
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent,
          splashColor: AppColors.primaryPurple.withValues(alpha: 0.05),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          childrenPadding: const EdgeInsets.only(left: 26, right: 8, bottom: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
          collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
          leading: Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Icon(icon, color: AppColors.primaryPurple, size: 18),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          iconColor: AppColors.primaryPurple,
          collapsedIconColor: const Color(0xFF94A3B8),
          children: [
            Container(
              padding: const EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: AppColors.primaryPurple.withValues(alpha: 0.3), width: 1.5),
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
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 14, color: AppColors.primaryPurple),
            ),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (sheetContext, setSheetState) {
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

          return DraggableScrollableSheet(
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
                            Expanded(
                              child: Row(
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
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Store Details',
                                          style: AppTextStyles.bold.copyWith(fontSize: 17, color: AppColors.darkText),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'Verified Business & Operations',
                                          style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () => _showEditStoreBottomSheet(
                                    context: context,
                                    controller: controller,
                                    initialTab: 0,
                                    onUpdated: () => setSheetState(() {}),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryPurple.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.2)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.edit_note_rounded, size: 16, color: AppColors.primaryPurple),
                                        SizedBox(width: 4),
                                        Text(
                                          'Edit',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryPurple,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: Container(
                                    padding: const EdgeInsets.all(5),
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
                        // Premium Store Hero Card (Banner + Overlapping Logo + Badges + Edit Profile)
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

                              // Store Name, Badges & Edit Profile
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    storeName,
                                                    style: AppTextStyles.extraBold.copyWith(
                                                      fontSize: 19,
                                                      color: AppColors.darkText,
                                                      letterSpacing: -0.3,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                const Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 18),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          InkWell(
                                            onTap: () => _showEditStoreProfileDialog(
                                            context: context,
                                            controller: controller,
                                            currentStoreName: storeName,
                                            currentTagline: tagline,
                                            currentDescription: description,
                                            onUpdated: () => setSheetState(() {}),
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryPurple.withValues(alpha: 0.08),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.15)),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: const [
                                                Icon(Icons.edit_outlined, size: 14, color: AppColors.primaryPurple),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Edit Profile',
                                                  style: TextStyle(
                                                    fontSize: 11.5,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.primaryPurple,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
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
                                    const SizedBox(height: 10),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFECFDF5),
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(color: const Color(0xFFA7F3D0)),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.check_circle_rounded, size: 13, color: Color(0xFF10B981)),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Verified Merchant',
                                                  style: TextStyle(
                                                    color: Color(0xFF059669),
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryPurple.withValues(alpha: 0.08),
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.2)),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.local_shipping_rounded, size: 13, color: AppColors.primaryPurple),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Pakistan-wide Delivery',
                                                  style: TextStyle(
                                                    color: AppColors.primaryPurple,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    // Interactive Description Box with Edit Icon
                                    InkWell(
                                      onTap: () => _showEditStoreProfileDialog(
                                        context: context,
                                        controller: controller,
                                        currentStoreName: storeName,
                                        currentTagline: tagline,
                                        currentDescription: description,
                                        onUpdated: () => setSheetState(() {}),
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8FAFC),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: const Color(0xFFE2E8F0)),
                                        ),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                description.isNotEmpty
                                                    ? description
                                                    : 'Add a store description to help customers learn about your brand and products...',
                                                style: TextStyle(
                                                  fontSize: 12.5,
                                                  color: description.isNotEmpty ? Colors.grey.shade800 : Colors.grey.shade500,
                                                  fontStyle: description.isNotEmpty ? FontStyle.normal : FontStyle.italic,
                                                  height: 1.45,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Icon(
                                              Icons.edit_outlined,
                                              size: 15,
                                              color: AppColors.primaryPurple.withValues(alpha: 0.8),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Section: Seller Profile & Identity (from GET /seller/me)
                        Obx(() {
                          final sellerFullName = controller.sellerName.value.isNotEmpty
                              ? controller.sellerName.value
                              : (controller.sellerProfile.value.fullName.isNotEmpty
                                  ? controller.sellerProfile.value.fullName
                                  : 'Seller Account');
                          final sellerEmailVal = controller.sellerEmail.value.isNotEmpty
                              ? controller.sellerEmail.value
                              : (controller.sellerProfile.value.email.isNotEmpty
                                  ? controller.sellerProfile.value.email
                                  : contactEmail);
                          final sellerPhoneVal = controller.sellerPhone.value.isNotEmpty
                              ? controller.sellerPhone.value
                              : controller.sellerProfile.value.phoneNumber;
                          final sellerStatusVal = controller.sellerStatus.value.isNotEmpty
                              ? controller.sellerStatus.value
                              : (controller.sellerProfile.value.status.isNotEmpty
                                  ? controller.sellerProfile.value.status
                                  : 'Approved');
                          final businessTypeVal = controller.businessType.value.isNotEmpty
                              ? controller.businessType.value
                              : controller.sellerProfile.value.businessType;
                          final cnicVal = controller.cnic.value.isNotEmpty
                              ? controller.cnic.value
                              : controller.sellerProfile.value.cnic;
                          final bankNameVal = controller.bankName.value.isNotEmpty
                              ? controller.bankName.value
                              : controller.sellerProfile.value.bankName;
                          final ibanVal = controller.ibanNumber.value.isNotEmpty
                              ? controller.ibanNumber.value
                              : controller.sellerProfile.value.ibanNumber;

                          return _buildModernInfoCard(
                            title: 'Seller Account Profile',
                            icon: Icons.badge_outlined,
                            onEdit: () => _showEditSellerProfileDialog(
                              context: context,
                              controller: controller,
                              currentFullName: sellerFullName,
                              currentPhone: sellerPhoneVal,
                              onUpdated: () => setSheetState(() {}),
                            ),
                            items: [
                              _CardInfoItem(
                                icon: Icons.person_rounded,
                                label: 'Full Name',
                                value: sellerFullName,
                              ),
                              _CardInfoItem(
                                icon: Icons.email_outlined,
                                label: 'Account Email',
                                value: sellerEmailVal.isNotEmpty ? sellerEmailVal : 'Not set',
                              ),
                              if (sellerPhoneVal.isNotEmpty)
                                _CardInfoItem(
                                  icon: Icons.phone_android_rounded,
                                  label: 'Registered Phone',
                                  value: sellerPhoneVal,
                                ),
                              _CardInfoItem(
                                icon: Icons.verified_user_rounded,
                                label: 'Account Status',
                                value: sellerStatusVal,
                                highlightValue: true,
                              ),
                              if (businessTypeVal.isNotEmpty)
                                _CardInfoItem(
                                  icon: Icons.business_center_outlined,
                                  label: 'Business Type',
                                  value: businessTypeVal,
                                ),
                              if (cnicVal.isNotEmpty)
                                _CardInfoItem(
                                  icon: Icons.credit_card_rounded,
                                  label: 'CNIC / National ID',
                                  value: cnicVal,
                                ),
                              if (bankNameVal.isNotEmpty)
                                _CardInfoItem(
                                  icon: Icons.account_balance_outlined,
                                  label: 'Bank Name',
                                  value: bankNameVal,
                                ),
                              if (ibanVal.isNotEmpty)
                                _CardInfoItem(
                                  icon: Icons.account_balance_wallet_outlined,
                                  label: 'IBAN / Account #',
                                  value: ibanVal,
                                ),
                            ],
                          );
                        }),
                        const SizedBox(height: 16),

                        // Section: Contact & Location Info Card with Edit Icon
                        _buildModernInfoCard(
                          title: 'Contact & Location',
                          icon: Icons.contact_mail_outlined,
                          onEdit: () => _showEditContactLocationDialog(
                            context: context,
                            controller: controller,
                            currentEmail: contactEmail,
                            currentWhatsapp: whatsapp,
                            currentCity: city,
                            currentWarehouse: warehouse,
                            onUpdated: () => setSheetState(() {}),
                          ),
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
                              onEdit: () => _showEditContactLocationDialog(
                                context: context,
                                controller: controller,
                                currentEmail: contactEmail,
                                currentWhatsapp: whatsapp,
                                currentCity: city,
                                currentWarehouse: warehouse,
                                onUpdated: () => setSheetState(() {}),
                              ),
                            ),
                            _CardInfoItem(
                              icon: Icons.chat_bubble_outline_rounded,
                              label: 'WhatsApp',
                              value: whatsapp.isNotEmpty ? whatsapp : 'Not set',
                              highlightValue: whatsapp.isNotEmpty,
                              onEdit: () => _showEditContactLocationDialog(
                                context: context,
                                controller: controller,
                                currentEmail: contactEmail,
                                currentWhatsapp: whatsapp,
                                currentCity: city,
                                currentWarehouse: warehouse,
                                onUpdated: () => setSheetState(() {}),
                              ),
                            ),
                            _CardInfoItem(
                              icon: Icons.location_city_rounded,
                              label: 'Primary City',
                              value: city.isNotEmpty ? city : 'Not set',
                              onEdit: () => _showEditContactLocationDialog(
                                context: context,
                                controller: controller,
                                currentEmail: contactEmail,
                                currentWhatsapp: whatsapp,
                                currentCity: city,
                                currentWarehouse: warehouse,
                                onUpdated: () => setSheetState(() {}),
                              ),
                            ),
                            _CardInfoItem(
                              icon: Icons.warehouse_outlined,
                              label: 'Warehouse Address',
                              value: warehouse.isNotEmpty ? warehouse : 'Not set',
                              onEdit: () => _showEditContactLocationDialog(
                                context: context,
                                controller: controller,
                                currentEmail: contactEmail,
                                currentWhatsapp: whatsapp,
                                currentCity: city,
                                currentWarehouse: warehouse,
                                onUpdated: () => setSheetState(() {}),
                              ),
                            ),
                            _CardInfoItem(
                              icon: Icons.language_rounded,
                              label: 'Language',
                              value: language,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Section: Shipping & Delivery Card with Edit Icon
                        _buildModernInfoCard(
                          title: 'Shipping & Delivery',
                          icon: Icons.local_shipping_outlined,
                          onEdit: () => _showEditPoliciesDialog(
                            context: context,
                            controller: controller,
                            currentShippingMethod: shippingMethod,
                            currentDeliveryZones: deliveryZones,
                            currentShippingCharges: shippingCharges,
                            currentReturnPolicy: returnPolicy,
                            currentWarranty: warranty,
                            currentProcessingTime: processingTime,
                            currentCancellationPolicy: cancellationPolicy,
                            onUpdated: () => setSheetState(() {}),
                          ),
                          items: [
                            _CardInfoItem(
                              icon: Icons.delivery_dining_outlined,
                              label: 'Shipping Method',
                              value: shippingMethod,
                              onEdit: () => _showEditPoliciesDialog(
                                context: context,
                                controller: controller,
                                currentShippingMethod: shippingMethod,
                                currentDeliveryZones: deliveryZones,
                                currentShippingCharges: shippingCharges,
                                currentReturnPolicy: returnPolicy,
                                currentWarranty: warranty,
                                currentProcessingTime: processingTime,
                                currentCancellationPolicy: cancellationPolicy,
                                onUpdated: () => setSheetState(() {}),
                              ),
                            ),
                            _CardInfoItem(
                              icon: Icons.map_outlined,
                              label: 'Delivery Coverage',
                              value: deliveryZones,
                              onEdit: () => _showEditPoliciesDialog(
                                context: context,
                                controller: controller,
                                currentShippingMethod: shippingMethod,
                                currentDeliveryZones: deliveryZones,
                                currentShippingCharges: shippingCharges,
                                currentReturnPolicy: returnPolicy,
                                currentWarranty: warranty,
                                currentProcessingTime: processingTime,
                                currentCancellationPolicy: cancellationPolicy,
                                onUpdated: () => setSheetState(() {}),
                              ),
                            ),
                            _CardInfoItem(
                              icon: Icons.payments_outlined,
                              label: 'Delivery Charges',
                              value: 'Rs. $shippingCharges',
                              highlightValue: true,
                              onEdit: () => _showEditPoliciesDialog(
                                context: context,
                                controller: controller,
                                currentShippingMethod: shippingMethod,
                                currentDeliveryZones: deliveryZones,
                                currentShippingCharges: shippingCharges,
                                currentReturnPolicy: returnPolicy,
                                currentWarranty: warranty,
                                currentProcessingTime: processingTime,
                                currentCancellationPolicy: cancellationPolicy,
                                onUpdated: () => setSheetState(() {}),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Section: Policies & Guarantees Card with Edit Icon
                        _buildModernInfoCard(
                          title: 'Store Policies',
                          icon: Icons.gavel_outlined,
                          onEdit: () => _showEditPoliciesDialog(
                            context: context,
                            controller: controller,
                            currentShippingMethod: shippingMethod,
                            currentDeliveryZones: deliveryZones,
                            currentShippingCharges: shippingCharges,
                            currentReturnPolicy: returnPolicy,
                            currentWarranty: warranty,
                            currentProcessingTime: processingTime,
                            currentCancellationPolicy: cancellationPolicy,
                            onUpdated: () => setSheetState(() {}),
                          ),
                          items: [
                            _CardInfoItem(
                              icon: Icons.keyboard_return_rounded,
                              label: 'Return Policy',
                              value: returnPolicy,
                              onEdit: () => _showEditPoliciesDialog(
                                context: context,
                                controller: controller,
                                currentShippingMethod: shippingMethod,
                                currentDeliveryZones: deliveryZones,
                                currentShippingCharges: shippingCharges,
                                currentReturnPolicy: returnPolicy,
                                currentWarranty: warranty,
                                currentProcessingTime: processingTime,
                                currentCancellationPolicy: cancellationPolicy,
                                onUpdated: () => setSheetState(() {}),
                              ),
                            ),
                            _CardInfoItem(
                              icon: Icons.verified_user_outlined,
                              label: 'Warranty',
                              value: warranty,
                              onEdit: () => _showEditPoliciesDialog(
                                context: context,
                                controller: controller,
                                currentShippingMethod: shippingMethod,
                                currentDeliveryZones: deliveryZones,
                                currentShippingCharges: shippingCharges,
                                currentReturnPolicy: returnPolicy,
                                currentWarranty: warranty,
                                currentProcessingTime: processingTime,
                                currentCancellationPolicy: cancellationPolicy,
                                onUpdated: () => setSheetState(() {}),
                              ),
                            ),
                            _CardInfoItem(
                              icon: Icons.access_time_rounded,
                              label: 'Processing Time',
                              value: processingTime,
                              onEdit: () => _showEditPoliciesDialog(
                                context: context,
                                controller: controller,
                                currentShippingMethod: shippingMethod,
                                currentDeliveryZones: deliveryZones,
                                currentShippingCharges: shippingCharges,
                                currentReturnPolicy: returnPolicy,
                                currentWarranty: warranty,
                                currentProcessingTime: processingTime,
                                currentCancellationPolicy: cancellationPolicy,
                                onUpdated: () => setSheetState(() {}),
                              ),
                            ),
                            _CardInfoItem(
                              icon: Icons.highlight_off_rounded,
                              label: 'Cancellation Policy',
                              value: cancellationPolicy,
                              onEdit: () => _showEditPoliciesDialog(
                                context: context,
                                controller: controller,
                                currentShippingMethod: shippingMethod,
                                currentDeliveryZones: deliveryZones,
                                currentShippingCharges: shippingCharges,
                                currentReturnPolicy: returnPolicy,
                                currentWarranty: warranty,
                                currentProcessingTime: processingTime,
                                currentCancellationPolicy: cancellationPolicy,
                                onUpdated: () => setSheetState(() {}),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModernInfoCard({
    required String title,
    required IconData icon,
    required List<_CardInfoItem> items,
    VoidCallback? onEdit,
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
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(icon, size: 18, color: AppColors.primaryPurple),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          style: AppTextStyles.bold.copyWith(
                            fontSize: 13.5,
                            color: AppColors.darkText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onEdit != null) ...[
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: onEdit,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.edit_outlined, size: 13, color: AppColors.primaryPurple),
                          SizedBox(width: 4),
                          Text(
                            'Edit',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryPurple,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
              final rowContent = Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Icon(item.icon, size: 16, color: AppColors.primaryPurple),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 4,
                      child: Text(
                        item.label,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 6,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
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
                          if (item.onEdit != null) ...[
                            const SizedBox(width: 6),
                            Icon(Icons.edit_outlined, size: 13, color: AppColors.primaryPurple.withValues(alpha: 0.7)),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );

              if (item.onEdit != null) {
                return InkWell(
                  onTap: item.onEdit,
                  borderRadius: BorderRadius.circular(8),
                  child: rowContent,
                );
              }
              return rowContent;
            },
          ),
        ],
      ),
    );
  }

  void _showEditSellerProfileDialog({
    required BuildContext context,
    required SellerDashboardController controller,
    required String currentFullName,
    required String currentPhone,
    required VoidCallback onUpdated,
  }) {
    final fullNameCtrl = TextEditingController(text: currentFullName);
    final phoneCtrl = TextEditingController(text: currentPhone);
    final currentPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();

    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    bool changePasswordExpanded = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle Bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4.5,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.badge_outlined,
                            color: AppColors.primaryPurple,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Update Seller Profile',
                                style: AppTextStyles.bold.copyWith(fontSize: 16),
                              ),
                              Text(
                                'Update your personal name, phone and password',
                                style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          icon: const Icon(Icons.close_rounded, size: 20),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Full Name Field
                    Text(
                      'Full Name *',
                      style: AppTextStyles.bold.copyWith(fontSize: 12.5, color: AppColors.darkText),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: fullNameCtrl,
                      decoration: InputDecoration(
                        hintText: 'Enter your full name',
                        hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                        prefixIcon: const Icon(Icons.person_outline_rounded, size: 19, color: AppColors.primaryPurple),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primaryPurple, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Phone Number Field
                    Text(
                      'Phone Number *',
                      style: AppTextStyles.bold.copyWith(fontSize: 12.5, color: AppColors.darkText),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: 'e.g. 03185915209',
                        hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                        prefixIcon: const Icon(Icons.phone_outlined, size: 19, color: AppColors.primaryPurple),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primaryPurple, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Change Password Expandable Card
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: changePasswordExpanded
                              ? AppColors.primaryPurple.withValues(alpha: 0.35)
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              setDialogState(() {
                                changePasswordExpanded = !changePasswordExpanded;
                              });
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.lock_reset_rounded,
                                    size: 20,
                                    color: changePasswordExpanded ? AppColors.primaryPurple : Colors.grey.shade700,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Change Password',
                                          style: AppTextStyles.bold.copyWith(
                                            fontSize: 13,
                                            color: changePasswordExpanded ? AppColors.primaryPurple : AppColors.darkText,
                                          ),
                                        ),
                                        Text(
                                          'Update password along with profile',
                                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    changePasswordExpanded
                                        ? Icons.keyboard_arrow_up_rounded
                                        : Icons.keyboard_arrow_down_rounded,
                                    color: Colors.grey.shade600,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (changePasswordExpanded) ...[
                            const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Current Password
                                  Text(
                                    'Current Password *',
                                    style: AppTextStyles.bold.copyWith(fontSize: 12, color: AppColors.darkText),
                                  ),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: currentPassCtrl,
                                    obscureText: obscureCurrent,
                                    decoration: InputDecoration(
                                      hintText: 'Enter current password',
                                      prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          obscureCurrent ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                          size: 18,
                                        ),
                                        onPressed: () => setDialogState(() => obscureCurrent = !obscureCurrent),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  // New Password
                                  Text(
                                    'New Password *',
                                    style: AppTextStyles.bold.copyWith(fontSize: 12, color: AppColors.darkText),
                                  ),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: newPassCtrl,
                                    obscureText: obscureNew,
                                    decoration: InputDecoration(
                                      hintText: 'Enter new password',
                                      prefixIcon: const Icon(Icons.vpn_key_outlined, size: 18),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                          size: 18,
                                        ),
                                        onPressed: () => setDialogState(() => obscureNew = !obscureNew),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  // Confirm Password
                                  Text(
                                    'Confirm New Password *',
                                    style: AppTextStyles.bold.copyWith(fontSize: 12, color: AppColors.darkText),
                                  ),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: confirmPassCtrl,
                                    obscureText: obscureConfirm,
                                    decoration: InputDecoration(
                                      hintText: 'Re-enter new password',
                                      prefixIcon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                          size: 18,
                                        ),
                                        onPressed: () => setDialogState(() => obscureConfirm = !obscureConfirm),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Action Buttons (Cancel / Save)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            child: const Text('Cancel', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final name = fullNameCtrl.text.trim();
                              final phone = phoneCtrl.text.trim();

                              if (name.isEmpty) {
                                CustomPopup.showToast('Validation Error', 'Please enter your full name', isError: true);
                                return;
                              }
                              if (phone.isEmpty) {
                                CustomPopup.showToast('Validation Error', 'Please enter your phone number', isError: true);
                                return;
                              }

                              String? curPass;
                              String? newPass;
                              String? confPass;

                              if (changePasswordExpanded || currentPassCtrl.text.isNotEmpty || newPassCtrl.text.isNotEmpty) {
                                curPass = currentPassCtrl.text.trim();
                                newPass = newPassCtrl.text.trim();
                                confPass = confirmPassCtrl.text.trim();

                                if (curPass.isEmpty) {
                                  CustomPopup.showToast('Validation Error', 'Please enter current password', isError: true);
                                  return;
                                }
                                if (newPass.isEmpty) {
                                  CustomPopup.showToast('Validation Error', 'Please enter new password', isError: true);
                                  return;
                                }
                                if (confPass.isEmpty) {
                                  CustomPopup.showToast('Validation Error', 'Please confirm your new password', isError: true);
                                  return;
                                }
                                if (newPass != confPass) {
                                  CustomPopup.showToast('Validation Error', 'New passwords do not match', isError: true);
                                  return;
                                }
                                if (newPass.length < 6) {
                                  CustomPopup.showToast('Validation Error', 'New password must be at least 6 characters', isError: true);
                                  return;
                                }
                              }

                              final success = await controller.updateSellerAccountProfile(
                                fullName: name,
                                phoneNumber: phone,
                                currentPassword: curPass,
                                newPassword: newPass,
                                confirmPassword: confPass,
                              );

                              if (success && ctx.mounted) {
                                Navigator.of(ctx).pop();
                                onUpdated();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryPurple,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text(
                              'Save Changes',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showEditStoreProfileDialog({
    required BuildContext context,
    required SellerDashboardController controller,
    required String currentStoreName,
    required String currentTagline,
    required String currentDescription,
    required VoidCallback onUpdated,
  }) {
    _showEditStoreBottomSheet(
      context: context,
      controller: controller,
      initialTab: 0,
      onUpdated: onUpdated,
    );
  }

  void _showEditContactLocationDialog({
    required BuildContext context,
    required SellerDashboardController controller,
    required String currentEmail,
    required String currentWhatsapp,
    required String currentCity,
    required String currentWarehouse,
    required VoidCallback onUpdated,
  }) {
    _showEditStoreBottomSheet(
      context: context,
      controller: controller,
      initialTab: 1,
      onUpdated: onUpdated,
    );
  }

  void _showEditPoliciesDialog({
    required BuildContext context,
    required SellerDashboardController controller,
    required String currentShippingMethod,
    required String currentDeliveryZones,
    required String currentShippingCharges,
    required String currentReturnPolicy,
    required String currentWarranty,
    required String currentProcessingTime,
    required String currentCancellationPolicy,
    required VoidCallback onUpdated,
  }) {
    _showEditStoreBottomSheet(
      context: context,
      controller: controller,
      initialTab: 2,
      onUpdated: onUpdated,
    );
  }

  void _showEditStoreBottomSheet({
    required BuildContext context,
    required SellerDashboardController controller,
    int initialTab = 0,
    required VoidCallback onUpdated,
  }) {
    final rawStore = SessionManager.getSellerStoreDetailsMap() ?? {};
    String g(String k1, [String? k2, String? k3]) {
      final v = rawStore[k1] ?? (k2 != null ? rawStore[k2] : null) ?? (k3 != null ? rawStore[k3] : null);
      return v?.toString().trim() ?? '';
    }

    final nameCtrl = TextEditingController(
      text: controller.storeName.value.isNotEmpty
          ? controller.storeName.value
          : (g('storeName', 'StoreName', 'name').isNotEmpty ? g('storeName', 'StoreName', 'name') : (SessionManager.sellerStoreName ?? '')),
    );
    final taglineCtrl = TextEditingController(text: g('storeTagline', 'Storetagline', 'tagline'));
    final descCtrl = TextEditingController(text: g('description', 'StoreDescription'));

    final emailCtrl = TextEditingController(text: g('storeContactEmail', 'StoreContactEmail', 'email'));
    final whatsappCtrl = TextEditingController(text: g('storeWhatsapp', 'StoreWhatsapp', 'whatsapp'));
    final cityCtrl = TextEditingController(text: g('primaryCity', 'PrimaryCity', 'city'));
    final warehouseCtrl = TextEditingController(text: g('warehouseAddress', 'WarehouseAddress'));

    final shippingMethodCtrl = TextEditingController(text: g('shippingMethod', 'ShippingMethod'));
    final deliveryZonesCtrl = TextEditingController(text: g('deliveryZones', 'DeliveryZones'));
    final shippingChargesCtrl = TextEditingController(text: g('shippingCharges', 'ShippingCharges'));
    final processingTimeCtrl = TextEditingController(text: g('processingTime', 'ProcessingTime'));
    final returnPolicyCtrl = TextEditingController(text: g('returnPolicy', 'ReturnPolicy'));
    final warrantyCtrl = TextEditingController(text: g('warranty', 'Warrenty'));
    final cancellationPolicyCtrl = TextEditingController(text: g('cancellationPolicy', 'CancellationPolicy'));

    final formKey = GlobalKey<FormState>();
    int selectedTab = initialTab;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.90,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 42,
                    height: 4.5,
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                // Sheet Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 16, 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryPurple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.mode_edit_outline_rounded, color: AppColors.primaryPurple, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Edit Store Details',
                              style: AppTextStyles.bold.copyWith(fontSize: 17, color: AppColors.darkText),
                            ),
                            Text(
                              'Update your public profile, contact & operational policies',
                              style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded, size: 18, color: Colors.black87),
                        ),
                        onPressed: () => Navigator.of(sheetCtx).pop(),
                      ),
                    ],
                  ),
                ),
                // Modern Segmented Tab Pills
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      _buildEditTabPill(
                        label: 'Store Profile',
                        icon: Icons.storefront_rounded,
                        isSelected: selectedTab == 0,
                        onTap: () => setModalState(() => selectedTab = 0),
                      ),
                      _buildEditTabPill(
                        label: 'Contact & City',
                        icon: Icons.contact_mail_outlined,
                        isSelected: selectedTab == 1,
                        onTap: () => setModalState(() => selectedTab = 1),
                      ),
                      _buildEditTabPill(
                        label: 'Policies',
                        icon: Icons.local_shipping_outlined,
                        isSelected: selectedTab == 2,
                        onTap: () => setModalState(() => selectedTab = 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

                // Form Scrollable Body
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 16),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (selectedTab == 0) ...[
                            _buildModernFormField(
                              label: 'Store Name *',
                              hint: 'Enter your brand / store name',
                              icon: Icons.business_rounded,
                              controller: nameCtrl,
                              validator: (val) => val == null || val.trim().isEmpty ? 'Store name is required' : null,
                            ),
                            const SizedBox(height: 14),
                            _buildModernFormField(
                              label: 'Store Tagline',
                              hint: 'e.g. Quality Goods for Every Home',
                              icon: Icons.short_text_rounded,
                              controller: taglineCtrl,
                            ),
                            const SizedBox(height: 14),
                            _buildModernFormField(
                              label: 'Store Description',
                              hint: 'Describe your store, specialty, and services for buyers...',
                              icon: Icons.notes_rounded,
                              controller: descCtrl,
                              maxLines: 4,
                            ),
                          ] else if (selectedTab == 1) ...[
                            _buildModernFormField(
                              label: 'Contact Email *',
                              hint: 'store@example.com',
                              icon: Icons.email_outlined,
                              controller: emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'Email is required';
                                if (!val.contains('@')) return 'Enter a valid email address';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            _buildModernFormField(
                              label: 'WhatsApp Number',
                              hint: '03XXXXXXXXX',
                              icon: Icons.chat_bubble_outline_rounded,
                              controller: whatsappCtrl,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 14),
                            _buildModernFormField(
                              label: 'Primary City',
                              hint: 'e.g. Lahore, Karachi, Islamabad',
                              icon: Icons.location_city_rounded,
                              controller: cityCtrl,
                            ),
                            const SizedBox(height: 14),
                            _buildModernFormField(
                              label: 'Warehouse Address',
                              hint: 'Complete street, building, area address...',
                              icon: Icons.warehouse_outlined,
                              controller: warehouseCtrl,
                              maxLines: 2,
                            ),
                          ] else ...[
                            _buildModernFormField(
                              label: 'Shipping Method',
                              hint: 'e.g. Standard Courier / Express',
                              icon: Icons.local_shipping_outlined,
                              controller: shippingMethodCtrl,
                            ),
                            const SizedBox(height: 14),
                            _buildModernFormField(
                              label: 'Delivery Coverage / Zones',
                              hint: 'e.g. All over Pakistan',
                              icon: Icons.map_outlined,
                              controller: deliveryZonesCtrl,
                            ),
                            const SizedBox(height: 14),
                            _buildModernFormField(
                              label: 'Delivery Charges (Rs.)',
                              hint: 'e.g. 200',
                              icon: Icons.payments_outlined,
                              controller: shippingChargesCtrl,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 14),
                            _buildModernFormField(
                              label: 'Processing Time',
                              hint: 'e.g. 1-2 working days',
                              icon: Icons.schedule_rounded,
                              controller: processingTimeCtrl,
                            ),
                            const SizedBox(height: 14),
                            _buildModernFormField(
                              label: 'Return Policy',
                              hint: 'e.g. 7 days return & refund',
                              icon: Icons.assignment_return_outlined,
                              controller: returnPolicyCtrl,
                            ),
                            const SizedBox(height: 14),
                            _buildModernFormField(
                              label: 'Warranty Policy',
                              hint: 'e.g. 6 months official warranty',
                              icon: Icons.verified_user_outlined,
                              controller: warrantyCtrl,
                            ),
                            const SizedBox(height: 14),
                            _buildModernFormField(
                              label: 'Cancellation Policy',
                              hint: 'e.g. Within 24 hours of order',
                              icon: Icons.highlight_off_rounded,
                              controller: cancellationPolicyCtrl,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom Action Bar
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: OutlinedButton(
                          onPressed: isSaving ? null : () => Navigator.of(sheetCtx).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 5,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primaryPurple, AppColors.secondaryViolet],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryPurple.withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: isSaving
                                ? null
                                : () async {
                                    if (formKey.currentState?.validate() ?? false) {
                                      setModalState(() => isSaving = true);
                                      final payload = <String, dynamic>{
                                        'StoreName': nameCtrl.text.trim(),
                                        'storeName': nameCtrl.text.trim(),
                                        'Storetagline': taglineCtrl.text.trim(),
                                        'storeTagline': taglineCtrl.text.trim(),
                                        'tagline': taglineCtrl.text.trim(),
                                        'description': descCtrl.text.trim(),
                                        'StoreContactEmail': emailCtrl.text.trim(),
                                        'storeContactEmail': emailCtrl.text.trim(),
                                        'email': emailCtrl.text.trim(),
                                        'StoreWhatsapp': whatsappCtrl.text.trim(),
                                        'storeWhatsapp': whatsappCtrl.text.trim(),
                                        'whatsapp': whatsappCtrl.text.trim(),
                                        'PrimaryCity': cityCtrl.text.trim(),
                                        'primaryCity': cityCtrl.text.trim(),
                                        'city': cityCtrl.text.trim(),
                                        'WarehouseAddress': warehouseCtrl.text.trim(),
                                        'warehouseAddress': warehouseCtrl.text.trim(),
                                        'ShippingMethod': shippingMethodCtrl.text.trim(),
                                        'shippingMethod': shippingMethodCtrl.text.trim(),
                                        'DeliveryZones': deliveryZonesCtrl.text.trim(),
                                        'deliveryZones': deliveryZonesCtrl.text.trim(),
                                        'ShippingCharges': shippingChargesCtrl.text.trim(),
                                        'shippingCharges': shippingChargesCtrl.text.trim(),
                                        'ReturnPolicy': returnPolicyCtrl.text.trim(),
                                        'returnPolicy': returnPolicyCtrl.text.trim(),
                                        'Warrenty': warrantyCtrl.text.trim(),
                                        'warranty': warrantyCtrl.text.trim(),
                                        'ProcessingTime': processingTimeCtrl.text.trim(),
                                        'processingTime': processingTimeCtrl.text.trim(),
                                        'CancellationPolicy': cancellationPolicyCtrl.text.trim(),
                                        'cancellationPolicy': cancellationPolicyCtrl.text.trim(),
                                      };
                                      final success = await controller.updateStoreDetails(payload);
                                      if (sheetCtx.mounted) {
                                        setModalState(() => isSaving = false);
                                      }
                                      if (success) {
                                        if (sheetCtx.mounted) {
                                          Navigator.of(sheetCtx).pop();
                                        }
                                        onUpdated();
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: isSaving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text(
                                    'Save Changes',
                                    style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEditTabPill({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? AppColors.primaryPurple : const Color(0xFF64748B),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.primaryPurple : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernFormField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontSize: 13.5, color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
            prefixIcon: maxLines == 1 ? Icon(icon, size: 18, color: const Color(0xFF64748B)) : null,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
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
            final delivered = controller.stats.value.deliveredOrders > 0
                ? controller.stats.value.deliveredOrders
                : controller.deliveredOrders.length;
            final cancelled = controller.stats.value.cancelledOrders;
            final returned = controller.stats.value.returnedOrders > 0
                ? controller.stats.value.returnedOrders
                : controller.refundedOrders.length;
            final sum = active + delivered + cancelled + returned;
            final total = sum > 0
                ? sum
                : (controller.stats.value.totalOrders > 0
                    ? controller.stats.value.totalOrders
                    : (controller.deliveredOrders.length + controller.refundedOrders.length));

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
          Obx(() {
            final active = controller.stats.value.activeOrders;
            final delivered = controller.stats.value.deliveredOrders > 0
                ? controller.stats.value.deliveredOrders
                : controller.deliveredOrders.length;
            final cancelled = controller.stats.value.cancelledOrders;
            final returned = controller.stats.value.returnedOrders > 0
                ? controller.stats.value.returnedOrders
                : controller.refundedOrders.length;

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatusLegendChip(
                        label: 'Active',
                        count: active,
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
                        count: delivered,
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
                        count: cancelled,
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
                        count: returned,
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
            );
          }),
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

          Obx(() {

            final double paid = controller.paidAmount.value;

            final double unpaid = controller.unpaidAmount.value;

            final double maxVal = paid > unpaid ? paid : unpaid;



            final double paidHeight;

            final double unpaidHeight;



            if (maxVal > 0) {

              paidHeight = (paid / maxVal) * 98.0 + 8.0;

              unpaidHeight = (unpaid / maxVal) * 98.0 + 8.0;

            } else {

              paidHeight = 8.0;

              unpaidHeight = 8.0;

            }



            return Row(

              mainAxisAlignment: MainAxisAlignment.spaceEvenly,

              children: [

                _buildPayoutBarColumn(

                  label: 'Paid',

                  amount: paid,

                  bottomColor: const Color(0xFFF59E0B),

                  fillHeight: paidHeight,

                ),

                _buildPayoutBarColumn(

                  label: 'Unpaid',

                  amount: unpaid,

                  bottomColor: const Color(0xFF0F172A),

                  fillHeight: unpaidHeight,

                ),

              ],

            );

          }),

        ],

      ),

    );

  }



  Widget _buildPayoutBarColumn({

    required String label,

    required double amount,

    required Color bottomColor,

    required double fillHeight,

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

          child: AnimatedContainer(

            duration: const Duration(milliseconds: 500),

            curve: Curves.easeOutCubic,

            width: double.infinity,

            height: fillHeight,

            decoration: BoxDecoration(

              color: bottomColor,

              borderRadius: BorderRadius.vertical(

                bottom: const Radius.circular(9),

                top: Radius.circular(fillHeight >= 110 ? 9 : 4),

              ),

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
  final VoidCallback? onEdit;

  const _CardInfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.highlightValue = false,
    this.onEdit,
  });
}
