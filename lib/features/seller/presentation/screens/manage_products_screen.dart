import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/models/seller_product_model.dart';
import '../controllers/manage_products_controller.dart';

class ManageProductsScreen extends StatelessWidget {
  const ManageProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ManageProductsController());

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
                'Manage Products',
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
                  '${controller.products.length}',
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
            onPressed: controller.fetchProducts,
            tooltip: 'Refresh',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: controller.navigateToAddProduct,
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
                    Icon(Icons.add_rounded, size: 16, color: Colors.white),
                    SizedBox(width: 2),
                    Text(
                      'Add',
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
          // Search & Filter Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: TextField(
              controller: controller.searchController,
              onChanged: controller.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search products by name, SKU, or category...',
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

          // Status Filter Tabs (All, Active, Inactive, Draft)
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
                      label: 'Inactive',
                      count: controller.inactiveCount,
                      isSelected: controller.selectedTab.value == 'Inactive',
                      activeColor: Colors.red.shade600,
                      onTap: () => controller.onTabChanged('Inactive'),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterTab(
                      label: 'Draft',
                      count: controller.draftCount,
                      isSelected: controller.selectedTab.value == 'Draft',
                      activeColor: Colors.amber.shade700,
                      onTap: () => controller.onTabChanged('Draft'),
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
                return _buildProductsShimmer();
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
                          onPressed: controller.fetchProducts,
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

              if (controller.products.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.primaryPurple),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'No Products Yet',
                          style: AppTextStyles.bold.copyWith(fontSize: 18, color: AppColors.darkText),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your store has no products yet. Start adding items to begin selling!',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.medium.copyWith(fontSize: 13, color: AppColors.hintText),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: controller.navigateToAddProduct,
                          icon: const Icon(Icons.add_rounded, size: 20),
                          label: const Text('Add Your First Product'),
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

              if (controller.filteredProducts.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off_rounded, size: 54, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text(
                          'No matching products',
                          style: AppTextStyles.bold.copyWith(fontSize: 16, color: AppColors.darkText),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'No products found matching "${controller.searchQuery.value}"',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13, color: AppColors.hintText),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                color: AppColors.primaryPurple,
                onRefresh: controller.fetchProducts,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  itemCount: controller.filteredProducts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final product = controller.filteredProducts[index];
                    return _buildProductCard(context, product, controller);
                  },
                ),
              );
            }),
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
          border: Border.all(
            color: isSelected ? themeColor : Colors.transparent,
            width: 1,
          ),
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

  Widget _buildProductCard(
    BuildContext context,
    SellerProductModel product,
    ManageProductsController controller,
  ) {
    return Container(
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
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image with status overlay badge
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 88,
                        height: 88,
                        color: const Color(0xFFF8FAFC),
                        child: product.primaryImage.isNotEmpty
                            ? Image.network(
                                product.primaryImage,
                                fit: BoxFit.cover,
                                cacheWidth: 220,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Colors.grey,
                                  size: 32,
                                ),
                                loadingBuilder: (_, child, progress) {
                                  if (progress == null) return child;
                                  return const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryPurple),
                                    ),
                                  );
                                },
                              )
                            : const Icon(Icons.inventory_2_outlined, color: Colors.grey, size: 36),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      left: 4,
                      child: _buildStatusPill(product),
                    ),
                  ],
                ),
                const SizedBox(width: 14),

                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        product.name,
                        style: AppTextStyles.bold.copyWith(fontSize: 14.5, color: AppColors.darkText),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      // Category & Condition
                      Row(
                        children: [
                          if (product.category.isNotEmpty) ...[
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  product.category,
                                  style: const TextStyle(fontSize: 10.5, color: Color(0xFF475569), fontWeight: FontWeight.w600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          if (product.sku.isNotEmpty)
                            Flexible(
                              child: Text(
                                'SKU: ${product.sku}',
                                style: const TextStyle(fontSize: 10.5, color: AppColors.hintText),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Price and Stock status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${product.priceCurrency} ${product.price.toStringAsFixed(product.price.truncateToDouble() == product.price ? 0 : 2)}',
                              style: AppTextStyles.extraBold.copyWith(fontSize: 15, color: AppColors.primaryPurple),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildStockBadge(product),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
          // Card Action Buttons Footer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Edit Button
                InkWell(
                  onTap: () => controller.navigateToEditProduct(product),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.edit_outlined, color: AppColors.primaryPurple, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Edit',
                          style: TextStyle(
                            color: AppColors.primaryPurple,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Delete Button
                InkWell(
                  onTap: () => controller.confirmDeleteProduct(product),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.delete_outline_rounded, color: Colors.red, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                          ),
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
    );
  }

  Widget _buildStatusPill(SellerProductModel product) {
    Color bg;
    Color fg;
    String text;

    if (product.isDraft) {
      bg = Colors.amber.shade600;
      fg = Colors.white;
      text = 'Draft';
    } else if (product.isActive) {
      bg = Colors.green.shade600;
      fg = Colors.white;
      text = 'Active';
    } else {
      bg = Colors.red.shade600;
      fg = Colors.white;
      text = 'Inactive';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(color: fg, fontSize: 9.5, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStockBadge(SellerProductModel product) {
    Color bgColor;
    Color textColor;
    String label;

    if (product.stock <= 0) {
      bgColor = Colors.red.shade50;
      textColor = Colors.red.shade700;
      label = 'Out of Stock';
    } else if (product.lowStockThreshold > 0 && product.stock <= product.lowStockThreshold) {
      bgColor = Colors.amber.shade50;
      textColor = Colors.amber.shade800;
      label = 'Low: ${product.stock} left';
    } else {
      bgColor = Colors.green.shade50;
      textColor = Colors.green.shade700;
      label = 'Stock: ${product.stock}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor),
      ),
    );
  }

  Widget _buildProductsShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF8FAFC),
      period: const Duration(milliseconds: 1400),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
