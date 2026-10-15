import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/models/seller_banner_model.dart';
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
                'Promotions & Banners',
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
            tooltip: 'Refresh',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: controller.navigateToCreateBanner,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
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
                hintText: 'Search promotions, banners, or campaigns...',
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

          // Status Filter Tabs (Matching Web Dashboard: All, Promotions, My Banners)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Obx(() {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
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
                      label: 'Promotions',
                      count: controller.promotionsCount,
                      isSelected: controller.selectedTab.value == 'Promotions',
                      activeColor: const Color(0xFF0F172A),
                      onTap: () => controller.onTabChanged('Promotions'),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterTab(
                      label: 'My Banners',
                      count: controller.bannersCount,
                      isSelected: controller.selectedTab.value == 'My Banners',
                      activeColor: const Color(0xFF6366F1),
                      onTap: () => controller.onTabChanged('My Banners'),
                    ),
                  ],
                ),
              );
            }),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 6),

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

              final hasPromos = controller.filteredPromotions.isNotEmpty;
              final hasBanners = controller.filteredBanners.isNotEmpty;

              if (!hasPromos && !hasBanners) {
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
                          'No Items Found',
                          style: AppTextStyles.bold.copyWith(fontSize: 18, color: AppColors.darkText),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Create a banner or flash sale campaign to promote your store across USHU.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13.5, color: AppColors.hintText),
                        ),
                        const SizedBox(height: 22),
                        ElevatedButton.icon(
                          onPressed: controller.navigateToCreateBanner,
                          icon: const Icon(Icons.panorama_outlined, size: 20),
                          label: const Text('Create Promotional Banner'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F172A),
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

              return RefreshIndicator(
                color: AppColors.primaryPurple,
                onRefresh: controller.fetchPromotions,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  children: [
                    // Section 1: Promotions
                    if (hasPromos) ...[
                      _buildSectionTitle(
                        title: 'Promotions',
                        count: controller.filteredPromotions.length,
                        subtitle: 'Available platform campaigns to apply for',
                      ),
                      const SizedBox(height: 10),
                      ...controller.filteredPromotions.map((p) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _buildAvailablePromotionCard(context, controller, p),
                      )),
                      const SizedBox(height: 10),
                    ],

                    // Section 2: My Banners
                    if (hasBanners) ...[
                      _buildSectionTitle(
                        title: 'My Banners',
                        count: controller.filteredBanners.length,
                        subtitle: 'Your submitted promotional banner campaigns',
                      ),
                      const SizedBox(height: 10),
                      ...controller.filteredBanners.map((b) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _buildBannerCard(context, controller, b),
                      )),
                    ],
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({
    required String title,
    required int count,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF475569),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
        ),
      ],
    );
  }

  /// Card matching Web: Title, Price, Description, [Apply for Promotion] button
  Widget _buildAvailablePromotionCard(
    BuildContext context,
    SellerPromotionsController controller,
    SellerPromotionModel promo,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TITLE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF94A3B8),
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      promo.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PRICE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF94A3B8),
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${promo.price.toInt()}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => controller.applyForPromotion(promo),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Apply for Promotion',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          if (promo.description.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DESCRIPTION:  ',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF94A3B8),
                    letterSpacing: 0.5,
                  ),
                ),
                Expanded(
                  child: Text(
                    promo.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Card matching Web: Wide Banner Image (1920:800), Pencil edit button, Title, PENDING badge, Description, Dates
  Widget _buildBannerCard(
    BuildContext context,
    SellerPromotionsController controller,
    SellerBannerModel banner,
  ) {
    Color statusBg;
    Color statusFg;
    String statusText;

    if (banner.isPending) {
      statusBg = const Color(0xFFFEF3C7);
      statusFg = const Color(0xFFB45309);
      statusText = 'PENDING';
    } else if (banner.isActive) {
      statusBg = const Color(0xFFDCFCE7);
      statusFg = const Color(0xFF15803D);
      statusText = 'ACTIVE';
    } else if (banner.isRejected) {
      statusBg = const Color(0xFFFEE2E2);
      statusFg = const Color(0xFFB91C1C);
      statusText = 'REJECTED';
    } else {
      statusBg = const Color(0xFFF1F5F9);
      statusFg = const Color(0xFF475569);
      statusText = banner.status.toUpperCase();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
          // Banner Image with Edit Button on top right
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1920 / 800,
                  child: banner.bannerImage.isNotEmpty
                      ? Image.network(
                          banner.bannerImage,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFFF1F5F9),
                            child: const Center(
                              child: Icon(Icons.broken_image_rounded, size: 36, color: Color(0xFF94A3B8)),
                            ),
                          ),
                        )
                      : Container(
                          color: const Color(0xFFF1F5F9),
                          child: const Center(
                            child: Icon(Icons.panorama_outlined, size: 40, color: Color(0xFF94A3B8)),
                          ),
                        ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: Colors.white.withValues(alpha: 0.92),
                    shape: const CircleBorder(),
                    elevation: 2,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => controller.editBanner(banner),
                      child: const Padding(
                        padding: EdgeInsets.all(7),
                        child: Icon(
                          Icons.edit_outlined,
                          size: 16,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        banner.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: statusFg,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
                if (banner.description.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    banner.description,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF64748B),
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.calendar_month_outlined, size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 5),
                    Text(
                      banner.dateRangeFormatted,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
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
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
