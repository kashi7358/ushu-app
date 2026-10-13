import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.darkText, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.amber.shade700,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.flash_on_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            Obx(() => Text(
              controller.isEditMode.value ? 'Update Flash Sale' : 'Create Flash Sale',
              style: AppTextStyles.bold.copyWith(color: AppColors.darkText, fontSize: 17),
            )),
          ],
        ),
        centerTitle: true,
      ),
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Campaign Details Card
              _buildSectionCard(
                title: 'Campaign Details',
                icon: Icons.campaign_rounded,
                children: [
                  TextFormField(
                    controller: controller.titleController,
                    decoration: _inputDecoration(
                      hint: 'e.g. Summer Super Flash Sale',
                      label: 'Sale Title *',
                      icon: Icons.title_rounded,
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter sale title' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: controller.descriptionController,
                    maxLines: 2,
                    decoration: _inputDecoration(
                      hint: 'e.g. Limited time big discounts for our verified buyers',
                      label: 'Description',
                      icon: Icons.description_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 2. Schedule Timing Card (Start & End Time)
              _buildSectionCard(
                title: 'Sale Schedule',
                icon: Icons.access_time_rounded,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() => _buildDateTimePicker(
                          label: 'Start Time',
                          dateTime: controller.startTime.value,
                          onTap: () => controller.pickDateTime(isStart: true, context: context),
                        )),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Obx(() => _buildDateTimePicker(
                          label: 'End Time',
                          dateTime: controller.endTime.value,
                          onTap: () => controller.pickDateTime(isStart: false, context: context),
                        )),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 3. Discount & Sale Rules
              _buildSectionCard(
                title: 'Discount & Limits',
                icon: Icons.percent_rounded,
                children: [
                  // Discount Type Selector
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() => _buildTypeChoice(
                          label: 'Percentage (%)',
                          isSelected: controller.discountType.value == 'percentage',
                          onTap: () => controller.setDiscountType('percentage'),
                        )),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Obx(() => _buildTypeChoice(
                          label: 'Fixed Price (PKR)',
                          isSelected: controller.discountType.value == 'fixed',
                          onTap: () => controller.setDiscountType('fixed'),
                        )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: controller.discountValueController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration(
                            hint: '20',
                            label: 'Discount Value *',
                            icon: Icons.discount_outlined,
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Required';
                            if (num.tryParse(v) == null) return 'Invalid';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: controller.stockLimitController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration(
                            hint: '50',
                            label: 'Stock Limit *',
                            icon: Icons.inventory_outlined,
                          ),
                          validator: (v) => (v == null || int.tryParse(v) == null) ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: controller.maxPerUserController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration(
                            hint: '2',
                            label: 'Max Per User',
                            icon: Icons.person_outline_rounded,
                          ),
                          validator: (v) => (v == null || int.tryParse(v) == null) ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Obx(() => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: controller.isFreeShipping.value,
                                onChanged: controller.toggleFreeShipping,
                                activeColor: AppColors.primaryPurple,
                              ),
                              const Expanded(
                                child: Text(
                                  'Free Shipping',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                                ),
                              ),
                            ],
                          ),
                        )),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 4. Products Selection Card
              _buildSectionCard(
                title: 'Select Products for Flash Sale',
                icon: Icons.shopping_bag_outlined,
                children: [
                  Obx(() {
                    if (controller.isLoadingProducts.value) {
                      return Shimmer.fromColors(
                        baseColor: const Color(0xFFE2E8F0),
                        highlightColor: const Color(0xFFF8FAFC),
                        child: Column(
                          children: List.generate(3, (_) => Container(
                            height: 65,
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
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
                        ),
                        child: Text(controller.errorMessage.value, style: const TextStyle(color: Colors.red, fontSize: 13)),
                      );
                    }

                    if (controller.storeProducts.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        child: const Center(
                          child: Text(
                            'No products found in your store. Please create products first.',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.storeProducts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final product = controller.storeProducts[index];
                        final isSelected = controller.selectedProductIds.contains(product.id);
                        return _buildProductSelectTile(product, isSelected, controller);
                      },
                    );
                  }),
                ],
              ),
              const SizedBox(height: 26),

              // 5. Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: Obx(() => ElevatedButton.icon(
                  onPressed: controller.submitFlashSale,
                  icon: Icon(
                    controller.isEditMode.value ? Icons.save_as_rounded : Icons.bolt_rounded,
                    size: 22,
                    color: Colors.white,
                  ),
                  label: Text(
                    controller.isEditMode.value
                        ? 'Update Flash Sale Campaign'
                        : 'Launch Flash Sale Campaign',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 1,
                  ),
                )),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
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
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primaryPurple, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: AppTextStyles.bold.copyWith(fontSize: 14.5, color: const Color(0xFF1E293B)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDateTimePicker({
    required String label,
    required DateTime? dateTime,
    required VoidCallback onTap,
  }) {
    final text = dateTime != null
        ? '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}'
        : 'Pick Date';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.primaryPurple),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChoice({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryPurple : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF64748B),
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildProductSelectTile(
    SellerProductModel product,
    bool isSelected,
    CreateFlashSaleController controller,
  ) {
    return InkWell(
      onTap: () => controller.toggleProductSelection(product.id),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryPurple.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryPurple : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (_) => controller.toggleProductSelection(product.id),
              activeColor: AppColors.primaryPurple,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 44,
                height: 44,
                color: const Color(0xFFF1F5F9),
                child: product.primaryImage.isNotEmpty
                    ? Image.network(
                        product.primaryImage,
                        fit: BoxFit.cover,
                        cacheWidth: 120,
                        errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 20),
                      )
                    : const Icon(Icons.inventory_2_outlined, size: 20, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${product.priceCurrency} ${product.price.toStringAsFixed(0)}  •  Stock: ${product.stock}',
                    style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
      prefixIcon: Icon(icon, color: AppColors.primaryPurple, size: 18),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryPurple, width: 1.5),
      ),
    );
  }
}
