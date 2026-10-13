import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/models/flash_sale_campaign_model.dart';
import '../controllers/manage_flash_sales_controller.dart';

class ManageFlashSalesScreen extends StatelessWidget {
  const ManageFlashSalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ManageFlashSalesController());

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
                'Flash Sales & Deals',
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
            onPressed: controller.fetchFlashSales,
            tooltip: 'Refresh',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: controller.navigateToCreateFlashSale,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.bolt_rounded, size: 16, color: Colors.white),
                    SizedBox(width: 2),
                    Text(
                      'New Sale',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.5),
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
                hintText: 'Search flash sale campaigns...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13.5),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryPurple, size: 22),
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
                      label: 'Ongoing',
                      count: controller.ongoingCount,
                      isSelected: controller.selectedTab.value == 'Ongoing',
                      activeColor: Colors.green.shade600,
                      onTap: () => controller.onTabChanged('Ongoing'),
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

          // Main Content
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
                        const Icon(Icons.error_outline_rounded, size: 56, color: Colors.red),
                        const SizedBox(height: 14),
                        Text(
                          controller.errorMessage.value,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14, color: AppColors.darkText),
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton.icon(
                          onPressed: controller.fetchFlashSales,
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

              if (controller.allCampaigns.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.flash_on_rounded,
                            size: 62,
                            color: Colors.amber.shade700,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'No Flash Sales Created Yet',
                          style: AppTextStyles.bold.copyWith(fontSize: 18, color: AppColors.darkText),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Boost your store revenue by launching limited-time discount flash sales.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13.5, color: AppColors.hintText),
                        ),
                        const SizedBox(height: 22),
                        ElevatedButton.icon(
                          onPressed: controller.navigateToCreateFlashSale,
                          icon: const Icon(Icons.bolt_rounded, size: 20),
                          label: const Text('Create First Flash Sale'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (controller.filteredCampaigns.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.filter_list_off_rounded, size: 54, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text(
                          'No matching flash sales',
                          style: AppTextStyles.bold.copyWith(fontSize: 16, color: AppColors.darkText),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                color: AppColors.primaryPurple,
                onRefresh: controller.fetchFlashSales,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  itemCount: controller.filteredCampaigns.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final campaign = controller.filteredCampaigns[index];
                    return _buildCampaignCard(campaign, controller);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignCard(
    FlashSaleCampaignModel campaign,
    ManageFlashSalesController controller,
  ) {
    Color statusBg;
    Color statusFg;
    String statusLabel;

    if (campaign.isUpcoming) {
      statusBg = Colors.amber.shade50;
      statusFg = Colors.amber.shade800;
      statusLabel = 'Upcoming';
    } else if (campaign.isExpired) {
      statusBg = Colors.red.shade50;
      statusFg = Colors.red.shade700;
      statusLabel = 'Ended';
    } else {
      statusBg = Colors.green.shade50;
      statusFg = Colors.green.shade700;
      statusLabel = '● Live Now';
    }

    String formatDateTime(DateTime? dt) {
      if (dt == null) return 'N/A';
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.flash_on_rounded, color: Colors.amber.shade700, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        campaign.title,
                        style: AppTextStyles.extraBold.copyWith(fontSize: 15.5, color: AppColors.darkText),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (campaign.description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          campaign.description,
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
                    statusLabel,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusFg),
                  ),
                ),
                const SizedBox(width: 6),
                Material(
                  color: AppColors.primaryPurple.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () => controller.navigateToEditFlashSale(campaign),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.primaryPurple.withValues(alpha: 0.22),
                        ),
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        size: 17,
                        color: AppColors.primaryPurple,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Material(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () => controller.confirmDeleteFlashSale(campaign),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        size: 17,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Schedule Row
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule_rounded, size: 15, color: AppColors.primaryPurple),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${formatDateTime(campaign.startTime)}  →  ${formatDateTime(campaign.endTime)}',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Products List inside Campaign
          if (campaign.products.isNotEmpty) ...[
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'INCLUDED PRODUCTS (${campaign.products.length})',
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...campaign.products.map((prod) {
                    final matchedStoreProduct = controller.storeProductsMap[prod.productId];
                    final displayName = prod.productName.isNotEmpty
                        ? prod.productName
                        : (matchedStoreProduct?.name ?? 'Product #${prod.productId.length > 6 ? prod.productId.substring(prod.productId.length - 6) : prod.productId}');
                    final displayImg = prod.productImage.isNotEmpty
                        ? prod.productImage
                        : (matchedStoreProduct?.primaryImage ?? '');

                    final discountTag = prod.discountType.toLowerCase() == 'percentage'
                        ? '-${prod.discountValue}% OFF'
                        : '-Rs. ${prod.discountValue} OFF';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 42,
                              height: 42,
                              color: Colors.white,
                              child: displayImg.isNotEmpty
                                  ? Image.network(
                                      displayImg,
                                      fit: BoxFit.cover,
                                      cacheWidth: 120,
                                      errorBuilder: (_, __, ___) => const Icon(Icons.inventory_2_outlined, size: 18, color: Colors.grey),
                                    )
                                  : const Icon(Icons.inventory_2_outlined, size: 18, color: Colors.grey),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Text(
                                      'Stock Limit: ${prod.stockLimit}',
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Max/User: ${prod.maxPerUser}',
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                    ),
                                    if (prod.isFreeShipping) ...[
                                      const SizedBox(width: 8),
                                      const Text(
                                        '• Free Ship',
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryPurple.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              discountTag,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryPurple,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
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
          height: 160,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}
