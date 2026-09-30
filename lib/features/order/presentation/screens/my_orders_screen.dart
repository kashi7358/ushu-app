import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../controllers/order_controller.dart';
import '../../../../core/widgets/no_internet_widget.dart';
import '../../../../core/utils/session_manager.dart';
import '../../data/models/order_model.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrderController());

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          'My Orders',
          style: AppTextStyles.bold.copyWith(color: AppColors.darkText, fontSize: 18),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isNoInternet.value && controller.orders.isEmpty) {
          return NoInternetWidget(onRetry: controller.fetchMyOrders);
        }
        if (controller.isLoading.value && controller.orders.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryPurple));
        }

        return RefreshIndicator(
          onRefresh: controller.fetchMyOrders,
          color: AppColors.primaryPurple,
          child: Column(
            children: [
              // Top Status Tabs (Daraz Style)
              Container(
                color: Colors.white,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        _buildTabItem(controller, 'all', 'All', controller.orders.length),
                        const SizedBox(width: 8),
                        _buildTabItem(controller, 'active', 'Active', controller.activeOrdersCount),
                        const SizedBox(width: 8),
                        _buildTabItem(controller, 'completed', 'Completed', controller.completedOrdersCount),
                        const SizedBox(width: 8),
                        _buildTabItem(controller, 'cancelled', 'Cancelled', controller.cancelledOrdersCount),
                      ],
                    ),
                  ),
                ),
              ),
              const Divider(height: 1, color: Colors.grey),

              // Orders List
              Expanded(
                child: controller.filteredOrders.isEmpty
                    ? _buildEmptyState(context, controller)
                    : ListView.separated(
                        padding: const EdgeInsets.all(12),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: controller.filteredOrders.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final order = controller.filteredOrders[index];
                          return _buildOrderCard(context, controller, order);
                        },
                      ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTabItem(OrderController controller, String key, String label, int count) {
    final isSelected = controller.selectedTab.value.toLowerCase() == key.toLowerCase();
    return GestureDetector(
      onTap: () {
        controller.selectedTab.value = key;
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            child: Row(
              children: [
                Text(
                  label,
                  style: isSelected
                      ? AppTextStyles.bold.copyWith(fontSize: 14, color: AppColors.primaryPurple)
                      : AppTextStyles.medium.copyWith(fontSize: 14, color: AppColors.hintText),
                ),
                if (count > 0) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryPurple : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppColors.darkText,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            height: 2.5,
            width: 36,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryPurple : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, OrderController controller) {
    String message = 'Looks like you haven\'t placed any orders yet. Start shopping now!';
    if (controller.selectedTab.value.toLowerCase() == 'active') {
      message = 'No active orders right now.';
    } else if (controller.selectedTab.value.toLowerCase() == 'completed') {
      message = 'No completed orders yet.';
    } else if (controller.selectedTab.value.toLowerCase() == 'cancelled') {
      message = 'No cancelled orders.';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.receipt_long_outlined, size: 56, color: AppColors.primaryPurple),
            ),
            const SizedBox(height: 20),
            Text(
              'No orders found',
              style: AppTextStyles.bold.copyWith(fontSize: 18, color: AppColors.darkText),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.medium.copyWith(color: AppColors.hintText, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'Start Shopping',
              onPressed: () {
                Get.offAllNamed('/main');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderController controller, OrderModel order) {
    final statusColor = _getStatusColor(order.status);
    final int totalItemCount = order.items.fold(0, (sum, item) => sum + item.quantity);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.storefront_outlined, size: 18, color: AppColors.darkText),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Order #${order.id.length >= 8 ? order.id.substring(0, 8).toUpperCase() : (order.id.isNotEmpty ? order.id.toUpperCase() : 'N/A')}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bold.copyWith(fontSize: 13, color: AppColors.darkText),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  order.status.replaceAll('_', ' ').replaceAll('-', ' ').toUpperCase(),
                  style: AppTextStyles.bold.copyWith(fontSize: 12, color: statusColor),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Items List
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                if (order.items.isEmpty)
                  Text(
                    'No item details available',
                    style: AppTextStyles.medium.copyWith(fontSize: 12, color: AppColors.hintText),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: order.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, itemIdx) {
                      final item = order.items[itemIdx];
                      final double displayTotal = item.total > 0 ? item.total : (item.price * item.quantity);
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: item.image.isNotEmpty
                                  ? Image.network(
                                      item.image,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, color: Colors.grey, size: 18),
                                    )
                                  : const Icon(Icons.shopping_bag_outlined, color: AppColors.primaryPurple, size: 20),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productName,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.medium.copyWith(fontSize: 13, color: AppColors.darkText),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Qty: ${item.quantity}',
                                      style: AppTextStyles.medium.copyWith(fontSize: 12, color: AppColors.hintText),
                                    ),
                                    Text(
                                      'Rs. ${displayTotal.toStringAsFixed(0)}',
                                      style: AppTextStyles.bold.copyWith(fontSize: 13, color: AppColors.darkText),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Total & Actions Footer (Daraz Style)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _formatDate(order.createdAt),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.medium.copyWith(fontSize: 11, color: AppColors.hintText),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: RichText(
                        text: TextSpan(
                          text: 'Total (${totalItemCount > 0 ? totalItemCount : order.items.length} ${totalItemCount == 1 ? 'item' : 'items'}): ',
                          style: AppTextStyles.medium.copyWith(fontSize: 12, color: AppColors.darkText),
                          children: [
                            TextSpan(
                              text: 'Rs. ${order.totalAmount.toStringAsFixed(0)}',
                              style: AppTextStyles.bold.copyWith(fontSize: 14, color: AppColors.primaryPurple),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                if (order.status.toLowerCase() == 'pending') ...[
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      height: 34,
                      child: OutlinedButton(
                        onPressed: () {
                          _showCancelConfirmation(context, controller, order.id);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: Text(
                          'Cancel Order',
                          style: AppTextStyles.bold.copyWith(fontSize: 12, color: AppColors.error),
                        ),
                      ),
                    ),
                  ),
                ],

                if ((order.status.toLowerCase() == 'delivered' || order.status.toLowerCase() == 'completed') &&
                    order.items.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Builder(
                    builder: (context) {
                      final bool alreadyReviewed = order.isReviewed || SessionManager.isReviewed(order.id, order.items[0].productId);
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (order.canReturn) ...[
                            SizedBox(
                              height: 34,
                              child: OutlinedButton(
                                onPressed: () {
                                  Get.toNamed('/return-request', arguments: {
                                    'orderId': order.id,
                                    'orderItemId': order.items[0].id,
                                    'quantity': order.items[0].quantity,
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primaryPurple,
                                  side: const BorderSide(color: AppColors.primaryPurple),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                ),
                                child: Text(
                                  'Return Item',
                                  style: AppTextStyles.bold.copyWith(fontSize: 12, color: AppColors.primaryPurple),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (!alreadyReviewed) ...[
                            SizedBox(
                              height: 34,
                              child: ElevatedButton(
                                onPressed: () async {
                                  final res = await Get.toNamed('/write-review', arguments: {
                                    'productId': order.items[0].productId,
                                    'orderId': order.id,
                                  });
                                  if (res == true || SessionManager.isReviewed(order.id, order.items[0].productId)) {
                                    controller.fetchMyOrders();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryPurple,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                ),
                                child: Text(
                                  'Write Review',
                                  style: AppTextStyles.bold.copyWith(fontSize: 12, color: Colors.white),
                                ),
                              ),
                            ),
                          ] else ...[
                            SizedBox(
                              height: 34,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Get.toNamed('/product-detail', arguments: order.items[0].productId);
                                },
                                icon: const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                                label: Text(
                                  'View Review',
                                  style: AppTextStyles.bold.copyWith(fontSize: 12, color: AppColors.darkText),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.darkText,
                                  side: BorderSide(color: Colors.grey.shade300),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                ),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    final s = status.toLowerCase().replaceAll('_', ' ').replaceAll('-', ' ').trim();
    switch (s) {
      case 'pending':
        return Colors.orange.shade800;
      case 'confirmed':
      case 'processing':
      case 'picked':
      case 'picking':
      case 'packed':
        return Colors.amber.shade900;
      case 'shipped':
      case 'shipping':
      case 'in transit':
      case 'out for delivery':
      case 'active':
        return Colors.blue.shade700;
      case 'delivered':
      case 'completed':
        return Colors.green.shade700;
      case 'cancelled':
      case 'canceled':
      case 'returned':
      case 'refunded':
        return Colors.red.shade700;
      default:
        return AppColors.primaryPurple;
    }
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final month = months[date.month - 1];
      final day = date.day.toString().padLeft(2, '0');
      final year = date.year;
      int hour = date.hour;
      final minute = date.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      if (hour == 0) {
        hour = 12;
      } else if (hour > 12) {
        hour -= 12;
      }
      return '$day $month $year, $hour:$minute $period';
    } catch (e) {
      return dateStr;
    }
  }

  void _showCancelConfirmation(BuildContext context, OrderController controller, String orderId) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded, size: 40, color: AppColors.error),
              ),
              const SizedBox(height: 16),
              Text('Cancel Order?', style: AppTextStyles.bold.copyWith(fontSize: 18, color: AppColors.darkText)),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to cancel this order? This action cannot be undone.',
                textAlign: TextAlign.center,
                style: AppTextStyles.medium.copyWith(fontSize: 13, color: AppColors.hintText),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'No, Keep it',
                          maxLines: 1,
                          style: AppTextStyles.bold.copyWith(fontSize: 13, color: AppColors.darkText),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        controller.cancelOrder(orderId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Yes, Cancel',
                          maxLines: 1,
                          style: AppTextStyles.bold.copyWith(fontSize: 13, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
