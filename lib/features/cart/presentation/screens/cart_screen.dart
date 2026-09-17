import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../controllers/cart_controller.dart';
import '../../data/models/cart_item_model.dart';
import '../../../../core/widgets/app_button.dart';

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
        if (controller.isLoadingCart.value) {
          return const Center(child: CircularProgressIndicator());
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
                      // Navigate to home or change tab
                    },
                  ),
                )
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
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      onDismissed: (direction) {
        controller.removeFromCart(item.id);
      },
      child: Container(
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
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.medium.copyWith(fontSize: 14, color: AppColors.darkText, height: 1.2),
                  ),
                  const SizedBox(height: 12),
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
      ),
    );
  }

  Widget _buildBottomSummary(CartController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              // Select All (Optional visual fake for now, or you can implement logic)
              const SizedBox(width: 8),
              Checkbox(
                value: controller.cartItems.isNotEmpty && controller.cartItems.every((item) => item.isSelected),
                onChanged: (val) {
                  // Implement select all if needed
                },
                activeColor: AppColors.primaryPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              Text('All', style: AppTextStyles.medium.copyWith(fontSize: 14)),
              const Spacer(),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Total', style: AppTextStyles.regular.copyWith(fontSize: 12, color: AppColors.hintText)),
                  Text(
                    'Rs. ${controller.subtotal}',
                    style: AppTextStyles.bold.copyWith(fontSize: 16, color: AppColors.primaryPurple),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 60,
                width: 120,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple, // Or orange like Daraz
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    elevation: 0,
                  ),
                  onPressed: () {},
                  child: Text(
                    'Check Out',
                    style: AppTextStyles.bold.copyWith(color: Colors.white, fontSize: 14),
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
