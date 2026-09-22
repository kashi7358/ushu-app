import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../controllers/store_controller.dart';
import '../../../home/presentation/widgets/product_card.dart';
import '../../../home/data/models/product_model.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StoreController());

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildShimmer();
        }

        if (controller.storeData.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.store_outlined, size: 64, color: AppColors.hintText),
                const SizedBox(height: 16),
                Text('Store not found', style: AppTextStyles.bold.copyWith(color: AppColors.hintText)),
              ],
            ),
          );
        }

        final store = controller.storeData;
        final storeName = store['storeName'] ?? store['StoreName'] ?? 'Verified Store';
        final storeLogo = store['logo'];
        final storeBanner = store['banner'];
        final tagline = store['tagline']?.toString().trim() ?? '';
        final location = store['location']?.toString().trim() ?? '';
        final totalProducts = store['totalProducts'] ?? 0;
        final rating = store['rating'] ?? 0.0;
        final returnPolicy = store['returnPolicy']?.toString().trim() ?? '';
        final processingTime = store['processingTime']?.toString().trim() ?? '';
        
        final descText = store['description']?.toString().trim();
        final description = (descText != null && descText.isNotEmpty && descText.toLowerCase() != 'no discription')
            ? descText
            : 'Welcome to our official store. We provide top quality products.';

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 250, // Increased height
              pinned: true,
              backgroundColor: AppColors.primaryPurple,
              iconTheme: const IconThemeData(color: Colors.white),
              actions: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: () {
                    if (Get.isRegistered<MainLayoutController>()) {
                      Get.find<MainLayoutController>().changePage(2); // Switch to Cart tab
                    }
                    Get.offAllNamed('/main');
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Banner Image - blurred background
                    if (storeBanner != null && storeBanner.isNotEmpty)
                      Image.network(storeBanner, fit: BoxFit.cover),
                    if (storeBanner != null && storeBanner.isNotEmpty)
                      Container(color: Colors.black.withValues(alpha: 0.5)),
                    
                    // Banner Image - actual
                    Container(
                      color: Colors.transparent,
                      child: storeBanner != null && storeBanner.isNotEmpty
                          ? Image.network(storeBanner, fit: BoxFit.contain)
                          : const Center(child: Icon(Icons.image, size: 50, color: AppColors.hintText)),
                    ),
                    // Gradient overlay to make back button visible
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.7),
                            Colors.transparent,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Profile Header
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade200),
                              color: Colors.white,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(40),
                              child: storeLogo != null && storeLogo.isNotEmpty
                                  ? Image.network(storeLogo, fit: BoxFit.cover)
                                  : const Icon(Icons.storefront, size: 40, color: Colors.grey),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        storeName,
                                        style: AppTextStyles.bold.copyWith(fontSize: 18, color: AppColors.darkText),
                                      ),
                                    ),
                                    Obx(() {
                                      final isFollowing = controller.isFollowing.value;
                                      return GestureDetector(
                                        onTap: controller.toggleFollow,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: isFollowing ? Colors.grey.shade200 : AppColors.primaryPurple,
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                isFollowing ? Icons.check : Icons.add, 
                                                color: isFollowing ? AppColors.darkText : Colors.white, 
                                                size: 14
                                              ),
                                              const SizedBox(width: 2),
                                              Text(
                                                isFollowing ? 'Following' : 'Follow', 
                                                style: AppTextStyles.bold.copyWith(
                                                  color: isFollowing ? AppColors.darkText : Colors.white, 
                                                  fontSize: 11
                                                )
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                                if (tagline.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    tagline,
                                    style: AppTextStyles.medium.copyWith(color: AppColors.hintText, fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatItem(Icons.inventory_2_outlined, '$totalProducts', 'Products'),
                          Container(width: 1, height: 30, color: Colors.grey.shade300),
                          _buildStatItem(Icons.star_border_rounded, (rating is num ? rating.toDouble() : 0.0).toStringAsFixed(1), 'Rating'),
                          Container(width: 1, height: 30, color: Colors.grey.shade300),
                          _buildStatItem(Icons.location_on_outlined, location.isNotEmpty ? location : 'Pakistan', 'Location'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Badges
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (processingTime.isNotEmpty) ...[
                              _buildBadge(Icons.access_time, processingTime),
                              const SizedBox(width: 8),
                            ],
                            if (returnPolicy.isNotEmpty) ...[
                              _buildBadge(Icons.assignment_return_outlined, returnPolicy),
                              const SizedBox(width: 8),
                            ],
                            _buildBadge(Icons.verified_outlined, 'Verified Store'),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      Text(
                        description,
                        style: AppTextStyles.regular.copyWith(color: AppColors.darkText.withValues(alpha: 0.8), fontSize: 13, height: 1.5),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Text('All Products', style: AppTextStyles.bold.copyWith(fontSize: 16, color: AppColors.darkText)),
              ),
            ),

            // Products Grid
            controller.productsData.isEmpty
                ? SliverToBoxAdapter(
                    child: Container(
                      color: Colors.white,
                      height: 300,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Column(
                            children: [
                              Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text('No products available yet', style: AppTextStyles.medium.copyWith(color: AppColors.hintText)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.55,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final productModel = ProductModel.fromJson(controller.productsData[index]);
                          return ProductCard(
                            product: productModel,
                          );
                        },
                        childCount: controller.productsData.length,
                      ),
                    ),
                  ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        );
      }),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.darkText),
            const SizedBox(width: 4),
            Text(value, style: AppTextStyles.bold.copyWith(fontSize: 14, color: AppColors.darkText)),
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.medium.copyWith(fontSize: 11, color: AppColors.hintText)),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.primaryPurple),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.medium.copyWith(fontSize: 11, color: AppColors.darkText)),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: [
          Container(height: 250, width: double.infinity, color: Colors.white),
          Container(
            height: 250,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
