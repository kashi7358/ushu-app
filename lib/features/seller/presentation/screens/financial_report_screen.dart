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
                // Error message if any
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

                // 1. Executive Revenue Summary Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E1B4B), Color(0xFF312E81), Color(0xFF4338CA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF312E81).withValues(alpha: 0.3),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.greenAccent,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'TOTAL REVENUE',
                                    style: AppTextStyles.bold.copyWith(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      fontSize: 11,
                                      letterSpacing: 1.1,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'PKR Currency',
                              style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Rs. ${_formatAmount(controller.totalRevenue.value)}',
                          style: AppTextStyles.extraBold.copyWith(
                            fontSize: 28,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Divider(height: 1, color: Colors.white24),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildHeaderPill(
                              label: 'Settled Payout',
                              value: 'Rs. ${_formatAmount(controller.settledPayout.value)}',
                              icon: Icons.check_circle_rounded,
                              color: Colors.greenAccent,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildHeaderPill(
                              label: 'Pending Escrow',
                              value: 'Rs. ${_formatAmount(controller.pendingEscrow.value)}',
                              icon: Icons.hourglass_top_rounded,
                              color: Colors.amberAccent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Metrics Grid (4 Clean Cards)
                Text(
                  'FINANCIAL BREAKDOWN',
                  style: AppTextStyles.bold.copyWith(
                    color: AppColors.hintText,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Gross Revenue',
                        value: 'Rs. ${_formatAmount(controller.totalRevenue.value)}',
                        subtitle: '${controller.allFinancialOrders.length} Orders total',
                        icon: Icons.account_balance_wallet_rounded,
                        color: const Color(0xFF2563EB),
                        bgColor: const Color(0xFFEFF6FF),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Estimated Profit',
                        value: 'Rs. ${_formatAmount(controller.netProfit.value)}',
                        subtitle: 'After platform fees',
                        icon: Icons.trending_up_rounded,
                        color: const Color(0xFF7C3AED),
                        bgColor: const Color(0xFFF5F3FF),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: 'In-Transit Balance',
                        value: 'Rs. ${_formatAmount(controller.pendingEscrow.value)}',
                        subtitle: '${controller.totalPendingCount.value} Active orders',
                        icon: Icons.pending_actions_rounded,
                        color: const Color(0xFFF59E0B),
                        bgColor: const Color(0xFFFFFBEB),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Cancelled / Refund',
                        value: 'Rs. ${_formatAmount(controller.refundedAmount.value)}',
                        subtitle: '${controller.totalRefundedCount.value} Orders',
                        icon: Icons.assignment_return_rounded,
                        color: const Color(0xFFEF4444),
                        bgColor: const Color(0xFFFEF2F2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // 3. Settlement Progress Bar Card
                _buildSettlementProgressCard(controller),
                const SizedBox(height: 24),

                // 4. Transaction Settlement History Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ORDER SETTLEMENTS',
                      style: AppTextStyles.bold.copyWith(
                        color: AppColors.hintText,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      '${controller.filteredOrders.length} Records',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: TextField(
                    onChanged: controller.onSearchChanged,
                    decoration: const InputDecoration(
                      hintText: 'Search by Order ID, Buyer...',
                      hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
                      prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(controller, 'All'),
                      const SizedBox(width: 8),
                      _buildFilterChip(controller, 'Delivered'),
                      const SizedBox(width: 8),
                      _buildFilterChip(controller, 'Pending'),
                      const SizedBox(width: 8),
                      _buildFilterChip(controller, 'Cancelled'),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Orders List
                if (controller.filteredOrders.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long_rounded, size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 10),
                        Text(
                          'No Financial Records Found',
                          style: AppTextStyles.bold.copyWith(color: AppColors.darkText, fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Transactions will appear here when orders are placed.',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
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
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
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

  Widget _buildHeaderPill({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 10,
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
                    fontSize: 12,
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

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppTextStyles.bold.copyWith(fontSize: 17, color: AppColors.darkText),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSettlementProgressCard(FinancialReportController controller) {
    final double total = controller.totalRevenue.value > 0 ? controller.totalRevenue.value : 1.0;
    final double settledPct = (controller.settledPayout.value / total).clamp(0.0, 1.0);
    final double pendingPct = (controller.pendingEscrow.value / total).clamp(0.0, 1.0);
    final double refundedPct = (controller.refundedAmount.value / total).clamp(0.0, 1.0);

    final int sFlex = (settledPct * 100).round();
    final int pFlex = (pendingPct * 100).round();
    final int rFlex = (refundedPct * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Settlement Ratio',
                style: AppTextStyles.bold.copyWith(fontSize: 13.5, color: AppColors.darkText),
              ),
              Text(
                '${(settledPct * 100).toStringAsFixed(0)}% Settled',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Multi-color progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  if (sFlex > 0)
                    Expanded(
                      flex: sFlex,
                      child: Container(color: const Color(0xFF10B981)),
                    ),
                  if (pFlex > 0)
                    Expanded(
                      flex: pFlex,
                      child: Container(color: const Color(0xFFF59E0B)),
                    ),
                  if (rFlex > 0)
                    Expanded(
                      flex: rFlex,
                      child: Container(color: const Color(0xFFEF4444)),
                    ),
                  if (sFlex == 0 && pFlex == 0 && rFlex == 0)
                    Expanded(
                      flex: 100,
                      child: Container(color: const Color(0xFFE2E8F0)),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildProgressLegend('Settled', const Color(0xFF10B981)),
              _buildProgressLegend('Pending Escrow', const Color(0xFFF59E0B)),
              _buildProgressLegend('Refunded', const Color(0xFFEF4444)),
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
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildFilterChip(FinancialReportController controller, String label) {
    return Obx(() {
      final isSelected = controller.selectedFilter.value == label;
      return InkWell(
        onTap: () => controller.setFilter(label),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryPurple : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primaryPurple : const Color(0xFFCBD5E1),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF475569),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildOrderFinancialTile(SellerOrderModel order) {
    Color badgeBg;
    Color badgeColor;
    String badgeText;

    if (order.isCompleted) {
      badgeBg = const Color(0xFFECFDF5);
      badgeColor = const Color(0xFF10B981);
      badgeText = 'Settled';
    } else if (order.isCancelled) {
      badgeBg = const Color(0xFFFEF2F2);
      badgeColor = const Color(0xFFEF4444);
      badgeText = 'Refunded';
    } else {
      badgeBg = const Color(0xFFFFFBEB);
      badgeColor = const Color(0xFFF59E0B);
      badgeText = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.receipt_rounded, size: 20, color: badgeColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        order.id.length > 8 ? '#${order.id.substring(order.id.length - 8).toUpperCase()}' : '#${order.id.toUpperCase()}',
                        style: AppTextStyles.bold.copyWith(fontSize: 13, color: AppColors.darkText),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Rs. ${_formatAmount(order.totalAmount)}',
                      style: AppTextStyles.bold.copyWith(fontSize: 13.5, color: AppColors.darkText),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        order.buyerName.isNotEmpty ? order.buyerName : 'Buyer',
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: badgeColor),
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

  String _formatAmount(double amount) {
    if (amount.truncateToDouble() == amount) {
      return amount.toInt().toString();
    }
    return amount.toStringAsFixed(2);
  }
}
