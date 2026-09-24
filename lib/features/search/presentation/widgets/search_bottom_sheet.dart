import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/search_controller.dart' as my_search;
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../home/presentation/widgets/product_card.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../../../core/utils/session_manager.dart';
import '../../../../core/utils/custom_popup.dart';

class SearchBottomSheet extends StatefulWidget {
  const SearchBottomSheet({super.key});

  @override
  State<SearchBottomSheet> createState() => _SearchBottomSheetState();
}

class _SearchBottomSheetState extends State<SearchBottomSheet> {
  final TextEditingController _textController = TextEditingController();
  final my_search.SearchController _searchCtrl = Get.put(my_search.SearchController());

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {});
    if (value.trim().isEmpty) {
      _searchCtrl.clearSearch();
    } else if (value.trim().isNotEmpty) {
      _searchCtrl.searchProducts(value.trim());
    }
  }

  void _onSearchSubmit(String value) {
    if (value.trim().isNotEmpty) {
      _searchCtrl.searchProducts(value.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppDimensions.radiusLg),
          topRight: Radius.circular(AppDimensions.radiusLg),
        ),
      ),
      child: Column(
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: AppDimensions.md, bottom: AppDimensions.sm),
              height: 5,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          
          // Search Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: AppDimensions.sm),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _textController,
                autofocus: true,
                onChanged: _onSearchChanged,
                onSubmitted: _onSearchSubmit,
                decoration: InputDecoration(
                  hintText: 'Search for products...',
                  hintStyle: AppTextStyles.medium.copyWith(color: Colors.grey.shade400, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 22),
                  suffixIcon: _textController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                          onPressed: () {
                            _textController.clear();
                            _searchCtrl.clearSearch();
                            setState(() {});
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: AppColors.primaryPurple, width: 1.5),
                  ),
                ),
                style: AppTextStyles.medium.copyWith(color: AppColors.darkText, fontSize: 14),
              ),
            ),
          ),
          
          const SizedBox(height: AppDimensions.sm),
          
          Expanded(
            child: Obx(() {
              if (_searchCtrl.isSearching.value) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primaryPurple));
              }

              if (_textController.text.trim().isEmpty) {
                if (_searchCtrl.recentProducts.isEmpty && _searchCtrl.recentSearches.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_rounded, size: 60, color: Colors.grey.shade300),
                        const SizedBox(height: AppDimensions.md),
                        Text('Type to search for products', style: AppTextStyles.medium.copyWith(color: Colors.grey.shade400)),
                      ],
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Recent Query Keywords Chips (if any)
                      if (_searchCtrl.recentSearches.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Keywords',
                              style: AppTextStyles.semiBold.copyWith(fontSize: 12, color: AppColors.hintText),
                            ),
                            InkWell(
                              onTap: () => _searchCtrl.clearAllSearchHistory(),
                              child: Text(
                                'Clear Keywords',
                                style: AppTextStyles.medium.copyWith(fontSize: 11, color: AppColors.error),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: _searchCtrl.recentSearches.map((query) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          _textController.text = query;
                                          _textController.selection = TextSelection.fromPosition(
                                            TextPosition(offset: query.length),
                                          );
                                          _searchCtrl.searchProducts(query);
                                          setState(() {});
                                        },
                                        child: Text(
                                          query,
                                          style: AppTextStyles.medium.copyWith(fontSize: 12, color: AppColors.darkText),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      InkWell(
                                        onTap: () => _searchCtrl.removeSearchItem(query),
                                        child: Icon(Icons.close_rounded, size: 14, color: Colors.grey.shade500),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Recently Searched Products Section Header
                      if (_searchCtrl.recentProducts.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.history_rounded, size: 20, color: AppColors.primaryPurple),
                                const SizedBox(width: 8),
                                Text(
                                  'Recently Searched Products',
                                  style: AppTextStyles.bold.copyWith(fontSize: 14, color: AppColors.darkText),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: () => _searchCtrl.clearAllProductHistory(),
                              borderRadius: BorderRadius.circular(6),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                child: Text(
                                  'Clear All',
                                  style: AppTextStyles.bold.copyWith(fontSize: 12, color: AppColors.error),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            itemCount: _searchCtrl.recentProducts.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final product = _searchCtrl.recentProducts[index];
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.15)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryPurple.withValues(alpha: 0.04),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () {
                                      _searchCtrl.addProductToHistory(product);
                                      Get.toNamed('/product-detail', arguments: product.id);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Row(
                                        children: [
                                          // Thumbnail Image
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: Image.network(
                                              product.image,
                                              width: 65,
                                              height: 65,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Container(
                                                width: 65,
                                                height: 65,
                                                color: Colors.grey.shade100,
                                                child: const Icon(Icons.image_not_supported, size: 20, color: Colors.grey),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),

                                          // Product Details
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  product.name,
                                                  style: AppTextStyles.bold.copyWith(fontSize: 13, color: AppColors.darkText),
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
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Rs. ${product.price}',
                                                  style: AppTextStyles.extraBold.copyWith(fontSize: 13.5, color: AppColors.primaryPurple),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),

                                          // Clear / Delete Product Icon
                                          InkWell(
                                            onTap: () => _searchCtrl.removeProductFromHistory(product.id),
                                            borderRadius: BorderRadius.circular(15),
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade100,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.close_rounded,
                                                size: 18,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }

              if (_searchCtrl.searchResults.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded, size: 50, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text('No products found', style: AppTextStyles.semiBold.copyWith(color: AppColors.hintText, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text('Try searching with a different keyword', style: AppTextStyles.medium.copyWith(color: Colors.grey.shade400, fontSize: 12)),
                    ],
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
                itemCount: _searchCtrl.searchResults.length,
                itemBuilder: (context, index) {
                  final product = _searchCtrl.searchResults[index];
                  return GestureDetector(
                    onTap: () {
                      _searchCtrl.addProductToHistory(product);
                    },
                    child: ProductCard(
                      product: product,
                      onAddToCart: (imageKey) {
                        if (!SessionManager.isLoggedIn) {
                          CustomPopup.showLoginRequired();
                          return;
                        }
                        Get.put(CartController()).addToCart(product.id, 1, product.name);
                      },
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
