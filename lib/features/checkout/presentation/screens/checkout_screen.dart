import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../controllers/checkout_controller.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CheckoutController());

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('Checkout', style: AppTextStyles.bold.copyWith(fontSize: 18, color: AppColors.darkText)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isFetching.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryPurple));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildAddressSection(controller),
              const SizedBox(height: 16),
              _buildPaymentMethodSection(controller),
              const SizedBox(height: 16),
              _buildOrderSummarySection(controller),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildAddressSection(CheckoutController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.primaryPurple, size: 24),
              const SizedBox(width: 8),
              Text('Delivery Address', style: AppTextStyles.bold.copyWith(fontSize: 16, color: AppColors.darkText)),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(label: 'Full name', hint: 'John Doe', icon: Icons.person_outline, controller: controller.fullNameController),
          const SizedBox(height: 12),
          _buildTextField(label: 'Phone', hint: '03001234567', icon: Icons.phone_outlined, controller: controller.phoneController, keyboardType: TextInputType.phone),
          const SizedBox(height: 12),
          _buildTextField(label: 'Address line', hint: 'House, street, area', icon: Icons.home_outlined, controller: controller.addressLineController),
          const SizedBox(height: 12),
          _buildTextField(label: 'City', hint: 'Lahore', icon: Icons.location_city_outlined, controller: controller.cityController),
          const SizedBox(height: 12),
          _buildTextField(label: 'Province', hint: 'Punjab', icon: Icons.map_outlined, controller: controller.provinceController),
          const SizedBox(height: 12),
          _buildTextField(label: 'Country', hint: 'Pakistan', icon: Icons.language, controller: controller.countryController),
          const SizedBox(height: 12),
          _buildTextField(label: 'Postal code', hint: '54000', icon: Icons.numbers, controller: controller.postalCodeController, keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          Obx(() => CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: controller.isDefaultAddress.value,
            onChanged: (val) => controller.isDefaultAddress.value = val ?? false,
            activeColor: AppColors.primaryPurple,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text('Set as default address', style: AppTextStyles.medium.copyWith(fontSize: 14)),
          )),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection(CheckoutController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primaryPurple, size: 20),
              ),
              const SizedBox(width: 12),
              Text('Payment Method', style: AppTextStyles.bold.copyWith(fontSize: 16, color: AppColors.darkText)),
            ],
          ),
          const SizedBox(height: 20),
          // COD Option (Active)
          Obx(() => GestureDetector(
            onTap: () => controller.selectedPaymentMethod.value = 'COD',
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: controller.selectedPaymentMethod.value == 'COD' ? AppColors.primaryPurple : Colors.grey.shade200,
                  width: controller.selectedPaymentMethod.value == 'COD' ? 1.5 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
                color: controller.selectedPaymentMethod.value == 'COD' ? AppColors.primaryPurple.withValues(alpha: 0.03) : Colors.transparent,
              ),
              child: Row(
                children: [
                  Icon(
                    controller.selectedPaymentMethod.value == 'COD' ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: controller.selectedPaymentMethod.value == 'COD' ? AppColors.primaryPurple : Colors.grey.shade400,
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: controller.selectedPaymentMethod.value == 'COD' ? AppColors.primaryPurple.withValues(alpha: 0.1) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.local_shipping_outlined,
                      color: controller.selectedPaymentMethod.value == 'COD' ? AppColors.primaryPurple : Colors.grey.shade600,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cash on Delivery', style: AppTextStyles.bold.copyWith(fontSize: 15, color: AppColors.darkText)),
                        const SizedBox(height: 2),
                        Text('Pay cash when order arrives', style: AppTextStyles.regular.copyWith(fontSize: 12, color: AppColors.hintText)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )),
          const SizedBox(height: 12),
          // Credit Card Option (Disabled / Coming Soon)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200, width: 1),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            child: Row(
              children: [
                Icon(Icons.radio_button_off, color: Colors.grey.shade300),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.credit_card_outlined, color: Colors.grey.shade400, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Credit / Debit Card', style: AppTextStyles.bold.copyWith(fontSize: 15, color: Colors.grey.shade400)),
                      const SizedBox(height: 2),
                      Text('Coming soon', style: AppTextStyles.regular.copyWith(fontSize: 12, color: Colors.grey.shade400)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummarySection(CheckoutController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long, color: AppColors.primaryPurple, size: 24),
              const SizedBox(width: 8),
              Text('Order Summary', style: AppTextStyles.bold.copyWith(fontSize: 16, color: AppColors.darkText)),
            ],
          ),
          const SizedBox(height: 16),
          ...controller.selectedItems.map((itemData) {
            final item = itemData as Map<String, dynamic>;
            final imageUrl = item['image'] ?? item['product']?['image'] ?? '';
            final name = item['name'] ?? item['product']?['name'] ?? 'Product';
            final quantity = item['quantity'] ?? 1;
            final price = item['price'] ?? item['product']?['price'] ?? 0;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(width: 50, height: 50, color: Colors.grey.shade100, child: const Icon(Icons.image_not_supported, color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: AppTextStyles.medium.copyWith(fontSize: 13, color: AppColors.darkText), maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text('Qty $quantity', style: AppTextStyles.medium.copyWith(fontSize: 12, color: AppColors.primaryPurple)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Rs. ${price * quantity}', style: AppTextStyles.bold.copyWith(fontSize: 14, color: AppColors.darkText)),
                ],
              ),
            );
          }),
          const Divider(height: 32),
          Obx(() => Column(
            children: [
              _buildSummaryRow('Subtotal', 'Rs. ${controller.summary['subtotal']}'),
              const SizedBox(height: 8),
              _buildSummaryRow('Shipping', 'Rs. ${controller.summary['shipping']}'),
              if ((controller.summary['tax'] ?? 0) > 0) ...[
                const SizedBox(height: 8),
                _buildSummaryRow('Tax', 'Rs. ${controller.summary['tax']}'),
              ],
              if ((controller.summary['discount'] ?? 0) > 0) ...[
                const SizedBox(height: 8),
                _buildSummaryRow('Discount', '- Rs. ${controller.summary['discount']}'),
              ],
              const SizedBox(height: 16),
              _buildSummaryRow('Total', 'Rs. ${controller.summary['total']}', isTotal: true),
            ],
          )),
          const SizedBox(height: 24),
          Obx(() => AppButton(
            text: 'Place Order',
            isLoading: controller.isLoading.value,
            onPressed: controller.placeOrder,
          )),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal ? AppTextStyles.bold.copyWith(fontSize: 16, color: AppColors.darkText) : AppTextStyles.medium.copyWith(fontSize: 14, color: AppColors.hintText),
        ),
        Text(
          value,
          style: isTotal ? AppTextStyles.extraBold.copyWith(fontSize: 18, color: AppColors.primaryPurple) : AppTextStyles.bold.copyWith(fontSize: 14, color: AppColors.darkText),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bold.copyWith(fontSize: 13, color: AppColors.darkText)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: AppTextStyles.medium.copyWith(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.regular.copyWith(color: AppColors.hintText),
            prefixIcon: Icon(icon, color: AppColors.hintText, size: 20),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primaryPurple, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
