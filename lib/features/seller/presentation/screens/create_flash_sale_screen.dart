import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/routes/app_routes.dart';
import '../../data/models/seller_product_model.dart';
import '../controllers/create_flash_sale_controller.dart';

class CreateFlashSaleScreen extends StatelessWidget {
  const CreateFlashSaleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreateFlashSaleController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.darkText, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.flash_on_rounded, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Obx(() => Text(
                controller.isEditMode.value ? 'Update Flash Sale' : 'Create Flash Sale',
                style: AppTextStyles.bold.copyWith(color: AppColors.darkText, fontSize: 16.5),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () => Get.toNamed(AppRoutes.sellerManageFlashSales),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.list_alt_rounded, size: 15, color: Color(0xFFB45309)),
                    SizedBox(width: 4),
                    Text(
                      'Manage',
                      style: TextStyle(
                        color: Color(0xFFB45309),
                        fontWeight: FontWeight.w700,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Banner: Flash Sale Motivation & Tips
              _buildHeroPromoBanner(),
              const SizedBox(height: 14),

              // 1. Campaign Details Card
              _buildSectionCard(
                title: 'Campaign Details',
                icon: Icons.campaign_rounded,
                children: [
                  TextFormField(
                    controller: controller.titleController,
                    decoration: _inputDecoration(
                      hint: 'e.g. Mega Weekend Flash Sale',
                      label: 'Sale Title *',
                      icon: Icons.title_rounded,
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter sale title' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: controller.descriptionController,
                    maxLines: 2,
                    decoration: _inputDecoration(
                      hint: 'e.g. Exclusive limited-time markdowns for loyal shoppers',
                      label: 'Campaign Description (Optional)',
                      icon: Icons.notes_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 2. Schedule Timing Card (Start & End Time)
              _buildSectionCard(
                title: 'Sale Schedule',
                icon: Icons.access_time_filled_rounded,
                trailing: Obx(() {
                  final duration = controller.getCampaignDuration();
                  if (duration.isEmpty) return const SizedBox.shrink();
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer_outlined, size: 12, color: Color(0xFF2563EB)),
                        const SizedBox(width: 4),
                        Text(
                          duration,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() => _buildDateTimePicker(
                          label: 'Start Date & Time',
                          dateTime: controller.startTime.value,
                          onTap: () => controller.pickDateTime(isStart: true, context: context),
                        )),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Obx(() => _buildDateTimePicker(
                          label: 'End Date & Time',
                          dateTime: controller.endTime.value,
                          onTap: () => controller.pickDateTime(isStart: false, context: context),
                        )),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 3. Discount & Sale Rules
              _buildSectionCard(
                title: 'Discount & Limits',
                icon: Icons.percent_rounded,
                children: [
                  // Discount Type Selector Tabs
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() => _buildTypeChoice(
                          label: 'Percentage (%)',
                          icon: Icons.percent_rounded,
                          isSelected: controller.discountType.value == 'percentage',
                          onTap: () => controller.setDiscountType('percentage'),
                        )),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Obx(() => _buildTypeChoice(
                          label: 'Fixed Price (PKR)',
                          icon: Icons.sell_outlined,
                          isSelected: controller.discountType.value == 'fixed',
                          onTap: () => controller.setDiscountType('fixed'),
                        )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Discount Value & Stock Limit
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: controller.discountValueController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (_) => controller.discountValueController.text,
                          decoration: _inputDecoration(
                            hint: '20',
                            label: 'Discount Value *',
                            icon: Icons.discount_rounded,
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Required';
                            if (num.tryParse(v) == null) return 'Invalid';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: controller.stockLimitController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration(
                            hint: '50',
                            label: 'Stock Limit *',
                            icon: Icons.inventory_2_rounded,
                          ),
                          validator: (v) => (v == null || int.tryParse(v) == null) ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Max Per User
                  TextFormField(
                    controller: controller.maxPerUserController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(
                      hint: '2',
                      label: 'Max Limit Per Customer',
                      icon: Icons.person_outline_rounded,
                    ),
                    validator: (v) => (v == null || int.tryParse(v) == null) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),

                  // Dedicated Free Shipping Toggle Tile
                  Obx(() {
                    final isFree = controller.isFreeShipping.value;
                    return InkWell(
                      onTap: () => controller.toggleFreeShipping(!isFree),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isFree ? AppColors.primaryPurple.withValues(alpha: 0.05) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isFree ? AppColors.primaryPurple.withValues(alpha: 0.3) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isFree
                                    ? AppColors.primaryPurple.withValues(alpha: 0.15)
                                    : const Color(0xFFE2E8F0),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.local_shipping_rounded,
                                size: 18,
                                color: isFree ? AppColors.primaryPurple : const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Free Shipping for Buyers',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isFree
                                        ? 'Buyers get free delivery on this flash sale'
                                        : 'Standard shipping charges apply',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: isFree,
                              onChanged: controller.toggleFreeShipping,
                              activeThumbColor: AppColors.primaryPurple,
                              activeTrackColor: AppColors.primaryPurple.withValues(alpha: 0.3),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 14),

              // 4. Products Selection Card (Main Bottom Cards)
              _buildSectionCard(
                title: 'Select Products',
                icon: Icons.shopping_bag_rounded,
                trailing: Obx(() {
                  final total = controller.storeProducts.length;
                  final selected = controller.selectedProductIds.length;
                  if (total == 0) return const SizedBox.shrink();
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryPurple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$selected / $total Selected',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryPurple,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      TextButton(
                        onPressed: selected == total
                            ? controller.deselectAllProducts
                            : controller.selectAllProducts,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          selected == total ? 'Clear' : 'Select All',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryPurple,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                children: [
                  // Search & Filter Box
                  Container(
                    height: 42,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: TextField(
                      controller: controller.searchController,
                      onChanged: (val) => controller.searchQuery.value = val,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
                      decoration: InputDecoration(
                        hintText: 'Search products by name, SKU or category...',
                        hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                        prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF94A3B8)),
                        suffixIcon: Obx(() {
                          if (controller.searchQuery.value.isEmpty) return const SizedBox.shrink();
                          return IconButton(
                            icon: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF94A3B8)),
                            onPressed: () {
                              controller.searchController.clear();
                              controller.searchQuery.value = '';
                            },
                          );
                        }),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),

                  Obx(() {
                    if (controller.isLoadingProducts.value) {
                      return Shimmer.fromColors(
                        baseColor: const Color(0xFFE2E8F0),
                        highlightColor: const Color(0xFFF8FAFC),
                        child: Column(
                          children: List.generate(3, (_) => Container(
                            height: 72,
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                          )),
                        ),
                      );
                    }

                    if (controller.errorMessage.value.isNotEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, size: 18, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                controller.errorMessage.value,
                                style: const TextStyle(color: Colors.red, fontSize: 12.5),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (controller.storeProducts.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.inventory_2_outlined, size: 36, color: Color(0xFF94A3B8)),
                              SizedBox(height: 8),
                              Text(
                                'No store products found',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13.5,
                                  color: Color(0xFF475569),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Please create products first before launching a flash sale.',
                                style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final filtered = controller.filteredProducts;

                    if (filtered.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(20),
                        alignment: Alignment.center,
                        child: const Text(
                          'No products match your search query',
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12.5),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final product = filtered[index];
                        final isSelected = controller.selectedProductIds.contains(product.id);
                        return _buildProductSelectTile(product, isSelected, controller);
                      },
                    );
                  }),
                ],
              ),
              const SizedBox(height: 22),

              // 5. Submit Launch Button
              Obx(() {
                final count = controller.selectedProductIds.length;
                final isSubmitting = controller.isSubmitting.value;

                return Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryPurple, AppColors.secondaryViolet],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryPurple.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : controller.submitFlashSale,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                controller.isEditMode.value
                                    ? Icons.save_as_rounded
                                    : Icons.bolt_rounded,
                                size: 20,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  controller.isEditMode.value
                                      ? 'Update Flash Sale Campaign'
                                      : 'Launch Flash Sale ($count Products)',
                                  style: const TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                  ),
                );
              }),
              const SizedBox(height: 26),
            ],
          ),
        ),
      ),
    );
  }

  // Top Hero Motivational Banner
  Widget _buildHeroPromoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E1B4B).withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.offline_bolt_rounded, color: Color(0xFFFCD34D), size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Boost Sales & Conversion',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Flash sales create urgency and can increase order volume by up to 300%.',
                  style: TextStyle(
                    color: Color(0xFFC7D2FE),
                    fontSize: 11.5,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Reusable Professional Section Card
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    Widget? trailing,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primaryPurple, size: 17),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bold.copyWith(
                    fontSize: 14.5,
                    color: const Color(0xFF1E293B),
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing,
              ],
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  // Date Time Picker Tile
  Widget _buildDateTimePicker({
    required String label,
    required DateTime? dateTime,
    required VoidCallback onTap,
  }) {
    final dateStr = dateTime != null
        ? '${dateTime.day} ${_monthName(dateTime.month)} ${dateTime.year}'
        : 'Select Date';
    final timeStr = dateTime != null
        ? '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}'
        : '--:--';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 13, color: AppColors.primaryPurple),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    dateStr,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                const Icon(Icons.schedule_rounded, size: 13, color: Color(0xFF94A3B8)),
                const SizedBox(width: 5),
                Text(
                  timeStr,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _monthName(int month) {
    const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return (month >= 1 && month <= 12) ? m[month - 1] : '';
  }

  // Segment Tab for Discount Type
  Widget _buildTypeChoice({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryPurple : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryPurple.withValues(alpha: 0.28),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Modern Professional Product Selection Card (Bottom Cards)
  Widget _buildProductSelectTile(
    SellerProductModel product,
    bool isSelected,
    CreateFlashSaleController controller,
  ) {
    final currency = product.priceCurrency.isNotEmpty ? product.priceCurrency : 'PKR';
    final discountedPrice = controller.calculateDiscountedPrice(product.price);
    final hasDiscount = discountedPrice < product.price && discountedPrice > 0;
    final isLowStock = product.stock <= 5;

    return InkWell(
      onTap: () => controller.toggleProductSelection(product.id),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryPurple.withValues(alpha: 0.04) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryPurple : const Color(0xFFE2E8F0),
            width: isSelected ? 1.6 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primaryPurple.withValues(alpha: 0.08)
                  : const Color(0xFF0F172A).withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Circular Custom Checkbox Indicator
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primaryPurple : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primaryPurple : const Color(0xFFCBD5E1),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(Icons.check_rounded, size: 14, color: Colors.white),
                    )
                  : null,
            ),
            const SizedBox(width: 10),

            // Product Thumbnail with Mini Stock Badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 52,
                    height: 52,
                    color: const Color(0xFFF1F5F9),
                    child: product.primaryImage.isNotEmpty
                        ? Image.network(
                            product.primaryImage,
                            fit: BoxFit.cover,
                            cacheWidth: 150,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.inventory_2_outlined,
                              size: 22,
                              color: Color(0xFF94A3B8),
                            ),
                          )
                        : const Icon(
                            Icons.inventory_2_outlined,
                            size: 22,
                            color: Color(0xFF94A3B8),
                          ),
                  ),
                ),
                Positioned(
                  bottom: -4,
                  left: 2,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: isLowStock ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isLowStock ? 'Low: ${product.stock}' : 'Stk: ${product.stock}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),

            // Product Info & Real-Time Calculated Price
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),

                  // Category & SKU chips
                  Row(
                    children: [
                      if (product.category.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            product.category,
                            style: const TextStyle(fontSize: 10, color: Color(0xFF475569), fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      if (product.sku.isNotEmpty)
                        Flexible(
                          child: Text(
                            'SKU: ${product.sku}',
                            style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),

                  // Pricing row: Original + Calculated Flash Price
                  Row(
                    children: [
                      if (hasDiscount) ...[
                        Text(
                          '$currency ${product.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                            decoration: TextDecoration.lineThrough,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.flash_on_rounded, size: 11, color: Color(0xFF059669)),
                              Text(
                                '$currency ${discountedPrice.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF059669),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        Text(
                          '$currency ${product.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
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

  // Consistent Clean Input Decoration
  InputDecoration _inputDecoration({
    required String hint,
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500),
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12.5),
      prefixIcon: Icon(icon, color: AppColors.primaryPurple, size: 18),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primaryPurple, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.6),
      ),
    );
  }
}
