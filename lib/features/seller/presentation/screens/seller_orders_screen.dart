import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/models/seller_order_model.dart';
import '../controllers/seller_orders_controller.dart';

class SellerOrdersScreen extends StatelessWidget {
  const SellerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SellerOrdersController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.darkText, size: 20),
          onPressed: () => Get.back(),
        ),
        titleSpacing: 0,
        title: Obx(() => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                'Order Management',
                style: AppTextStyles.bold.copyWith(color: AppColors.darkText, fontSize: 17),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!controller.isLoading.value) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${controller.allCount}',
                  style: const TextStyle(
                    color: AppColors.primaryPurple,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        )),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.darkText, size: 21),
            onPressed: controller.fetchSellerOrders,
            tooltip: 'Refresh Orders',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: TextField(
              controller: controller.searchController,
              onChanged: controller.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search by Order ID, customer, or product...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13.5),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryPurple, size: 21),
                suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18, color: Colors.grey),
                        onPressed: () {
                          controller.searchController.clear();
                          controller.onSearchChanged('');
                        },
                      )
                    : const SizedBox.shrink()),
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Status Filter Tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Obx(() {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterTab(
                      label: 'All',
                      count: controller.allCount,
                      isSelected: controller.selectedTab.value == 'All',
                      onTap: () => controller.onTabChanged('All'),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterTab(
                      label: 'Pending',
                      count: controller.pendingCount,
                      isSelected: controller.selectedTab.value == 'Pending',
                      activeColor: Colors.orange.shade700,
                      onTap: () => controller.onTabChanged('Pending'),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterTab(
                      label: 'Processing',
                      count: controller.processingCount,
                      isSelected: controller.selectedTab.value == 'Processing',
                      activeColor: Colors.blue.shade600,
                      onTap: () => controller.onTabChanged('Processing'),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterTab(
                      label: 'Completed',
                      count: controller.completedCount,
                      isSelected: controller.selectedTab.value == 'Completed',
                      activeColor: Colors.green.shade600,
                      onTap: () => controller.onTabChanged('Completed'),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterTab(
                      label: 'Cancelled',
                      count: controller.cancelledCount,
                      isSelected: controller.selectedTab.value == 'Cancelled',
                      activeColor: Colors.red.shade600,
                      onTap: () => controller.onTabChanged('Cancelled'),
                    ),
                  ],
                ),
              );
            }),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

          // Main Content
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return _buildShimmer();
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 54, color: Colors.red),
                        const SizedBox(height: 14),
                        Text(
                          controller.errorMessage.value,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14, color: AppColors.darkText),
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton.icon(
                          onPressed: controller.fetchSellerOrders,
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Try Again'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (controller.allOrders.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.shopping_bag_outlined,
                            size: 58,
                            color: AppColors.primaryPurple,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'No Orders Yet',
                          style: AppTextStyles.bold.copyWith(fontSize: 18, color: AppColors.darkText),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Customer orders placed for your store products will appear here in real time.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13.5, color: AppColors.hintText),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (controller.filteredOrders.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.filter_list_off_rounded, size: 52, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text(
                          'No matching orders found',
                          style: AppTextStyles.bold.copyWith(fontSize: 16, color: AppColors.darkText),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                color: AppColors.primaryPurple,
                onRefresh: controller.fetchSellerOrders,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  itemCount: controller.filteredOrders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final order = controller.filteredOrders[index];
                    return _buildOrderCard(context, order, controller);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    SellerOrderModel order,
    SellerOrdersController controller,
  ) {
    Color statusBg;
    Color statusFg;

    if (order.isCompleted) {
      statusBg = Colors.green.shade50;
      statusFg = Colors.green.shade700;
    } else if (order.isCancelled) {
      statusBg = Colors.red.shade50;
      statusFg = Colors.red.shade700;
    } else if (order.isProcessing) {
      statusBg = Colors.blue.shade50;
      statusFg = Colors.blue.shade700;
    } else {
      statusBg = Colors.orange.shade50;
      statusFg = Colors.orange.shade800;
    }

    String formatDate(String raw) {
      if (raw.isEmpty) return 'Recent';
      final dt = DateTime.tryParse(raw)?.toLocal();
      if (dt == null) return raw;
      return '${dt.day}/${dt.month}/${dt.year} • ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }

    return InkWell(
      onTap: () => _showOrderDetailsSheet(context, order, controller),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Order Top Header (Order ID, Date & Status Badge)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: AppColors.primaryPurple,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.displayOrderId,
                          style: AppTextStyles.extraBold.copyWith(
                            fontSize: 14.5,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 1.5),
                        Text(
                          formatDate(order.createdAt),
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: statusFg,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: Color(0xFFF1F5F9)),

            // 2. Customer & Shipping Strip
            if (order.buyerName.isNotEmpty || order.shippingAddress.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                color: const Color(0xFFF8FAFC),
                child: Row(
                  children: [
                    const Icon(Icons.person_outline_rounded, size: 16, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        [
                          if (order.buyerName.isNotEmpty) order.buyerName,
                          if (order.buyerPhone.isNotEmpty) order.buyerPhone,
                          if (order.city.isNotEmpty) order.city,
                        ].join('  •  '),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        order.paymentMethod.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // 3. Ordered Products List
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
              child: Column(
                children: order.items.take(3).map((item) {
                  final matchedProd = controller.storeProductsMap[item.productId];
                  final prodName = (item.productName.isNotEmpty && item.productName != 'Product')
                      ? item.productName
                      : (matchedProd?.name ?? 'Product #${item.productId.length > 6 ? item.productId.substring(item.productId.length - 6) : item.productId}');
                  final prodImg = item.image.isNotEmpty
                      ? item.image
                      : (matchedProd?.primaryImage ?? '');

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 44,
                            height: 44,
                            color: const Color(0xFFF1F5F9),
                            child: prodImg.isNotEmpty
                                ? Image.network(
                                    prodImg,
                                    fit: BoxFit.cover,
                                    cacheWidth: 120,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.inventory_2_outlined,
                                      size: 18,
                                      color: Colors.grey,
                                    ),
                                  )
                                : const Icon(Icons.inventory_2_outlined, size: 18, color: Colors.grey),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                prodName,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E293B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                [
                                  'Qty: ${item.quantity}',
                                  if (item.price > 0) 'Rs. ${item.price.toStringAsFixed(0)}',
                                  if (item.variantLabel.isNotEmpty) item.variantLabel,
                                ].join('  •  '),
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (item.total > 0 || item.price > 0)
                          Text(
                            'Rs. ${(item.total > 0 ? item.total : item.price * item.quantity).toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            if (order.items.length > 3)
              Padding(
                padding: const EdgeInsets.only(left: 14, bottom: 8),
                child: Text(
                  '+ ${order.items.length - 3} more items',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryPurple,
                  ),
                ),
              ),

            const Divider(height: 1, color: Color(0xFFF1F5F9)),

            // 4. Footer Summary
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order.items.length} ${order.items.length == 1 ? 'Item' : 'Items'}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        'Total: ',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        'Rs. ${order.totalAmount.toStringAsFixed(0)}',
                        style: AppTextStyles.extraBold.copyWith(
                          fontSize: 15,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: Color(0xFF94A3B8),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderDetailsSheet(
    BuildContext context,
    SellerOrderModel order,
    SellerOrdersController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.92,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order ${order.displayOrderId}',
                    style: AppTextStyles.extraBold.copyWith(fontSize: 18, color: AppColors.darkText),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order.status.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryPurple,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Customer Details Box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CUSTOMER & DELIVERY DETAILS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildDetailRow(Icons.person_outline_rounded, 'Customer', order.buyerName),
                    if (order.buyerPhone.isNotEmpty)
                      _buildDetailRow(Icons.phone_outlined, 'Phone', order.buyerPhone),
                    if (order.buyerEmail.isNotEmpty)
                      _buildDetailRow(Icons.email_outlined, 'Email', order.buyerEmail),
                    if (order.shippingAddress.isNotEmpty)
                      _buildDetailRow(Icons.location_on_outlined, 'Address', order.shippingAddress),
                    _buildDetailRow(
                      Icons.payments_outlined,
                      'Payment',
                      '${order.paymentMethod.toUpperCase()} (${order.paymentStatus.toUpperCase()})',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Order Items
              const Text(
                'ORDERED ITEMS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 8),
              ...order.items.map((item) {
                final matchedProd = controller.storeProductsMap[item.productId];
                final prodName = (item.productName.isNotEmpty && item.productName != 'Product')
                    ? item.productName
                    : (matchedProd?.name ?? 'Product');
                final prodImg = item.image.isNotEmpty
                    ? item.image
                    : (matchedProd?.primaryImage ?? '');

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 48,
                          height: 48,
                          color: Colors.white,
                          child: prodImg.isNotEmpty
                              ? Image.network(
                                  prodImg,
                                  fit: BoxFit.cover,
                                  cacheWidth: 120,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.inventory_2_outlined, size: 20),
                                )
                              : const Icon(Icons.inventory_2_outlined, size: 20, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              prodName,
                              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Qty: ${item.quantity}  ×  Rs. ${item.price.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Rs. ${(item.total > 0 ? item.total : item.price * item.quantity).toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),

              // Payment Summary
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    if (order.subtotal > 0)
                      _buildSummaryLine('Subtotal', 'Rs. ${order.subtotal.toStringAsFixed(0)}'),
                    if (order.shippingFee > 0)
                      _buildSummaryLine('Shipping Fee', 'Rs. ${order.shippingFee.toStringAsFixed(0)}'),
                    if (order.discount > 0)
                      _buildSummaryLine('Discount', '- Rs. ${order.discount.toStringAsFixed(0)}'),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Grand Total',
                          style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                        ),
                        Text(
                          'Rs. ${order.totalAmount.toStringAsFixed(0)}',
                          style: AppTextStyles.extraBold.copyWith(fontSize: 16.5, color: AppColors.primaryPurple),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.primaryPurple),
          const SizedBox(width: 8),
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'N/A',
              style: const TextStyle(fontSize: 12.5, color: Color(0xFF1E293B), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B))),
          Text(value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
        ],
      ),
    );
  }

  Widget _buildFilterTab({
    required String label,
    required int count,
    required bool isSelected,
    Color? activeColor,
    required VoidCallback onTap,
  }) {
    final themeColor = activeColor ?? AppColors.primaryPurple;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? themeColor : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.25) : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF8FAFC),
      period: const Duration(milliseconds: 1400),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (_, __) => Container(
          height: 155,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
