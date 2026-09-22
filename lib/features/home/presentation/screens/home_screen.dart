import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../features/categories/presentation/controllers/categories_controller.dart';
import '../../../../core/utils/session_manager.dart';
import '../../../../core/utils/custom_popup.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../widgets/home_slider.dart';
import '../widgets/product_card.dart';
import '../controllers/home_controller.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../../../features/main_layout/presentation/controllers/main_layout_controller.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Greeting Top Area
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(AppDimensions.md, AppDimensions.lg, AppDimensions.md, AppDimensions.sm),
                color: AppColors.lightBackground,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.primaryPurple.withOpacity(0.1),
                          child: const Icon(Icons.person, color: AppColors.primaryPurple),
                        ),
                        const SizedBox(width: AppDimensions.sm),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Good Morning,', style: AppTextStyles.medium.copyWith(color: AppColors.hintText, fontSize: 11)),
                            Text('Welcome to Ushu!', style: AppTextStyles.extraBold.copyWith(fontSize: 14, color: AppColors.darkText)),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_none_rounded, color: AppColors.darkText),
                            onPressed: () {},
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Pinned Search Bar
            SliverAppBar(
              backgroundColor: AppColors.lightBackground,
              floating: true,
              pinned: true,
              elevation: 0,
              toolbarHeight: 65,
              title: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search for products...',
                    hintStyle: AppTextStyles.medium.copyWith(color: Colors.grey.shade400, fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 22),
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
            
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppDimensions.sm),
                  const HomeSlider(),
                  const SizedBox(height: AppDimensions.md),
                  const _CategorySection(),
                  const SizedBox(height: AppDimensions.lg),

                  // 1. Top Selling Products
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Top Selling', style: AppTextStyles.extraBold.copyWith(fontSize: 22, color: AppColors.darkText, fontWeight: FontWeight.w900)),
                            const SizedBox(height: 4),
                            Text('Our most popular products this week', style: AppTextStyles.medium.copyWith(fontSize: 12, color: AppColors.hintText)),
                          ],
                        ),
                        TextButton(onPressed: () {}, child: Text('See All', style: AppTextStyles.bold.copyWith(color: AppColors.primaryPurple, fontSize: 13))),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.md),
                  Obx(() {
                    if (controller.isTrendingLoading.value && controller.trendingProducts.isEmpty) {
                      return SizedBox(
                        height: 290,
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            itemCount: 3,
                            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
                            itemBuilder: (context, index) {
                              return const Padding(
                                padding: EdgeInsets.only(right: AppDimensions.md, bottom: AppDimensions.sm),
                                child: SizedBox(width: 170, child: ShimmerProductCard()),
                              );
                            },
                          ),
                        ),
                      );
                    }
                    if (controller.trendingProducts.isEmpty) return const SizedBox.shrink();
                    return SizedBox(
                      height: 290,
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.trendingProducts.length,
                        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
                        itemBuilder: (context, index) {
                          final product = controller.trendingProducts[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: AppDimensions.md, bottom: AppDimensions.sm),
                            child: SizedBox(
                              width: 170,
                              child: ProductCard(
                                product: product,
                                onAddToCart: (imageKey) {
                                  if (!SessionManager.isLoggedIn) {
                                    CustomPopup.showLoginRequired();
                                    return;
                                  }
                                  // final mainLayoutCtrl = Get.find<MainLayoutController>();
                                  // mainLayoutCtrl.runAddToCartAnimation(imageKey);
                                  Get.put(CartController()).addToCart(product.id, 1, product.name);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                  const SizedBox(height: AppDimensions.lg),

                  // 2. Flash Sale
                  Obx(() {
                    if (controller.isFlashSaleLoading.value && controller.flashSaleProducts.isEmpty) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Flash Sale', style: AppTextStyles.extraBold.copyWith(fontSize: 22, color: AppColors.darkText, fontWeight: FontWeight.w900)),
                                      const SizedBox(height: 4),
                                      Text('Loading...', style: AppTextStyles.bold.copyWith(fontSize: 12, color: AppColors.error), maxLines: 1),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppDimensions.md),
                          SizedBox(
                            height: 290,
                            child: Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: 3,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: EdgeInsets.only(right: AppDimensions.md, bottom: AppDimensions.sm, left: index == 0 ? AppDimensions.md : 0),
                                    child: const SizedBox(width: 170, child: ShimmerProductCard()),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    if (controller.flashSaleProducts.isEmpty) return const SizedBox.shrink();
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Flash Sale', style: AppTextStyles.extraBold.copyWith(fontSize: 22, color: AppColors.darkText, fontWeight: FontWeight.w900)),
                                    const SizedBox(height: 4),
                                    Text('Ends in 02:45:10', style: AppTextStyles.bold.copyWith(fontSize: 12, color: AppColors.error), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              TextButton(onPressed: () {}, child: Text('See All', style: AppTextStyles.bold.copyWith(color: AppColors.primaryPurple, fontSize: 13))),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppDimensions.md),
                        SizedBox(
                          height: 290,
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            itemCount: controller.flashSaleProducts.length,
                            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
                            itemBuilder: (context, index) {
                              final product = controller.flashSaleProducts[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: AppDimensions.md, bottom: AppDimensions.sm),
                                child: SizedBox(
                                  width: 170,
                                  child: ProductCard(
                                    product: product,
                                    onAddToCart: (imageKey) {
                                      if (!SessionManager.isLoggedIn) {
                                        CustomPopup.showLoginRequired();
                                        return;
                                      }
                                      // final mainLayoutCtrl = Get.find<MainLayoutController>();
                                      // mainLayoutCtrl.runAddToCartAnimation(imageKey);
                                      Get.put(CartController()).addToCart(product.id, 1, product.name);
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: AppDimensions.lg),

                  // 3. For You Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('For You', style: AppTextStyles.extraBold.copyWith(fontSize: 22, color: AppColors.darkText, fontWeight: FontWeight.w900)),
                              const SizedBox(height: 4),
                              Text('Recommended based on your preferences', style: AppTextStyles.medium.copyWith(fontSize: 12, color: AppColors.hintText), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(onPressed: () {}, child: Text('See All', style: AppTextStyles.bold.copyWith(color: AppColors.primaryPurple, fontSize: 13))),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.md),
                ],
              ),
            ),
            
            // For You Grid (Optimized Sliver)
            Obx(() {
              if (controller.isLoading.value && controller.products.isEmpty) {
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      childAspectRatio: 0.58,
                      crossAxisSpacing: AppDimensions.md,
                      mainAxisSpacing: AppDimensions.md,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: const ShimmerProductCard(),
                        );
                      },
                      childCount: 4,
                    ),
                  ),
                );
              }
              if (controller.products.isEmpty) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 0.58,
                    crossAxisSpacing: AppDimensions.md,
                    mainAxisSpacing: AppDimensions.md,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = controller.products[index];
                      return ProductCard(
                        product: product,
                        onAddToCart: (imageKey) {
                          if (!SessionManager.isLoggedIn) {
                            CustomPopup.showLoginRequired();
                            return;
                          }
                          // final mainLayoutCtrl = Get.find<MainLayoutController>();
                          // mainLayoutCtrl.runAddToCartAnimation(imageKey);
                          Get.put(CartController()).addToCart(product.id, 1, product.name);
                        },
                      );
                    },
                    childCount: controller.products.length,
                  ),
                ),
              );
            }),
            
            const SliverToBoxAdapter(child: SizedBox(height: AppDimensions.xxl)),
          ],
        ),
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection();

  @override
  Widget build(BuildContext context) {
    // Inject CategoriesController if not already injected
    final controller = Get.put(CategoriesController());

    return Obx(() {
      if (controller.isLoading.value) {
        return const SizedBox(
          height: 100,
          child: Center(child: CircularProgressIndicator(color: AppColors.primaryPurple)),
        );
      }

      if (controller.categoriesList.isEmpty) {
        return const SizedBox();
      }

      return SizedBox(
        height: 110,
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: controller.categoriesList.length,
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
          itemBuilder: (context, index) {
            final cat = controller.categoriesList[index];
            return Padding(
              padding: const EdgeInsets.only(right: AppDimensions.md),
              child: GestureDetector(
                onTap: () {
                   Get.find<MainLayoutController>().changePage(1);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.network(
                          cat.image,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    SizedBox(
                      width: 70,
                      child: Text(
                        cat.category,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.semiBold.copyWith(fontSize: 11, color: AppColors.darkText),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
