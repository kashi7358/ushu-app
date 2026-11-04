import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../controllers/financial_report_controller.dart';
import '../../data/models/seller_order_model.dart';

class FinancialReportScreen extends StatelessWidget {
  const FinancialReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FinancialReportController());

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
        title: Text(
          'Financial Report',
          style: AppTextStyles.bold.copyWith(color: AppColors.darkText, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryPurple, size: 22),
            onPressed: controller.fetchFinancialReport,
            tooltip: 'Refresh Financials',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryPurple),
          );
        }

        return RefreshIndicator(
          color: AppColors.primaryPurple,
          onRefresh: controller.fetchFinancialReport,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Error message banner if any
                if (controller.errorMessage.value.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            controller.errorMessage.value,
                            style: const TextStyle(color: Colors.red, fontSize: 12.5),
                          ),
                        ),
                      ],
                    ),
                  ),

                // 1. Executive Modern Revenue Card
                _buildModernRevenueCard(controller),
                const SizedBox(height: 18),

                // 2. Settlement Ratio Visual Card
                _buildSettlementProgressCard(controller),
                const SizedBox(height: 24),

                // 3. Delivered Products & Settlement List Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'DELIVERED ORDERS',
                          style: AppTextStyles.bold.copyWith(
                            color: const Color(0xFF0F172A),
                            fontSize: 13,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    Obx(() => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0).withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${controller.filteredOrders.length} Delivered',
                        style: const TextStyle(color: Color(0xFF475569), fontSize: 11.5, fontWeight: FontWeight.w600),
                      ),
                    )),
                  ],
                ),
                const SizedBox(height: 12),

                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: controller.onSearchChanged,
                    decoration: const InputDecoration(
                      hintText: 'Search by Order ID, Buyer, Product...',
                      hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Interactive Filter Pills (All, Paid, Unpaid)
                Row(
                  children: [
                    _buildFilterChip(
                      controller: controller,
                      label: 'All',
                      count: controller.totalDeliveredCount.value,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      controller: controller,
                      label: 'Paid',
                      count: controller.totalDeliveredCount.value - controller.totalPendingCount.value,
                      activeColor: const Color(0xFF10B981),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      controller: controller,
                      label: 'Unpaid',
                      count: controller.totalPendingCount.value,
                      activeColor: const Color(0xFFF59E0B),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Orders List
                if (controller.filteredOrders.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 42, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.inventory_2_outlined, size: 36, color: Color(0xFF94A3B8)),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No Delivered Orders Found',
                          style: AppTextStyles.bold.copyWith(color: AppColors.darkText, fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Delivered orders and their payout status will appear here.',
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.filteredOrders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final order = controller.filteredOrders[index];
                      return _buildOrderFinancialTile(order);
                    },
                  ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      }),
    );
  }

  // 1. Executive Revenue Card
  Widget _buildModernRevenueCard(FinancialReportController controller) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E1065), Color(0xFF3B168F), Color(0xFF4C24A6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B168F).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -25,
            top: -25,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.account_balance_wallet_rounded, size: 16, color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'TOTAL PAYOUT REVENUE',
                          style: AppTextStyles.bold.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 11,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'PKR',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Rs. ${_formatAmount(controller.totalRevenue.value)}',
                    style: AppTextStyles.extraBold.copyWith(
                      fontSize: 30,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Colors.white24),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _buildHeaderPill(
                        label: 'Paid (Settled)',
                        value: 'Rs. ${_formatAmount(controller.settledPayout.value)}',
                        icon: Icons.check_circle_rounded,
                        color: const Color(0xFF34D399),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildHeaderPill(
                        label: 'Unpaid (Pending)',
                        value: 'Rs. ${_formatAmount(controller.pendingEscrow.value)}',
                        icon: Icons.hourglass_top_rounded,
                        color: const Color(0xFFFBBF24),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderPill({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. Settlement Ratio Card with Visual Bar
  Widget _buildSettlementProgressCard(FinancialReportController controller) {
    final double total = controller.totalRevenue.value;
    final double settled = controller.settledPayout.value;
    final double pending = controller.pendingEscrow.value;

    final double settledPct = total > 0 ? (settled / total).clamp(0.0, 1.0) : 0.0;
    final int sFlex = (settledPct * 100).round();
    final int pFlex = (100 - sFlex).clamp(0, 100);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.pie_chart_outline_rounded, size: 18, color: AppColors.primaryPurple),
                  const SizedBox(width: 6),
                  Text(
                    'Payout Settlement Ratio',
                    style: AppTextStyles.bold.copyWith(fontSize: 13.5, color: const Color(0xFF0F172A)),
                  ),
                ],
              ),
              Text(
                '${(settledPct * 100).toStringAsFixed(0)}% Paid',
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF10B981)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  if (sFlex > 0)
                    Expanded(
                      flex: sFlex,
                      child: Container(color: const Color(0xFF10B981)),
                    ),
                  if (pFlex > 0 && pending > 0)
                    Expanded(
                      flex: pFlex,
                      child: Container(color: const Color(0xFFF59E0B)),
                    ),
                  if (total == 0)
                    Expanded(
                      flex: 100,
                      child: Container(color: const Color(0xFFE2E8F0)),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProgressLegend('Paid: Rs. ${_formatAmount(settled)}', const Color(0xFF10B981)),
              _buildProgressLegend('Unpaid: Rs. ${_formatAmount(pending)}', const Color(0xFFF59E0B)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressLegend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // 3. Filter Chip Widget
  Widget _buildFilterChip({
    required FinancialReportController controller,
    required String label,
    required int count,
    Color activeColor = AppColors.primaryPurple,
  }) {
    return Obx(() {
      final isSelected = controller.selectedFilter.value == label;
      return InkWell(
        onTap: () => controller.setFilter(label),
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isSelected ? activeColor : const Color(0xFFE2E8F0),
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withValues(alpha: 0.25) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // 4. Delivered Product & Order Financial Tile
  Widget _buildOrderFinancialTile(SellerOrderModel order) {
    final isPaid = order.paymentStatus.toLowerCase() == 'paid' || order.paymentStatus.toLowerCase() == 'settled';
    final Color badgeBg = isPaid ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB);
    final Color badgeColor = isPaid ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
    final String badgeText = isPaid ? 'Paid' : 'Unpaid';

    final String firstProductImg = order.items.isNotEmpty ? order.items.first.image : '';
    final String firstProductName = order.items.isNotEmpty ? order.items.first.productName : 'Delivered Product';
    final int totalItems = order.items.fold(0, (sum, i) => sum + i.quantity);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header: ID, Date, Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Icon(Icons.receipt_rounded, size: 14, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    order.displayOrderId,
                    style: AppTextStyles.bold.copyWith(fontSize: 13.5, color: const Color(0xFF0F172A)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: badgeColor.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: badgeColor),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      badgeText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: badgeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),

          // Product Thumbnail & Information
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 56,
                  height: 56,
                  color: const Color(0xFFF8FAFC),
                  child: firstProductImg.isNotEmpty
                      ? Image.network(
                          firstProductImg,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 24),
                        )
                      : const Icon(Icons.shopping_bag_outlined, color: Color(0xFF94A3B8), size: 24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      firstProductName,
                      style: AppTextStyles.bold.copyWith(fontSize: 13, color: const Color(0xFF0F172A), height: 1.2),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Buyer: ${order.buyerName.isNotEmpty ? order.buyerName : "Customer"}  •  Qty: $totalItems',
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rs. ${_formatAmount(order.totalAmount)}',
                    style: AppTextStyles.bold.copyWith(fontSize: 14.5, color: AppColors.primaryPurple),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Delivered',
                    style: TextStyle(fontSize: 10.5, color: Color(0xFF10B981), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount.truncateToDouble() == amount) {
      return amount.toInt().toString();
    }
    return amount.toStringAsFixed(0);
  }
}
