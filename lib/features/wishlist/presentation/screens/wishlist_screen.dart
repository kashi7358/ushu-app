import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../home/presentation/widgets/product_card.dart';
import '../controllers/wishlist_controller.dart';
import '../../../main_layout/presentation/controllers/main_layout_controller.dart';
import '../../../../core/widgets/app_button.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WishlistController>();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('My Wishlist', style: AppTextStyles.bold.copyWith(color: AppColors.darkText, fontSize: 18)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryPurple));
        }

        if (controller.wishlistProducts.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          color: AppColors.primaryPurple.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: AppColors.primaryPurple.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const Icon(Icons.favorite_rounded, size: 48, color: AppColors.primaryPurple),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Your wishlist is empty',
                    style: AppTextStyles.extraBold.copyWith(fontSize: 22, color: AppColors.darkText),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Save items you love here and buy them later when you are ready.',
                    style: AppTextStyles.medium.copyWith(color: AppColors.hintText, fontSize: 14, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      text: 'Start Shopping',
                      onPressed: () {
                        if (Get.isRegistered<MainLayoutController>()) {
                          Get.find<MainLayoutController>().changePage(0);
                        }
                        Get.offAllNamed('/main');
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.58,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: controller.wishlistProducts.length,
          itemBuilder: (context, index) {
            final product = controller.wishlistProducts[index];
            return ProductCard(product: product);
          },
        );
      }),
    );
  }
}
