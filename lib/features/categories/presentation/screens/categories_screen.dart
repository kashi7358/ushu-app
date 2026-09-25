import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/custom_popup.dart';
import '../../../../core/utils/session_manager.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../../home/presentation/widgets/product_card.dart';
import '../controllers/categories_controller.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  void _showCategoryPickerSheet(BuildContext context, CategoriesController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              
              // Header title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'All Categories',
                      style: AppTextStyles.bold.copyWith(fontSize: 18, color: AppColors.darkText),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.darkText),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Categories Grid inside Bottom Sheet
              Expanded(
                child: Obx(() {
                  final cats = controller.filteredCategories;
                  if (cats.isEmpty) {
                    return Center(
                      child: Text('No Categories Found', style: AppTextStyles.medium.copyWith(color: AppColors.hintText)),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.82,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: cats.length,
                    itemBuilder: (context, index) {
                      final cat = cats[index];
                      final isSelected = controller.selectedIndex.value == index;

                      return GestureDetector(
                        onTap: () {
                          controller.selectCategory(index);
                          Navigator.pop(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryPurple.withValues(alpha: 0.08) : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? AppColors.primaryPurple : Colors.grey.shade200,
                              width: isSelected ? 1.8 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.network(
                                    cat.image,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.category_outlined, size: 24, color: AppColors.primaryPurple),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Text(
                                  cat.category,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: isSelected
                                      ? AppTextStyles.bold.copyWith(fontSize: 11.5, color: AppColors.primaryPurple)
                                      : AppTextStyles.medium.copyWith(fontSize: 11.5, color: AppColors.darkText),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CategoriesController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        automaticallyImplyLeading: false, // Remove left leading menu icon
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            onChanged: (val) => controller.categorySearchQuery.value = val,
            decoration: InputDecoration(
              hintText: 'Search categories...',
              hintStyle: AppTextStyles.medium.copyWith(color: AppColors.hintText, fontSize: 13),
              prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.hintText),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            style: AppTextStyles.medium.copyWith(fontSize: 13, color: AppColors.darkText),
          ),
        ),
        centerTitle: false,
        actions: [
          // Icon-only Menu button on top right
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.grid_view_rounded, size: 20, color: AppColors.primaryPurple),
              ),
              tooltip: 'All Categories Menu',
              onPressed: () => _showCategoryPickerSheet(context, controller),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Column(
              children: [
                // Top Bar Shimmer
                Container(
                  height: 90,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 6,
                    itemBuilder: (_, __) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        children: [
                          Container(width: 48, height: 48, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white)),
                          const SizedBox(height: 6),
                          Container(width: 40, height: 10, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.58,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: 4,
                    itemBuilder: (_, __) => Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final filteredCats = controller.filteredCategories;

        if (filteredCats.isEmpty) {
          return Center(
            child: Text('No Categories Found', style: AppTextStyles.medium.copyWith(color: AppColors.hintText)),
          );
        }

        final selectedIndex = controller.selectedIndex.value >= filteredCats.length ? 0 : controller.selectedIndex.value;
        final selectedCat = filteredCats[selectedIndex];

        return Column(
          children: [
            // Top Horizontal Categories List (Image + Category Name underneath, 4+ scrollable)
            Container(
              height: 92,
              color: Colors.grey.shade50,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: filteredCats.length,
                itemBuilder: (context, index) {
                  final cat = filteredCats[index];
                  final isSelected = controller.selectedIndex.value == index;

                  return GestureDetector(
                    onTap: () => controller.selectCategory(index),
                    child: Container(
                      width: 76,
                      margin: const EdgeInsets.only(right: 6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                color: isSelected ? AppColors.primaryPurple : Colors.grey.shade300,
                                width: isSelected ? 2.2 : 1,
                              ),
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: AppColors.primaryPurple.withValues(alpha: 0.2),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.network(
                                cat.image,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.category_outlined, size: 20, color: AppColors.primaryPurple),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cat.category,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: isSelected
                                ? AppTextStyles.bold.copyWith(fontSize: 10.5, color: AppColors.primaryPurple)
                                : AppTextStyles.medium.copyWith(fontSize: 10.5, color: AppColors.darkText),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Clean Header Banner Bar for Selected Category (No Menu button inside)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(12, 6, 12, 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryPurple.withValues(alpha: 0.09),
                    AppColors.primaryPurple.withValues(alpha: 0.02),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      selectedCat.image,
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.category, color: AppColors.primaryPurple, size: 28),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedCat.category,
                          style: AppTextStyles.extraBold.copyWith(fontSize: 15, color: AppColors.darkText),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${controller.categoryProducts.length} items available',
                          style: AppTextStyles.medium.copyWith(fontSize: 11, color: AppColors.hintText),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Subcategories Filter Row (if present)
            if (selectedCat.subCategories.isNotEmpty) ...[
              Container(
                height: 34,
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    // "All" Pill
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: GestureDetector(
                        onTap: () => controller.filterBySubCategory(''),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: controller.selectedSubCategory.value.isEmpty
                                ? AppColors.primaryPurple
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: controller.selectedSubCategory.value.isEmpty
                                  ? AppColors.primaryPurple
                                  : Colors.grey.shade200,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'All',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: controller.selectedSubCategory.value.isEmpty ? FontWeight.bold : FontWeight.w500,
                                color: controller.selectedSubCategory.value.isEmpty ? Colors.white : AppColors.darkText,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    ...selectedCat.subCategories.map((subCat) {
                      final isSubSelected = controller.selectedSubCategory.value == subCat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: GestureDetector(
                          onTap: () => controller.filterBySubCategory(subCat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSubSelected ? AppColors.primaryPurple : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSubSelected ? AppColors.primaryPurple : Colors.grey.shade200,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                subCat,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: isSubSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSubSelected ? Colors.white : AppColors.darkText,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],

            // Full-Width Products Grid View (Overflow-Free Layout)
            Expanded(
              child: Obx(() {
                if (controller.isProductsLoading.value) {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(12),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.58,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        );
                      },
                    ),
                  );
                }

                if (controller.categoryProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.shopping_bag_outlined,
                            size: 36,
                            color: AppColors.primaryPurple.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No Products Found',
                          style: AppTextStyles.bold.copyWith(fontSize: 15, color: AppColors.darkText),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'No items in this category right now.',
                          style: AppTextStyles.medium.copyWith(fontSize: 12, color: AppColors.hintText),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.58,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: controller.categoryProducts.length,
                  itemBuilder: (context, index) {
                    final product = controller.categoryProducts[index];
                    return ProductCard(
                      product: product,
                      onAddToCart: (imageKey) {
                        if (!SessionManager.isLoggedIn) {
                          CustomPopup.showLoginRequired();
                          return;
                        }
                        Get.put(CartController()).addToCart(product.id, 1, product.name);
                      },
                    );
                  },
                );
              }),
            ),
          ],
        );
      }),
    );
  }
}
