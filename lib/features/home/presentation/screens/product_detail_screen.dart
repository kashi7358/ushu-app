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
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share_plus/share_plus.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  void _showShareOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Share via',
                  style: AppTextStyles.bold.copyWith(fontSize: 18, color: AppColors.darkText),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildShareIcon(
                      assetPath: 'assets/images/whatsapp.svg',
                      color: const Color(0xFF25D366),
                      label: 'WhatsApp',
                      onTap: () {
                        Get.back();
                        final product = Get.find<ProductDetailController>().product.value;
                        final shareText = 'Check out ${product?.name ?? 'this product'} on Ushu!';
                        Share.share(shareText);
                      },
                    ),
                    _buildShareIcon(
                      assetPath: 'assets/images/facebook.svg',
                      color: const Color(0xFF1877F2),
                      label: 'Facebook',
                      onTap: () {
                        Get.back();
                        final product = Get.find<ProductDetailController>().product.value;
                        final shareText = 'Check out ${product?.name ?? 'this product'} on Ushu!';
                        Share.share(shareText);
                      },
                    ),
                    _buildShareIcon(
                      assetPath: 'assets/images/instagram.svg',
                      color: const Color(0xFFE4405F),
                      label: 'Instagram',
                      onTap: () {
                        Get.back();
                        final product = Get.find<ProductDetailController>().product.value;
                        final shareText = 'Check out ${product?.name ?? 'this product'} on Ushu!';
                        Share.share(shareText);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShareIcon({
    required String assetPath,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: SizedBox(
              width: 30,
              height: 30,
              child: SvgPicture.asset(
                assetPath,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.medium.copyWith(fontSize: 12, color: AppColors.darkText),
          ),
        ],
      ),
    );
  }

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
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), shape: BoxShape.circle),
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
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), shape: BoxShape.circle),
            child: IconButton(
              icon: const Icon(Icons.share, color: AppColors.white, size: 20),
              onPressed: () {
                _showShareOptions(context);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 65,
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
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
                              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(12)),
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
                            decoration: BoxDecoration(color: AppColors.primaryPurple.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
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

              // --- SECTION 6: DARAZ-STYLE RATINGS & REVIEWS ---
              Obx(() {
                final reviewsList = controller.reviews;
                final product = controller.product.value;
                
                // Compute real rating average from reviewsList if available
                double displayRating = product?.rating ?? 0.0;
                if (reviewsList.isNotEmpty) {
                  double totalRatingSum = 0;
                  int validReviewsCount = 0;
                  for (var r in reviewsList) {
                    final rVal = (r['rating'] is num)
                        ? (r['rating'] as num).toDouble()
                        : double.tryParse(r['rating']?.toString() ?? '');
                    if (rVal != null && rVal > 0) {
                      totalRatingSum += rVal;
                      validReviewsCount++;
                    }
                  }
                  if (validReviewsCount > 0) {
                    displayRating = totalRatingSum / validReviewsCount;
                  }
                }

                return Container(
                  width: double.infinity,
                  color: AppColors.white,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Ratings & Reviews (${reviewsList.length})',
                            style: AppTextStyles.extraBold.copyWith(fontSize: 16, color: AppColors.darkText),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Rating Breakdown Summary Box (Daraz Style)
                      if (product != null || reviewsList.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        displayRating.toStringAsFixed(1),
                                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.darkText),
                                      ),
                                      const Text(
                                        '/5',
                                        style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: List.generate(5, (index) {
                                      return Icon(
                                        index < displayRating.floor()
                                            ? Icons.star
                                            : (index < displayRating ? Icons.star_half : Icons.star_border),
                                        size: 18,
                                        color: Colors.amber,
                                      );
                                    }),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${reviewsList.length} Ratings & Reviews',
                                    style: AppTextStyles.medium.copyWith(fontSize: 12, color: AppColors.hintText),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 20),

                      // Empty state or Reviews list
                      if (reviewsList.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Column(
                              children: [
                                Icon(Icons.rate_review_outlined, size: 48, color: Colors.grey.shade300),
                                const SizedBox(height: 8),
                                Text(
                                  'No reviews yet for this product',
                                  style: AppTextStyles.medium.copyWith(color: Colors.grey.shade600, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: reviewsList.length > 5 ? 5 : reviewsList.length,
                          separatorBuilder: (context, index) => const Divider(height: 28),
                          itemBuilder: (context, index) {
                            final review = reviewsList[index];
                            final String reviewId = review['_id']?.toString() ?? review['id']?.toString() ?? '';
                            final int rating = (review['rating'] is num)
                                ? (review['rating'] as num).toInt()
                                : int.tryParse(review['rating']?.toString() ?? '') ?? 5;

                            String userName = '';

                            // Check all possible top-level name fields first
                            if (review['fullName'] != null && review['fullName'].toString().trim().isNotEmpty) {
                              userName = review['fullName'].toString().trim();
                            } else if (review['userName'] != null && review['userName'].toString().trim().isNotEmpty) {
                              userName = review['userName'].toString().trim();
                            } else if (review['user_name'] != null && review['user_name'].toString().trim().isNotEmpty) {
                              userName = review['user_name'].toString().trim();
                            } else if (review['username'] != null && review['username'].toString().trim().isNotEmpty) {
                              userName = review['username'].toString().trim();
                            } else if (review['buyerName'] != null && review['buyerName'].toString().trim().isNotEmpty) {
                              userName = review['buyerName'].toString().trim();
                            } else if (review['customerName'] != null && review['customerName'].toString().trim().isNotEmpty) {
                              userName = review['customerName'].toString().trim();
                            } else if (review['name'] != null && review['name'].toString().trim().isNotEmpty) {
                              userName = review['name'].toString().trim();
                            }

                            // Check nested object fields: user, buyer, customer
                            if (userName.isEmpty && review['user'] != null) {
                              if (review['user'] is Map) {
                                final uMap = review['user'] as Map;
                                userName = uMap['fullName']?.toString() ??
                                    uMap['name']?.toString() ??
                                    uMap['username']?.toString() ??
                                    uMap['user_name']?.toString() ??
                                    uMap['firstName']?.toString() ??
                                    '';
                              }
                            }

                            if (userName.isEmpty && review['buyer'] is Map) {
                              final bMap = review['buyer'] as Map;
                              userName = bMap['fullName']?.toString() ?? bMap['name']?.toString() ?? '';
                            }

                            if (userName.isEmpty && review['customer'] is Map) {
                              final cMap = review['customer'] as Map;
                              userName = cMap['fullName']?.toString() ?? cMap['name']?.toString() ?? '';
                            }

                            // If name is an ObjectId (24 hex characters) or empty, fall back to SessionManager.fullName or 'Customer'
                            if (userName.isEmpty || RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(userName)) {
                              userName = SessionManager.fullName ?? 'Customer';
                            }

                            final String dateStr = _formatDate(review['createdAt'] ?? review['date']);
                            
                            // Extract vote counts
                            int upvotes = 0;
                            if (review['helpfulVotes'] is num) {
                              upvotes = (review['helpfulVotes'] as num).toInt();
                            } else if (review['helpfull votes'] is num) {
                              upvotes = (review['helpfull votes'] as num).toInt();
                            } else if (review['upvotes'] is num) {
                              upvotes = (review['upvotes'] as num).toInt();
                            } else if (review['helpful'] is num) {
                              upvotes = (review['helpful'] as num).toInt();
                            } else if (review['likes'] is num) {
                              upvotes = (review['likes'] as num).toInt();
                            } else if (review['votes'] is Map && (review['votes']['up'] is num || review['votes']['helpful'] is num)) {
                              upvotes = ((review['votes']['up'] ?? review['votes']['helpful']) as num).toInt();
                            }

                            int downvotes = 0;
                            if (review['unhelpfulVotes'] is num) {
                              downvotes = (review['unhelpfulVotes'] as num).toInt();
                            } else if (review['unhelpfullVote'] is num) {
                              downvotes = (review['unhelpfullVote'] as num).toInt();
                            } else if (review['downvotes'] is num) {
                              downvotes = (review['downvotes'] as num).toInt();
                            } else if (review['unhelpful'] is num) {
                              downvotes = (review['unhelpful'] as num).toInt();
                            } else if (review['dislikes'] is num) {
                              downvotes = (review['dislikes'] as num).toInt();
                            } else if (review['votes'] is Map && (review['votes']['down'] is num || review['votes']['unhelpful'] is num)) {
                              downvotes = ((review['votes']['down'] ?? review['votes']['unhelpful']) as num).toInt();
                            }

                            final rawImages = review['images'];
                            final List<String> imageUrls = [];
                            if (rawImages is List) {
                              for (var img in rawImages) {
                                if (img is String && img.trim().isNotEmpty) {
                                  imageUrls.add(img.trim());
                                } else if (img is Map) {
                                  final url = img['url']?.toString() ?? img['src']?.toString() ?? img['path']?.toString() ?? '';
                                  if (url.isNotEmpty) {
                                    imageUrls.add(url);
                                  }
                                }
                              }
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top row: Avatar + Name + Verified Purchase + Date
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: AppColors.primaryPurple.withValues(alpha: 0.1),
                                      child: Text(
                                        userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                                        style: const TextStyle(color: AppColors.primaryPurple, fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  userName,
                                                  style: AppTextStyles.bold.copyWith(fontSize: 13, color: AppColors.darkText),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.green.shade50,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.check_circle, size: 11, color: Colors.green.shade700),
                                                    const SizedBox(width: 3),
                                                    Text(
                                                      'Verified Purchase',
                                                      style: TextStyle(fontSize: 10, color: Colors.green.shade700, fontWeight: FontWeight.w600),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Row(
                                                children: List.generate(5, (starIndex) {
                                                  return Icon(
                                                    starIndex < rating ? Icons.star : Icons.star_border,
                                                    size: 13,
                                                    color: Colors.amber,
                                                  );
                                                }),
                                              ),
                                              if (dateStr.isNotEmpty) ...[
                                                const SizedBox(width: 8),
                                                Text(
                                                  dateStr,
                                                  style: AppTextStyles.medium.copyWith(fontSize: 11, color: AppColors.hintText),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                // Review Title & Body
                                if (review['title'] != null && review['title'].toString().trim().isNotEmpty) ...[
                                  Text(
                                    review['title'].toString().trim(),
                                    style: AppTextStyles.bold.copyWith(fontSize: 14, color: AppColors.darkText),
                                  ),
                                  const SizedBox(height: 4),
                                ],
                                Text(
                                  review['body']?.toString() ?? review['comment']?.toString() ?? review['review']?.toString() ?? '',
                                  style: AppTextStyles.regular.copyWith(fontSize: 13, color: AppColors.darkText.withValues(alpha: 0.9), height: 1.4),
                                ),

                                // Attached Images
                                if (imageUrls.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    height: 70,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: imageUrls.length,
                                      separatorBuilder: (context, idx) => const SizedBox(width: 8),
                                      itemBuilder: (context, idx) {
                                        final imgUrl = imageUrls[idx];
                                        return GestureDetector(
                                          onTap: () => _showFullImage(context, imgUrl),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              imgUrl,
                                              height: 70,
                                              width: 70,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Container(
                                                height: 70,
                                                width: 70,
                                                color: Colors.grey.shade200,
                                                child: const Icon(Icons.broken_image, size: 20),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 12),

                                // --- VOTE FOR REVIEW ROW (STRICTLY SINGLE ROW USING FITTEDBOX) ---
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerRight,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Was this review helpful?',
                                          style: AppTextStyles.medium.copyWith(fontSize: 11, color: AppColors.hintText),
                                        ),
                                        const SizedBox(width: 8),
                                        
                                        // 👍 Good / Helpful Button
                                        InkWell(
                                          borderRadius: BorderRadius.circular(16),
                                          onTap: () async {
                                            if (reviewId.isNotEmpty) {
                                              await controller.voteReview(reviewId, 'helpful', reviewIndex: index);
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade100,
                                              borderRadius: BorderRadius.circular(16),
                                              border: Border.all(color: Colors.grey.shade300),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.thumb_up_alt_outlined, size: 13, color: Colors.green),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Good ($upvotes)',
                                                  style: AppTextStyles.bold.copyWith(fontSize: 11, color: AppColors.darkText),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),

                                        // 👎 Not Good / Unhelpful Button
                                        InkWell(
                                          borderRadius: BorderRadius.circular(16),
                                          onTap: () async {
                                            if (reviewId.isNotEmpty) {
                                              await controller.voteReview(reviewId, 'unhelpful', reviewIndex: index);
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade100,
                                              borderRadius: BorderRadius.circular(16),
                                              border: Border.all(color: Colors.grey.shade300),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.thumb_down_alt_outlined, size: 13, color: Colors.red),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Not Good ($downvotes)',
                                                  style: AppTextStyles.bold.copyWith(fontSize: 11, color: AppColors.darkText),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
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

  void _showFullImage(BuildContext context, String imageUrl) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50, color: Colors.white),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic dateRaw) {
    if (dateRaw == null) return '';
    try {
      final dt = DateTime.parse(dateRaw.toString());
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return dateRaw.toString();
    }
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
