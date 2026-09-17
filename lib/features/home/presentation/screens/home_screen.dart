import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../widgets/home_slider.dart';
import '../widgets/section_header.dart';
import '../widgets/product_card.dart';
import '../controllers/home_controller.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../../../core/utils/custom_popup.dart';

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
              title: TextField(
                decoration: InputDecoration(
                  hintText: 'Search for products...',
                  hintStyle: AppTextStyles.medium.copyWith(color: Colors.grey.shade400, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 22),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: AppTextStyles.medium.copyWith(color: AppColors.darkText, fontSize: 14),
              ),
            ),
            
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppDimensions.sm),
                  // Premium Slider
                  const HomeSlider(),
                  
                  const SizedBox(height: AppDimensions.md),
                  
                  // Clean Categories
                  const _CategorySection(),
                  
                  const SizedBox(height: AppDimensions.lg),

                  // 1. Top Selling Products (Row)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Top Selling',
                              style: AppTextStyles.extraBold.copyWith(fontSize: 22, color: AppColors.darkText, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Our most popular products this week',
                              style: AppTextStyles.medium.copyWith(fontSize: 12, color: AppColors.hintText),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text('See All', style: AppTextStyles.bold.copyWith(color: AppColors.primaryPurple, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.md),
                  
                  Obx(() {
                    if (controller.isLoading.value && controller.trendingProducts.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (controller.trendingProducts.isEmpty) {
                       return const SizedBox.shrink();
                    }
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
                                  onAddToCart: () {
                                    final cartCtrl = Get.put(CartController());
                                    cartCtrl.addToCart(product.id, 1, product.name);
                                  },
                                ),
                              ),
                            );
                          },
                      ),
                    );
                  }),

                  const SizedBox(height: AppDimensions.lg),

                  // 2. Flash Sale (Row)
                  Obx(() {
                    if (controller.isLoading.value) {
                       return const SizedBox.shrink(); 
                    }
                    if (controller.flashSaleProducts.isEmpty) {
                       return const SizedBox.shrink(); 
                    }
                    
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
                                    Row(
                                      children: [
                                        Text(
                                          'Flash Sale',
                                          style: AppTextStyles.extraBold.copyWith(fontSize: 22, color: AppColors.darkText, fontWeight: FontWeight.w900),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Ends in 02:45:10',
                                      style: AppTextStyles.bold.copyWith(fontSize: 12, color: AppColors.error),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: () {},
                                child: Text('See All', style: AppTextStyles.bold.copyWith(color: AppColors.primaryPurple, fontSize: 13)),
                              ),
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
                                      onAddToCart: () {
                                        final cartCtrl = Get.put(CartController());
                                        cartCtrl.addToCart(product.id, 1, product.name);
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

                  // 3. For You Section (Grid View)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'For You',
                                style: AppTextStyles.extraBold.copyWith(fontSize: 22, color: AppColors.darkText, fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Recommended based on your preferences',
                                style: AppTextStyles.medium.copyWith(fontSize: 12, color: AppColors.hintText),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {},
                          child: Text('See All', style: AppTextStyles.bold.copyWith(color: AppColors.primaryPurple, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.md),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
                    child: Obx(() {
                      if (controller.isLoading.value && controller.products.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      int crossAxisCount = MediaQuery.of(context).size.width > 1200 
                          ? 6 
                          : MediaQuery.of(context).size.width > 900 
                              ? 5 
                              : MediaQuery.of(context).size.width > 600 
                                  ? 4 
                                  : MediaQuery.of(context).size.width > 400 
                                      ? 3 
                                      : 2;

                      if (controller.products.isEmpty) {
                         return const SizedBox.shrink();
                      }
                      
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 0.58,
                          crossAxisSpacing: AppDimensions.md,
                          mainAxisSpacing: AppDimensions.md,
                        ),
                        itemCount: controller.products.length,
                        itemBuilder: (context, index) {
                          final product = controller.products[index];
                          return SizedBox(
                            height: 290,
                            child: ProductCard(
                              product: product,
                              onAddToCart: () {
                                final cartCtrl = Get.put(CartController());
                                cartCtrl.addToCart(product.id, 1, product.name);
                              },
                            ),
                          );
                        },
                      );
                    }),
                  ),
                  
                  const SizedBox(height: AppDimensions.xxl),
                ],
              ),
            ),
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
    final categories = [
      {'icon': Icons.phone_iphone, 'name': 'Mobiles'},
      {'icon': Icons.laptop_mac, 'name': 'Laptops'},
      {'icon': Icons.checkroom, 'name': 'Fashion'},
      {'icon': Icons.chair, 'name': 'Furniture'},
      {'icon': Icons.sports_esports, 'name': 'Gaming'},
      {'icon': Icons.watch, 'name': 'Watches'},
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: AppDimensions.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    categories[index]['icon'] as IconData,
                    color: AppColors.primaryPurple,
                    size: 28,
                  ),
                ),
                const SizedBox(height: AppDimensions.sm),
                Text(
                  categories[index]['name'] as String,
                  style: AppTextStyles.semiBold.copyWith(fontSize: 11, color: AppColors.darkText),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
