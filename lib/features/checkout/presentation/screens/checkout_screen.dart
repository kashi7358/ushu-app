import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
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
        elevation: 0.5,
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
              const SizedBox(height: 16),
            ],
          ),
        );
      }),
      bottomNavigationBar: Obx(() {
        if (controller.isFetching.value) return const SizedBox.shrink();
        final totalAmount = controller.summary['total'] ?? 0;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Payment', style: AppTextStyles.medium.copyWith(fontSize: 12, color: AppColors.hintText)),
                      const SizedBox(height: 2),
                      Text(
                        'Rs. $totalAmount',
                        style: AppTextStyles.extraBold.copyWith(fontSize: 18, color: AppColors.primaryPurple),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 48,
                    width: 160,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        alignment: Alignment.center,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: controller.isLoading.value ? null : controller.placeOrder,
                      child: controller.isLoading.value
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : Center(
                              child: Text(
                                'Place Order',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bold.copyWith(fontSize: 15, color: Colors.white, height: 1.0),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
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
                  const Icon(Icons.location_on, color: AppColors.primaryPurple, size: 22),
                  const SizedBox(width: 8),
                  Text('Delivery Address', style: AppTextStyles.bold.copyWith(fontSize: 15, color: AppColors.darkText)),
                ],
              ),
              InkWell(
                onTap: () => controller.isEditingAddress.value = true,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.edit_outlined, color: AppColors.primaryPurple, size: 14),
                      const SizedBox(width: 4),
                      Text('Edit', style: AppTextStyles.bold.copyWith(color: AppColors.primaryPurple, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 15, color: AppColors.hintText),
              const SizedBox(width: 6),
              Text(
                controller.fullNameController.text.isNotEmpty ? controller.fullNameController.text : 'Customer',
                style: AppTextStyles.bold.copyWith(fontSize: 14, color: AppColors.darkText),
              ),
              const SizedBox(width: 14),
              const Icon(Icons.phone_outlined, size: 15, color: AppColors.hintText),
              const SizedBox(width: 6),
              Text(
                controller.phoneController.text.isNotEmpty ? controller.phoneController.text : 'N/A',
                style: AppTextStyles.medium.copyWith(fontSize: 13, color: AppColors.darkText),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.home_outlined, size: 15, color: AppColors.hintText),
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
      padding: const EdgeInsets.all(16),
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
                  const Icon(Icons.location_on, color: AppColors.primaryPurple, size: 22),
                  const SizedBox(width: 8),
                  Text('Delivery Address', style: AppTextStyles.bold.copyWith(fontSize: 15, color: AppColors.darkText)),
                ],
              ),
              if (controller.hasSavedAddress.value)
                TextButton.icon(
                  onPressed: () => controller.isEditingAddress.value = false,
                  icon: const Icon(Icons.check, size: 15, color: AppColors.primaryPurple),
                  label: Text('Cancel', style: AppTextStyles.bold.copyWith(color: AppColors.primaryPurple, fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 14),
          _buildTextField(label: 'Full name', hint: 'John Doe', icon: Icons.person_outline, controller: controller.fullNameController),
          const SizedBox(height: 10),
          _buildTextField(label: 'Phone', hint: '03001234567', icon: Icons.phone_outlined, controller: controller.phoneController, keyboardType: TextInputType.phone),
          const SizedBox(height: 10),
          _buildTextField(label: 'Address line', hint: 'House, street, area', icon: Icons.home_outlined, controller: controller.addressLineController),
          const SizedBox(height: 10),
          _buildTextField(label: 'City', hint: 'Lahore', icon: Icons.location_city_outlined, controller: controller.cityController),
          const SizedBox(height: 10),
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
              labelStyle: AppTextStyles.medium.copyWith(color: AppColors.hintText, fontSize: 13),
              prefixIcon: const Icon(Icons.map_outlined, color: AppColors.hintText, size: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.primaryPurple, width: 1.5),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            items: const [
              DropdownMenuItem(value: 'Punjab', child: Text('Punjab', style: TextStyle(fontSize: 13))),
              DropdownMenuItem(value: 'Sindh', child: Text('Sindh', style: TextStyle(fontSize: 13))),
              DropdownMenuItem(value: 'Khyber Pakhtunkhwa', child: Text('Khyber Pakhtunkhwa', style: TextStyle(fontSize: 13))),
              DropdownMenuItem(value: 'Balochistan', child: Text('Balochistan', style: TextStyle(fontSize: 13))),
              DropdownMenuItem(value: 'Islamabad (Capital)', child: Text('Islamabad (Capital)', style: TextStyle(fontSize: 13))),
              DropdownMenuItem(value: 'Gilgit-Baltistan & AJK', child: Text('Gilgit-Baltistan & AJK', style: TextStyle(fontSize: 13))),
            ],
            onChanged: (val) {
              if (val != null) {
                controller.provinceController.text = val;
              }
            },
          ),
          const SizedBox(height: 10),
          _buildTextField(label: 'Country', hint: 'Pakistan', icon: Icons.language, controller: controller.countryController),
          const SizedBox(height: 10),
          _buildTextField(label: 'Postal code', hint: '54000', icon: Icons.numbers, controller: controller.postalCodeController, keyboardType: TextInputType.number),
          const SizedBox(height: 14),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: controller.isDefaultAddress.value,
            onChanged: (val) => controller.isDefaultAddress.value = val ?? false,
            activeColor: AppColors.primaryPurple,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text('Set as default address', style: AppTextStyles.medium.copyWith(fontSize: 13)),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryPurple,
                side: const BorderSide(color: AppColors.primaryPurple, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                await controller.saveAddress();
              },
              icon: const Icon(Icons.save_outlined, size: 16),
              label: const Text('Save Address Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection(CheckoutController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
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
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primaryPurple, size: 18),
              ),
              const SizedBox(width: 10),
              Text('Payment Method', style: AppTextStyles.bold.copyWith(fontSize: 15, color: AppColors.darkText)),
            ],
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => controller.selectedPaymentMethod.value = 'COD',
            child: Container(
              padding: const EdgeInsets.all(14),
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
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.local_shipping_outlined,
                      color: AppColors.primaryPurple,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cash on Delivery (COD)', style: AppTextStyles.bold.copyWith(fontSize: 14, color: AppColors.darkText)),
                        const SizedBox(height: 2),
                        Text('Pay cash when order arrives at your doorstep', style: AppTextStyles.regular.copyWith(fontSize: 11.5, color: AppColors.hintText)),
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
      padding: const EdgeInsets.all(16),
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
              const Icon(Icons.receipt_long, color: AppColors.primaryPurple, size: 20),
              const SizedBox(width: 8),
              Text('Order Summary', style: AppTextStyles.bold.copyWith(fontSize: 15, color: AppColors.darkText)),
            ],
          ),
          const SizedBox(height: 14),
          ...controller.selectedItems.map((item) {
            final imageUrl = item.image;
            final name = item.name;
            final quantity = item.quantity;
            final price = item.price;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(width: 48, height: 48, color: Colors.grey.shade100, child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 18)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: AppTextStyles.medium.copyWith(fontSize: 13, color: AppColors.darkText), maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text('Qty $quantity', style: AppTextStyles.medium.copyWith(fontSize: 11.5, color: AppColors.primaryPurple)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('Rs. ${price * quantity}', style: AppTextStyles.bold.copyWith(fontSize: 13.5, color: AppColors.darkText)),
                ],
              ),
            );
          }),
          const Divider(height: 24),
          Column(
            children: [
              _buildSummaryRow('Subtotal', 'Rs. ${controller.summary['subtotal']}'),
              const SizedBox(height: 6),
              _buildSummaryRow('Shipping', 'Rs. ${controller.summary['shipping']}'),
              if ((controller.summary['tax'] ?? 0) > 0) ...[
                const SizedBox(height: 6),
                _buildSummaryRow('Tax', 'Rs. ${controller.summary['tax']}'),
              ],
              if ((controller.summary['discount'] ?? 0) > 0) ...[
                const SizedBox(height: 6),
                _buildSummaryRow('Discount', '- Rs. ${controller.summary['discount']}'),
              ],
              const SizedBox(height: 12),
              _buildSummaryRow('Total', 'Rs. ${controller.summary['total']}', isTotal: true),
            ],
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
          style: isTotal ? AppTextStyles.bold.copyWith(fontSize: 15, color: AppColors.darkText) : AppTextStyles.medium.copyWith(fontSize: 13, color: AppColors.hintText),
        ),
        Text(
          value,
          style: isTotal ? AppTextStyles.extraBold.copyWith(fontSize: 16, color: AppColors.primaryPurple) : AppTextStyles.bold.copyWith(fontSize: 13.5, color: AppColors.darkText),
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
        Text(label, style: AppTextStyles.bold.copyWith(fontSize: 12.5, color: AppColors.darkText)),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: AppTextStyles.medium.copyWith(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.regular.copyWith(color: AppColors.hintText, fontSize: 13),
            prefixIcon: Icon(icon, color: AppColors.hintText, size: 18),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}
