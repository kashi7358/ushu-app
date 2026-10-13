import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/routes/app_routes.dart';
import '../../data/models/seller_promotion_model.dart';
import '../controllers/seller_promotions_controller.dart';

class SellerPromotionsScreen extends StatelessWidget {
  const SellerPromotionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SellerPromotionsController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.darkText, size: 20),
          onPressed: () => Get.back(),
        ),
        titleSpacing: 0,
        title: Obx(() => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                'Promotion Campaigns',
                style: AppTextStyles.bold.copyWith(color: AppColors.darkText, fontSize: 17),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!controller.isLoading.value) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${controller.allCount}',
                  style: const TextStyle(
                    color: AppColors.primaryPurple,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        )),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.darkText, size: 21),
            onPressed: controller.fetchPromotions,
            tooltip: 'Refresh Promotions',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              onTap: () => Get.toNamed('/seller/create-banner'),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.panorama_outlined, size: 15, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Banner',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: controller.navigateToCreateFlashSale,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.add_rounded, size: 16, color: Colors.white),
                    SizedBox(width: 2),
                    Text(
                      'Flash Sale',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: TextField(
              controller: controller.searchController,
              onChanged: controller.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search promotions, campaigns, or codes...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13.5),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryPurple, size: 21),
                suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18, color: Colors.grey),
                        onPressed: () {
                          controller.searchController.clear();
                          controller.onSearchChanged('');
                        },
                      )
                    : const SizedBox.shrink()),
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Status Filter Tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Obx(() {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterTab(
                      label: 'All',
                      count: controller.allCount,
                      isSelected: controller.selectedTab.value == 'All',
                      onTap: () => controller.onTabChanged('All'),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterTab(
                      label: 'Active',
                      count: controller.activeCount,
                      isSelected: controller.selectedTab.value == 'Active',
                      activeColor: Colors.green.shade600,
                      onTap: () => controller.onTabChanged('Active'),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterTab(
                      label: 'Upcoming',
                      count: controller.upcomingCount,
                      isSelected: controller.selectedTab.value == 'Upcoming',
                      activeColor: Colors.amber.shade700,
                      onTap: () => controller.onTabChanged('Upcoming'),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterTab(
                      label: 'Expired',
                      count: controller.expiredCount,
                      isSelected: controller.selectedTab.value == 'Expired',
                      activeColor: Colors.red.shade600,
                      onTap: () => controller.onTabChanged('Expired'),
                    ),
                  ],
                ),
              );
            }),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

          // Quick Flash Sale Shortcut Banner
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryPurple.withValues(alpha: 0.08),
                  AppColors.secondaryViolet.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.18)),
            ),
            child: Row(
              children: [
                Icon(Icons.bolt_rounded, color: Colors.amber.shade700, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Manage your store Flash Sale deals & discounts',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: controller.navigateToManageFlashSales,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'View Flash Sales →',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryPurple,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main List Content
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return _buildShimmer();
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 54, color: Colors.red),
                        const SizedBox(height: 14),
                        Text(
                          controller.errorMessage.value,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14, color: AppColors.darkText),
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton.icon(
                          onPressed: controller.fetchPromotions,
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Try Again'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (controller.allPromotions.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.campaign_rounded,
                            size: 60,
                            color: AppColors.primaryPurple,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'No Promotions Found',
                          style: AppTextStyles.bold.copyWith(fontSize: 18, color: AppColors.darkText),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Create promotional campaigns or flash sales to attract more buyers to your store.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13.5, color: AppColors.hintText),
                        ),
                        const SizedBox(height: 22),
                        ElevatedButton.icon(
                          onPressed: controller.navigateToCreateFlashSale,
                          icon: const Icon(Icons.bolt_rounded, size: 20),
                          label: const Text('Create Flash Sale Campaign'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (controller.filteredPromotions.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.filter_list_off_rounded, size: 52, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text(
                          'No matching promotions',
                          style: AppTextStyles.bold.copyWith(fontSize: 16, color: AppColors.darkText),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                color: AppColors.primaryPurple,
                onRefresh: controller.fetchPromotions,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  itemCount: controller.filteredPromotions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final promo = controller.filteredPromotions[index];
                    return _buildPromotionCard(promo);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionCard(SellerPromotionModel promo) {
    Color statusBg;
    Color statusFg;
    String statusText;

    if (promo.isUpcoming) {
      statusBg = Colors.amber.shade50;
      statusFg = Colors.amber.shade800;
      statusText = 'Upcoming';
    } else if (promo.isExpired) {
      statusBg = Colors.red.shade50;
      statusFg = Colors.red.shade700;
      statusText = 'Expired';
    } else {
      statusBg = Colors.green.shade50;
      statusFg = Colors.green.shade700;
      statusText = 'Active';
    }

    final controller = Get.find<SellerPromotionsController>();

    String formatDate(DateTime? dt) {
      if (dt == null) return 'N/A';
      return '${dt.day}/${dt.month}/${dt.year}';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (promo.bannerImage.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                promo.bannerImage,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                cacheWidth: 600,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(
                        Icons.campaign_rounded,
                        color: AppColors.primaryPurple,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            promo.title,
                            style: AppTextStyles.extraBold.copyWith(
                              fontSize: 15,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          if (promo.description.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              promo.description,
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusFg,
                        ),
                      ),
                    ),
                    if (promo.bannerImage.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () {
                          Get.toNamed(
                            AppRoutes.sellerCreateBanner,
                            arguments: {
                              'isEdit': true,
                              'bannerId': promo.id,
                              'title': promo.title,
                              'description': promo.description,
                              'image': promo.bannerImage,
                              'startDate': promo.startTime,
                              'endDate': promo.endTime,
                            },
                          )?.then((updated) {
                            if (updated == true) {
                              controller.fetchPromotions();
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF0F172A)),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),

                // Tags Row (Discount, Code, Products count, Min Spend)
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        promo.badgeLabel,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                    ),
                    if (promo.code.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Code: ${promo.code}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                    if (promo.productsCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${promo.productsCount} Products',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                    if (promo.minOrderAmount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Min. Rs. ${promo.minOrderAmount.toInt()}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                  ],
                ),

                if (promo.startTime != null || promo.endTime != null) ...[
                  const SizedBox(height: 10),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 13.5, color: Color(0xFF64748B)),
                      const SizedBox(width: 6),
                      Text(
                        '${formatDate(promo.startTime)}  →  ${formatDate(promo.endTime)}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      if (promo.usageLimit > 0) ...[
                        const Spacer(),
                        Text(
                          'Used: ${promo.usedCount}/${promo.usageLimit}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab({
    required String label,
    required int count,
    required bool isSelected,
    Color? activeColor,
    required VoidCallback onTap,
  }) {
    final themeColor = activeColor ?? AppColors.primaryPurple;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? themeColor : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.25) : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF8FAFC),
      period: const Duration(milliseconds: 1400),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (_, __) => Container(
          height: 135,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
