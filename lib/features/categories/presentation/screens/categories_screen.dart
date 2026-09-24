import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/custom_popup.dart';
import '../../../../core/utils/session_manager.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../../wishlist/presentation/controllers/wishlist_controller.dart';
import '../controllers/categories_controller.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CategoriesController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text('Categories', style: AppTextStyles.bold.copyWith(color: AppColors.darkText, fontSize: 18)),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Row(
              children: [
                // Left Sidebar Shimmer
                Container(
                  width: 85,
                  color: Colors.grey.shade100,
                  child: ListView.builder(
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
                        child: Column(
                          children: [
                            Container(width: 48, height: 48, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white)),
                            const SizedBox(height: 6),
                            Container(width: 40, height: 8, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // Right Content Shimmer
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 120, height: 16, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                        const SizedBox(height: 6),
                        Container(width: 80, height: 10, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView.builder(
                            itemCount: 4,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Container(
                                  height: 90,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            },
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

        if (controller.categoriesList.isEmpty) {
          return Center(
            child: Text('No Categories Found', style: AppTextStyles.medium.copyWith(color: AppColors.hintText)),
          );
        }

        final selectedCat = controller.categoriesList[controller.selectedIndex.value];

        return Row(
          children: [
            // Left Sidebar Categories List
            Container(
              width: 85,
              color: Colors.grey.shade50,
              child: ListView.builder(
                itemCount: controller.categoriesList.length,
                itemBuilder: (context, index) {
                  final cat = controller.categoriesList[index];
                  final isSelected = controller.selectedIndex.value == index;

                  return GestureDetector(
                    onTap: () => controller.selectCategory(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.transparent,
                        border: Border(
                          left: BorderSide(
                            color: isSelected ? AppColors.primaryPurple : Colors.transparent,
                            width: 3.5,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: AppColors.primaryPurple.withValues(alpha: 0.15),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.network(
                                cat.image,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.category_outlined, size: 22, color: AppColors.primaryPurple),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            cat.category,
                            textAlign: TextAlign.center,
                            style: isSelected
                                ? AppTextStyles.bold.copyWith(fontSize: 10.5, color: AppColors.primaryPurple)
                                : AppTextStyles.medium.copyWith(fontSize: 10.5, color: AppColors.darkText),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Right Content Area (Subcategories + Category Products List)
            Expanded(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Styled Category Header Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryPurple.withValues(alpha: 0.08),
                            AppColors.primaryPurple.withValues(alpha: 0.02),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.12)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedCat.category,
                                  style: AppTextStyles.extraBold.copyWith(fontSize: 16, color: AppColors.darkText),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Explore top items',
                                  style: AppTextStyles.medium.copyWith(fontSize: 11, color: AppColors.hintText),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.primaryPurple,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${controller.categoryProducts.length} items',
                              style: AppTextStyles.bold.copyWith(fontSize: 11, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Subcategories Filter Pills
                    if (selectedCat.subCategories.isNotEmpty) ...[
                      SizedBox(
                        height: 34,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
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
                                    borderRadius: BorderRadius.circular(18),
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
                                      borderRadius: BorderRadius.circular(18),
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
                      const SizedBox(height: 12),
                    ],

                    // Products List View
                    Expanded(
                      child: Obx(() {
                        if (controller.isProductsLoading.value) {
                          return Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: ListView.builder(
                              itemCount: 4,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Container(
                                    height: 90,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
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
                                  style: AppTextStyles.medium.copyWith(fontSize: 11, color: AppColors.hintText),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          itemCount: controller.categoryProducts.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final product = controller.categoryProducts[index];
                            final cartCtrl = Get.put(CartController());
                            final wishlistCtrl = Get.find<WishlistController>();

                            return GestureDetector(
                              onTap: () => Get.toNamed('/product-detail', arguments: product.id),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.primaryPurple.withValues(alpha: 0.18),
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryPurple.withValues(alpha: 0.06),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    // Product Image
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        product.image,
                                        width: 75,
                                        height: 75,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          width: 75,
                                          height: 75,
                                          color: Colors.grey.shade100,
                                          child: const Icon(Icons.image_not_supported, size: 24, color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    
                                    // Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.name,
                                            style: AppTextStyles.bold.copyWith(fontSize: 12.5, color: AppColors.darkText),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                                              const SizedBox(width: 3),
                                              Text(
                                                '${product.rating.toStringAsFixed(1)} (${product.totalReviews})',
                                                style: AppTextStyles.medium.copyWith(fontSize: 10, color: AppColors.hintText),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Rs. ${product.price}',
                                            style: AppTextStyles.extraBold.copyWith(fontSize: 13.5, color: AppColors.primaryPurple),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Action buttons
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Obx(() {
                                          final isWish = wishlistCtrl.isFavorite(product.id);
                                          return InkWell(
                                            borderRadius: BorderRadius.circular(20),
                                            onTap: () {
                                              if (!SessionManager.isLoggedIn) {
                                                CustomPopup.showLoginRequired();
                                                return;
                                              }
                                              wishlistCtrl.toggleWishlist(product.id);
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(7),
                                              decoration: BoxDecoration(
                                                color: isWish ? Colors.red.shade50 : Colors.grey.shade100,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                isWish ? Icons.favorite : Icons.favorite_border,
                                                color: isWish ? Colors.red : Colors.grey.shade600,
                                                size: 20,
                                              ),
                                            ),
                                          );
                                        }),
                                        const SizedBox(height: 8),
                                        InkWell(
                                          borderRadius: BorderRadius.circular(8),
                                          onTap: () {
                                            if (!SessionManager.isLoggedIn) {
                                              CustomPopup.showLoginRequired();
                                              return;
                                            }
                                            cartCtrl.addToCart(product.id, 1, product.name);
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryPurple,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.add_shopping_cart,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ],
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
              ),
            ),
          ],
        );
      }),
    );
  }
}
