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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Logo
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade200, width: 2),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                              ],
                              image: storeLogo != null && storeLogo.isNotEmpty
                                  ? DecorationImage(image: NetworkImage(storeLogo), fit: BoxFit.cover)
                                  : null,
                            ),
                            child: storeLogo == null || storeLogo.isEmpty
                                ? const Icon(Icons.store, color: AppColors.primaryPurple, size: 32)
                                : null,
                          ),
                          const SizedBox(width: 16),
                          // Name and Tagline
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        storeName,
                                        style: AppTextStyles.extraBold.copyWith(fontSize: 18, color: AppColors.darkText),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryPurple,
                                        borderRadius: BorderRadius.circular(100),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.add, color: Colors.white, size: 14),
                                          const SizedBox(width: 2),
                                          Text('Follow', style: AppTextStyles.bold.copyWith(color: Colors.white, fontSize: 11)),
                                        ],
                                      ),
                                    ),
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
                          Container(width: 1, height: 24, color: Colors.grey.shade300),
                          _buildStatItem(Icons.star_outline, rating.toString(), 'Rating'),
                          if (location.isNotEmpty) ...[
                            Container(width: 1, height: 24, color: Colors.grey.shade300),
                            _buildStatItem(Icons.location_on_outlined, location, 'Location'),
                          ],
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Mini info chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (processingTime.isNotEmpty) _buildInfoChip(Icons.access_time, processingTime),
                            if (returnPolicy.isNotEmpty) _buildInfoChip(Icons.replay_circle_filled_outlined, returnPolicy),
                            _buildInfoChip(Icons.verified_outlined, 'Verified Store'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Description
                      Text(
                        description,
                        style: AppTextStyles.regular.copyWith(color: AppColors.hintText, height: 1.4, fontSize: 13),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Products Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text('All Products', style: AppTextStyles.bold.copyWith(fontSize: 18, color: AppColors.darkText)),
              ),
            ),

            // Products Grid
            controller.productsData.isEmpty
                ? SliverToBoxAdapter(
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
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.55, // Changed to 0.55 to provide much more height and prevent overflow
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final productModel = ProductModel.fromJson(controller.productsData[index]);
                          return ProductCard(
                            product: productModel,
                            onAddToCart: (key) {},
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
