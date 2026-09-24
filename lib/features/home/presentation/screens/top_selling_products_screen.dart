import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/custom_popup.dart';
import '../../../../core/utils/session_manager.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../widgets/product_card.dart';
import '../../data/models/product_model.dart';
import '../../domain/entities/product_entity.dart';

enum ProductSortOption { defaultSort, priceLowToHigh, priceHighToLow, topRated }

class TopSellingProductsScreen extends StatefulWidget {
  const TopSellingProductsScreen({super.key});

  @override
  State<TopSellingProductsScreen> createState() => _TopSellingProductsScreenState();
}

class _TopSellingProductsScreenState extends State<TopSellingProductsScreen> {
  final HomeController _homeCtrl = Get.find<HomeController>();
  final TextEditingController _searchController = TextEditingController();
  ProductSortOption _selectedSort = ProductSortOption.defaultSort;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProductEntity> _getFilteredAndSortedProducts(List<ProductEntity> rawList) {
    List<ProductEntity> list = List.from(rawList);

    // Apply Search Filter
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list.where((p) => p.name.toLowerCase().contains(q) || p.category.toLowerCase().contains(q) || p.brand.toLowerCase().contains(q)).toList();
    }

    // Apply Sorting
    switch (_selectedSort) {
      case ProductSortOption.priceLowToHigh:
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case ProductSortOption.priceHighToLow:
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case ProductSortOption.topRated:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case ProductSortOption.defaultSort:
        break;
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.darkText, size: 18),
          onPressed: () => Get.back(),
        ),
        title: Column(
          children: [
            Text(
              'Top Selling Products',
              style: AppTextStyles.bold.copyWith(color: AppColors.darkText, fontSize: 17),
            ),
            Obx(() => Text(
              '${_homeCtrl.trendingProducts.length} Most Popular Items',
              style: AppTextStyles.medium.copyWith(color: AppColors.hintText, fontSize: 11),
            )),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filter & Search Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: 10),
            child: Column(
              children: [
                // Search Input Field
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search top selling products...',
                      hintStyle: AppTextStyles.medium.copyWith(color: Colors.grey.shade400, fontSize: 13),
                      prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, color: Colors.grey, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    style: AppTextStyles.medium.copyWith(color: AppColors.darkText, fontSize: 13.5),
                  ),
                ),
                const SizedBox(height: 10),

                // Sorting Filter Chips Bar
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildSortChip(ProductSortOption.defaultSort, 'All Popular', Icons.local_fire_department_rounded),
                      const SizedBox(width: 8),
                      _buildSortChip(ProductSortOption.topRated, 'Top Rated', Icons.star_rounded),
                      const SizedBox(width: 8),
                      _buildSortChip(ProductSortOption.priceLowToHigh, 'Price: Low to High', Icons.arrow_upward_rounded),
                      const SizedBox(width: 8),
                      _buildSortChip(ProductSortOption.priceHighToLow, 'Price: High to Low', Icons.arrow_downward_rounded),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.black12),

          // Main Product Grid View
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primaryPurple,
              onRefresh: () async {
                await _homeCtrl.fetchTrendingProducts();
              },
              child: Obx(() {
                if (_homeCtrl.isTrendingLoading.value && _homeCtrl.trendingProducts.isEmpty) {
                  return GridView.builder(
                    padding: const EdgeInsets.all(AppDimensions.md),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      childAspectRatio: 0.58,
                      crossAxisSpacing: AppDimensions.md,
                      mainAxisSpacing: AppDimensions.md,
                    ),
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      return Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: const ShimmerProductCard(),
                      );
                    },
                  );
                }

                final displayList = _getFilteredAndSortedProducts(_homeCtrl.trendingProducts);

                if (displayList.isEmpty) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.primaryPurple.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.search_off_rounded, size: 48, color: AppColors.primaryPurple),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No products found',
                              style: AppTextStyles.bold.copyWith(fontSize: 16, color: AppColors.darkText),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Try searching with a different term or filter',
                              style: AppTextStyles.medium.copyWith(fontSize: 12, color: AppColors.hintText),
                            ),
                            if (_searchQuery.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                    _selectedSort = ProductSortOption.defaultSort;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryPurple,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: Text('Reset Filters', style: AppTextStyles.bold.copyWith(color: Colors.white, fontSize: 12)),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(AppDimensions.md),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 0.58,
                    crossAxisSpacing: AppDimensions.md,
                    mainAxisSpacing: AppDimensions.md,
                  ),
                  itemCount: displayList.length,
                  itemBuilder: (context, index) {
                    final item = displayList[index];
                    final productModel = item is ProductModel
                        ? item
                        : ProductModel(
                            id: item.id,
                            name: item.name,
                            price: item.price,
                            discountPriceOrg: item.discountPriceOrg,
                            priceCurrency: item.priceCurrency,
                            category: item.category,
                            brand: item.brand,
                            stock: item.stock,
                            image: item.image,
                            rating: item.rating,
                            totalReviews: item.totalReviews,
                            description: item.description,
                            images: item.images,
                            storeName: item.storeName,
                            storeLogo: item.storeLogo,
                            storeId: item.storeId,
                          );

                    return ProductCard(
                      product: productModel,
                      onAddToCart: (imageKey) {
                        if (!SessionManager.isLoggedIn) {
                          CustomPopup.showLoginRequired();
                          return;
                        }
                        Get.put(CartController()).addToCart(productModel.id, 1, productModel.name);
                      },
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(ProductSortOption option, String label, IconData icon) {
    final isSelected = _selectedSort == option;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSort = option;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryPurple : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? AppColors.primaryPurple : Colors.grey.shade200,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryPurple.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : AppColors.hintText,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.medium.copyWith(
                color: isSelected ? Colors.white : AppColors.darkText,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
