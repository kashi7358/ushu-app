import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/session_manager.dart';
import '../../../../core/utils/custom_popup.dart';
import '../controllers/product_detail_controller.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../../wishlist/presentation/controllers/wishlist_controller.dart';
import '../../../chatbot/presentation/screens/chatbot_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProductDetailController());

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back_ios_new, color: AppColors.white, size: 18),
          ),
        ),
        actions: [
          Obx(() {
            final product = controller.product.value;
            final isRegistered = Get.isRegistered<WishlistController>();
            final isFav = isRegistered && product != null 
                ? Get.find<WishlistController>().isFavorite(product.id) 
                : false;

            return Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), shape: BoxShape.circle),
              child: IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border, 
                  color: isFav ? AppColors.error : AppColors.white, 
                  size: 20
                ),
                onPressed: () {
                  if (isRegistered && product != null) {
                    Get.find<WishlistController>().toggleWishlist(product.id);
                  }
                },
              ),
            );
          }),
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
            child: IconButton(
              icon: const Icon(Icons.share, color: AppColors.white, size: 20),
              onPressed: () {},
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 65,
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (controller.product.value?.storeId != null && controller.product.value!.storeId!.isNotEmpty) {
                          Get.toNamed('/store', arguments: controller.product.value!.storeId);
                        } else {
                          CustomPopup.showToast('Store not found', 'This product does not have a valid store.', isError: true);
                        }
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.storefront, color: AppColors.primaryPurple, size: 22),
                          const SizedBox(height: 2),
                          Text('Store', style: AppTextStyles.medium.copyWith(fontSize: 10, color: AppColors.darkText)),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 35, color: Colors.grey.shade300),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        // Import ChatbotScreen locally or navigate by name if we register it
                        Get.to(() => const ChatbotScreen());
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.chat_bubble_outline, color: AppColors.primaryPurple, size: 22),
                          const SizedBox(height: 2),
                          Text('Chat', style: AppTextStyles.medium.copyWith(fontSize: 10, color: AppColors.darkText)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () {
                    if (controller.product.value != null) {
                      if (!SessionManager.isLoggedIn) {
                        CustomPopup.showLoginRequired();
                        return;
                      }
                      final cartCtrl = Get.put(CartController());
                      cartCtrl.addToCart(controller.product.value!.id, 1, controller.product.value!.name);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade500,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text('Add to Cart', style: AppTextStyles.bold.copyWith(color: AppColors.white, fontSize: 13)),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () async {
                    if (controller.product.value != null) {
                      if (!SessionManager.isLoggedIn) {
                        CustomPopup.showLoginRequired();
                        return;
                      }
                      final cartCtrl = Get.put(CartController());
                      final success = await cartCtrl.buyNow(controller.product.value!.id, 1, controller.product.value!.name);
                      if (success) {
                        await Future.delayed(const Duration(milliseconds: 300));
                        Get.toNamed('/checkout');
                      }
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 8, left: 4, right: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text('Buy Now', style: AppTextStyles.bold.copyWith(color: AppColors.white, fontSize: 13)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildShimmer();
        }
        final product = controller.product.value;
        if (product == null) {
          return const Center(child: Text('Product not found'));
        }

        final images = (product.images != null && product.images!.isNotEmpty) 
            ? product.images! 
            : [product.image];

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SECTION 1: IMAGE SLIDER ---
              Container(
                color: AppColors.white,
                child: Column(
                  children: [
                    Stack(
                      children: [
                        SizedBox(
                          height: 380,
                          width: double.infinity,
                          child: PageView.builder(
                            itemCount: images.length,
                            onPageChanged: (index) => controller.selectedImageIndex.value = index,
                            itemBuilder: (context, index) {
                              return Obx(() => AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Image.network(
                                  images[controller.selectedImageIndex.value],
                                  key: ValueKey<int>(controller.selectedImageIndex.value),
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, size: 40, color: Colors.grey)),
                                ),
                              ));
                            },
                          ),
                        ),
                        if (images.length > 1)
                          Positioned(
                            bottom: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
                              child: Obx(() => Text(
                                '${controller.selectedImageIndex.value + 1}/${images.length}',
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              )),
                            ),
                          ),
                      ],
                    ),
                    if (images.length > 1)
                      Container(
                        height: 60,
                        margin: const EdgeInsets.only(top: 8, bottom: 12),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: images.length,
                          itemBuilder: (context, index) {
                            return Obx(() {
                              final isSelected = controller.selectedImageIndex.value == index;
                              return GestureDetector(
                                onTap: () => controller.selectedImageIndex.value = index,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.only(right: 10),
                                  width: 60,
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected ? AppColors.primaryPurple : Colors.grey.shade300,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.network(
                                      images[index],
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 16, color: Colors.grey),
                                    ),
                                  ),
                                ),
                              );
                            });
                          },
                        ),
                      ),
                  ],
                ),
              ),

              // --- SECTION 2: PRICE & TITLE ---
              Container(
                width: double.infinity,
                color: AppColors.white,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${product.priceCurrency} ${product.price.toStringAsFixed(0)}',
                          style: const TextStyle(color: AppColors.primaryPurple, fontSize: 24, fontWeight: FontWeight.w900),
                        ),
                        if (product.discountPriceOrg != null && product.discountPriceOrg! > product.price) ...[
                          const SizedBox(width: 8),
                          Text(
                            '${product.priceCurrency} ${product.discountPriceOrg!.toStringAsFixed(0)}',
                            style: const TextStyle(color: Colors.grey, fontSize: 14, decoration: TextDecoration.lineThrough),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.primaryPurple.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                            child: Text(
                              '-${(((product.discountPriceOrg! - product.price) / product.discountPriceOrg!) * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(color: AppColors.primaryPurple, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      product.name,
                      style: AppTextStyles.extraBold.copyWith(fontSize: 16, height: 1.3, color: AppColors.darkText),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${product.rating} / 5',
                          style: AppTextStyles.bold.copyWith(color: AppColors.darkText, fontSize: 13),
                        ),
                        const SizedBox(width: 16),
                        Container(width: 1, height: 12, color: Colors.grey),
                        const SizedBox(width: 16),
                        Text(
                          '${product.stock > 0 ? "In Stock" : "Out of Stock"} (${product.stock})',
                          style: AppTextStyles.medium.copyWith(color: product.stock > 0 ? Colors.green : AppColors.error, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // --- SECTION 3: DELIVERY & SERVICES ---
              Container(
                width: double.infinity,
                color: AppColors.white,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.local_shipping_outlined, color: Colors.grey, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Standard Delivery', style: AppTextStyles.bold.copyWith(fontSize: 14, color: AppColors.darkText)),
                              const SizedBox(height: 2),
                              Text('Get by 3-5 days', style: AppTextStyles.medium.copyWith(fontSize: 12, color: AppColors.hintText)),
                            ],
                          ),
                        ),
                        Text('Rs 150', style: AppTextStyles.bold.copyWith(fontSize: 14, color: AppColors.darkText)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.security, color: Colors.grey, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('100% Authentic', style: AppTextStyles.bold.copyWith(fontSize: 14, color: AppColors.darkText)),
                              const SizedBox(height: 2),
                              Text('14 days easy return', style: AppTextStyles.medium.copyWith(fontSize: 12, color: AppColors.hintText)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // --- SECTION 4: STORE INFO ---
              GestureDetector(
                onTap: () {
                  if (product.storeId != null && product.storeId!.isNotEmpty) {
                    Get.toNamed('/store', arguments: product.storeId);
                  }
                },
                child: Container(
                  width: double.infinity,
                  color: AppColors.white,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade100,
                          border: Border.all(color: Colors.grey.shade300),
                          image: product.storeLogo != null 
                            ? DecorationImage(image: NetworkImage(product.storeLogo!), fit: BoxFit.cover) 
                            : null,
                        ),
                        child: product.storeLogo == null ? const Icon(Icons.store, color: AppColors.primaryPurple, size: 24) : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.storeName ?? (product.brand.isNotEmpty ? product.brand : 'Verified Store'), style: AppTextStyles.extraBold.copyWith(fontSize: 15, color: AppColors.darkText)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text('98% Positive Feedback', style: AppTextStyles.medium.copyWith(color: AppColors.hintText, fontSize: 11)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primaryPurple),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('Visit Store', style: AppTextStyles.bold.copyWith(color: AppColors.primaryPurple, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ),

              // --- SECTION 5: DESCRIPTION ---
              Container(
                width: double.infinity,
                color: AppColors.white,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Product Description', style: AppTextStyles.extraBold.copyWith(fontSize: 15, color: AppColors.darkText)),
                    const SizedBox(height: 12),
                    Text(
                      product.description ?? 'No detailed description available for this product.',
                      style: AppTextStyles.regular.copyWith(
                        color: AppColors.darkText.withValues(alpha: 0.8),
                        height: 1.6,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // --- SECTION 6: REVIEWS ---
              Obx(() {
                if (controller.reviews.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Container(
                  width: double.infinity,
                  color: AppColors.white,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Product Reviews (${controller.reviews.length})', style: AppTextStyles.extraBold.copyWith(fontSize: 15, color: AppColors.darkText)),
                      const SizedBox(height: 16),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.reviews.length > 5 ? 5 : controller.reviews.length, // Show up to 5
                        separatorBuilder: (context, index) => const Divider(height: 32),
                        itemBuilder: (context, index) {
                          final review = controller.reviews[index];
                          final rating = review['rating'] ?? 5;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.grey.shade200,
                                    child: Icon(Icons.person, size: 20, color: Colors.grey.shade500),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          review['user']?['fullName'] ?? review['userName'] ?? 'User',
                                          style: AppTextStyles.bold.copyWith(fontSize: 13),
                                        ),
                                        Row(
                                          children: List.generate(5, (starIndex) {
                                            return Icon(
                                              starIndex < rating ? Icons.star : Icons.star_border,
                                              size: 14,
                                              color: Colors.amber,
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (review['title'] != null && review['title'].toString().isNotEmpty) ...[
                                Text(
                                  review['title'],
                                  style: AppTextStyles.bold.copyWith(fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                              ],
                              Text(
                                review['body'] ?? '',
                                style: AppTextStyles.regular.copyWith(fontSize: 13, color: AppColors.darkText.withValues(alpha: 0.8)),
                              ),
                              if (review['images'] != null && (review['images'] as List).isNotEmpty) ...[
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 80,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: (review['images'] as List).length,
                                    separatorBuilder: (context, idx) => const SizedBox(width: 8),
                                    itemBuilder: (context, idx) {
                                      final imgUrl = review['images'][idx];
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          imgUrl,
                                          height: 80,
                                          width: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            height: 80,
                                            width: 80,
                                            color: Colors.grey.shade200,
                                            child: const Icon(Icons.broken_image),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildShimmer() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 400,
              width: double.infinity,
              color: Colors.white,
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Price placeholder
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    height: 24,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Title placeholder
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    height: 20,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    height: 20,
                    width: 250,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Rating/Sold placeholder
                Row(
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(height: 16, width: 80, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(height: 16, width: 80, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Divider
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(height: 1, width: double.infinity, color: Colors.white),
                ),
                const SizedBox(height: 24),
                
                // Section Title (Description)
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(height: 18, width: 100, color: Colors.white),
                ),
                const SizedBox(height: 12),
                
                // Description lines
                for (int i = 0; i < 4; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(height: 14, width: i == 3 ? 200 : double.infinity, color: Colors.white),
                    ),
                  ),
                  
                const SizedBox(height: 24),
                
                // Store Profile Block Shimmer
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    height: 80,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
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
}
