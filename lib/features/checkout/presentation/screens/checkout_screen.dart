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
    return Obx(() {
      if (controller.hasSavedAddress.value && !controller.isEditingAddress.value) {
        return _buildSavedAddressCard(controller);
      }
      return _buildAddressForm(controller);
    });
  }

  Widget _buildSavedAddressCard(CheckoutController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.2), width: 1.2),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on, color: AppColors.primaryPurple, size: 24),
                  const SizedBox(width: 8),
                  Text('Delivery Address', style: AppTextStyles.bold.copyWith(fontSize: 16, color: AppColors.darkText)),
                ],
              ),
              InkWell(
                onTap: () => controller.isEditingAddress.value = true,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.edit_outlined, color: AppColors.primaryPurple, size: 15),
                      const SizedBox(width: 4),
                      Text('Edit', style: AppTextStyles.bold.copyWith(color: AppColors.primaryPurple, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                controller.fullNameController.text,
                style: AppTextStyles.bold.copyWith(fontSize: 14, color: AppColors.darkText),
              ),
              const SizedBox(width: 14),
              const Icon(Icons.phone_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                controller.phoneController.text,
                style: AppTextStyles.medium.copyWith(fontSize: 13, color: AppColors.darkText),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.home_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${controller.addressLineController.text}, ${controller.cityController.text}, ${controller.provinceController.text}, ${controller.countryController.text} (${controller.postalCodeController.text})',
                  style: AppTextStyles.medium.copyWith(fontSize: 13, color: AppColors.darkText, height: 1.3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressForm(CheckoutController controller) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on, color: AppColors.primaryPurple, size: 24),
                  const SizedBox(width: 8),
                  Text('Delivery Address', style: AppTextStyles.bold.copyWith(fontSize: 16, color: AppColors.darkText)),
                ],
              ),
              if (controller.hasSavedAddress.value)
                TextButton.icon(
                  onPressed: () => controller.isEditingAddress.value = false,
                  icon: const Icon(Icons.check, size: 16, color: AppColors.primaryPurple),
                  label: Text('Cancel', style: AppTextStyles.bold.copyWith(color: AppColors.primaryPurple, fontSize: 13)),
                ),
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
          DropdownButtonFormField<String>(
            initialValue: [
              'Punjab',
              'Sindh',
              'Khyber Pakhtunkhwa',
              'Balochistan',
              'Islamabad (Capital)',
              'Gilgit-Baltistan & AJK',
            ].contains(controller.provinceController.text) 
                ? controller.provinceController.text 
                : 'Punjab',
            decoration: InputDecoration(
              labelText: 'Province',
              labelStyle: AppTextStyles.medium.copyWith(color: AppColors.hintText, fontSize: 14),
              prefixIcon: const Icon(Icons.map_outlined, color: AppColors.hintText),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primaryPurple, width: 1.5),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            items: const [
              DropdownMenuItem(value: 'Punjab', child: Text('Punjab')),
              DropdownMenuItem(value: 'Sindh', child: Text('Sindh')),
              DropdownMenuItem(value: 'Khyber Pakhtunkhwa', child: Text('Khyber Pakhtunkhwa')),
              DropdownMenuItem(value: 'Balochistan', child: Text('Balochistan')),
              DropdownMenuItem(value: 'Islamabad (Capital)', child: Text('Islamabad (Capital)')),
              DropdownMenuItem(value: 'Gilgit-Baltistan & AJK', child: Text('Gilgit-Baltistan & AJK')),
            ],
            onChanged: (val) {
              if (val != null) {
                controller.provinceController.text = val;
              }
            },
          ),
          const SizedBox(height: 12),
          _buildTextField(label: 'Country', hint: 'Pakistan', icon: Icons.language, controller: controller.countryController),
          const SizedBox(height: 12),
          _buildTextField(label: 'Postal code', hint: '54000', icon: Icons.numbers, controller: controller.postalCodeController, keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: controller.isDefaultAddress.value,
            onChanged: (val) => controller.isDefaultAddress.value = val ?? false,
            activeColor: AppColors.primaryPurple,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text('Set as default address', style: AppTextStyles.medium.copyWith(fontSize: 14)),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryPurple,
                side: const BorderSide(color: AppColors.primaryPurple, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                await controller.saveAddress();
              },
              icon: const Icon(Icons.save_outlined, size: 18),
              label: const Text('Save Address Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
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
          const SizedBox(height: 16),
          // COD Option (Active)
          GestureDetector(
            onTap: () => controller.selectedPaymentMethod.value = 'COD',
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.primaryPurple,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(12),
                color: AppColors.primaryPurple.withValues(alpha: 0.04),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.radio_button_checked,
                    color: AppColors.primaryPurple,
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.local_shipping_outlined,
                      color: AppColors.primaryPurple,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cash on Delivery (COD)', style: AppTextStyles.bold.copyWith(fontSize: 15, color: AppColors.darkText)),
                        const SizedBox(height: 2),
                        Text('Pay cash when order arrives at your doorstep', style: AppTextStyles.regular.copyWith(fontSize: 12, color: AppColors.hintText)),
                      ],
                    ),
                  ),
                ],
              ),
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
          ...controller.selectedItems.map((item) {
            final imageUrl = item.image;
            final name = item.name;
            final quantity = item.quantity;
            final price = item.price;
            
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
                      errorBuilder: (_, __, ___) => Container(width: 50, height: 50, color: Colors.grey.shade100, child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 20)),
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
          Column(
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
          ),
          const SizedBox(height: 24),
          AppButton(
            text: 'Place Order',
            isLoading: controller.isLoading.value,
            onPressed: controller.placeOrder,
          ),
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
