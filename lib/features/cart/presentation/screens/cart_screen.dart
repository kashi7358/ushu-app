import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../controllers/cart_controller.dart';
import '../../data/models/cart_item_model.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/utils/custom_popup.dart';
import '../../../../core/widgets/no_internet_widget.dart';
import '../../../main_layout/presentation/controllers/main_layout_controller.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Put controller so it's available
    final controller = Get.put(CartController());

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'My Cart',
          style: AppTextStyles.bold.copyWith(color: AppColors.darkText, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isNoInternet.value && controller.cartItems.isEmpty) {
          return NoInternetWidget(onRetry: controller.fetchCart);
        }
        if (controller.isLoadingCart.value && controller.cartItems.isEmpty) {
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 4,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                );
              },
            ),
          );
        }

        if (controller.cartItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  'Your cart is empty',
                  style: AppTextStyles.bold.copyWith(fontSize: 18, color: AppColors.darkText),
                ),
                const SizedBox(height: 8),
                Text(
                  'Looks like you haven\'t added\nanything to your cart yet',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.regular.copyWith(color: AppColors.hintText),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: 200,
                  child: AppButton(
                    text: 'Start Shopping',
                    onPressed: () {
                      if (Get.isRegistered<MainLayoutController>()) {
                        Get.find<MainLayoutController>().changePage(0);
                      } else {
                        Get.offAllNamed('/main');
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: controller.cartItems.length,
                separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                itemBuilder: (context, index) {
                  final item = controller.cartItems[index];
                  return _buildCartItem(item, controller);
                },
              ),
            ),
            _buildBottomSummary(controller),
          ],
        );
      }),
    );
  }

  Widget _buildCartItem(CartItemModel item, CartController controller) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Simple Checkbox
          Checkbox(
            value: item.isSelected,
            onChanged: (val) => controller.selectCartItem(item.id),
            activeColor: AppColors.primaryPurple,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          // Product Image
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(4),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                item.image,
                width: 75,
                height: 75,
                cacheWidth: 150,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 75,
                  height: 75,
                  color: Colors.grey.shade100,
                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.medium.copyWith(fontSize: 14, color: AppColors.darkText, height: 1.2),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'In Stock: ${item.stock}',
                            style: AppTextStyles.medium.copyWith(fontSize: 11, color: AppColors.success),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => controller.removeFromCart(item.id),
                      child: const Padding(
                        padding: EdgeInsets.only(left: 8, bottom: 8),
                        child: Icon(Icons.delete_outline, color: Colors.black54, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rs. ${item.price}',
                        style: AppTextStyles.bold.copyWith(fontSize: 16, color: AppColors.primaryPurple),
                      ),
                      // Simple Quantity Control (Daraz style)
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () {
                                if (item.quantity > 1) {
                                  controller.updateQuantity(item.id, item.quantity - 1);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                color: Colors.grey.shade100,
                                child: const Icon(Icons.remove, size: 16, color: Colors.black54),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                '${item.quantity}',
                                style: AppTextStyles.medium.copyWith(fontSize: 14),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                controller.updateQuantity(item.id, item.quantity + 1);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                color: Colors.grey.shade100,
                                child: const Icon(Icons.add, size: 16, color: Colors.black54),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),

    );
  }

  Widget _buildBottomSummary(CartController controller) {
    int selectedCount = controller.cartItems.where((item) => item.isSelected).length;
    bool isAllSelected = controller.cartItems.isNotEmpty && selectedCount == controller.cartItems.length;

    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20, top: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primaryPurple,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Side: Select All Checkbox + Texts
              GestureDetector(
                onTap: controller.toggleSelectAll,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    // Checkbox
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isAllSelected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: isAllSelected
                          ? Icon(Icons.check, color: AppColors.primaryPurple, size: 16)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$selectedCount Items Selected',
                          style: AppTextStyles.medium.copyWith(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Total: Rs. ${controller.subtotal}',
                          style: AppTextStyles.bold.copyWith(color: Colors.white, fontSize: 15),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Right Side: Checkout Button
              SizedBox(
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    if (controller.cartItems.where((item) => item.isSelected).isEmpty) {
                      CustomPopup.showToast('Error', 'Please select at least one item to checkout', isError: true);
                      return;
                    }
                    Get.toNamed('/checkout');
                  },
                  child: Text(
                    'Checkout',
                    style: AppTextStyles.bold.copyWith(fontSize: 14, color: AppColors.primaryPurple),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
