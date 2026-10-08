import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/create_store_controller.dart';
import '../widgets/seller_step_indicator.dart';

class CreateStoreScreen extends StatelessWidget {
  const CreateStoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreateStoreController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: controller.previousStep,
        ),
        title: Text(
          'Setup Your Store',
          style: AppTextStyles.bold.copyWith(color: AppColors.darkText, fontSize: 17),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Step Progress Indicator
            Obx(
              () => SellerStepIndicator(
                currentStep: controller.currentStep.value,
                steps: const ['Branding', 'Contact', 'Policies'],
              ),
            ),
            const Divider(height: 1),

            // Step Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Obx(() {
                  switch (controller.currentStep.value) {
                    case 0:
                      return _buildStep1Branding(context, controller);
                    case 1:
                      return _buildStep2Contact(controller);
                    case 2:
                    default:
                      return _buildStep3Policies(controller);
                  }
                }),
              ),
            ),

            // Bottom Navigation Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Obx(() {
                final isLastStep = controller.currentStep.value == 2;
                return SizedBox(
                  height: 46,
                  child: Row(
                    children: [
                      if (controller.currentStep.value > 0) ...[
                        Expanded(
                          flex: 1,
                          child: OutlinedButton(
                            onPressed: controller.previousStep,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryPurple,
                              side: const BorderSide(color: AppColors.primaryPurple, width: 1.2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: Text(
                              'Back',
                              style: AppTextStyles.bold.copyWith(color: AppColors.primaryPurple, fontSize: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        flex: controller.currentStep.value > 0 ? 2 : 1,
                        child: ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : (isLastStep ? controller.createStore : controller.nextStep),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryPurple,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  isLastStep ? 'Create Store' : 'Next Step',
                                  style: AppTextStyles.bold.copyWith(color: Colors.white, fontSize: 14),
                                ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // STEP 1: Branding & Basic Information
  Widget _buildStep1Branding(BuildContext context, CreateStoreController controller) {
    return Form(
      key: controller.step1FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoBanner(),
          const SizedBox(height: 20),

          _buildSectionHeader(
            title: 'Store Branding',
            subtitle: 'Upload your store logo and banner image',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Obx(() => _buildImageUploadTile(
                  title: 'Store Logo *',
                  subtitle: 'Tap to upload',
                  imagePath: controller.logoPath.value,
                  isCircle: true,
                  onTap: () => _showPickerSheet(context, (src) => controller.pickImage(isLogo: true, source: src)),
                  onRemove: () => controller.removeImage(isLogo: true),
                )),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Obx(() => _buildImageUploadTile(
                  title: 'Store Banner *',
                  subtitle: 'Tap to upload',
                  imagePath: controller.storeBannerPath.value,
                  isCircle: false,
                  onTap: () => _showPickerSheet(context, (src) => controller.pickImage(isLogo: false, source: src)),
                  onRemove: () => controller.removeImage(isLogo: false),
                )),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildSectionHeader(
            title: 'Store Profile',
            subtitle: 'Basic identity of your online store',
          ),
          const SizedBox(height: 16),
          _buildLabel('Store Name *'),
          AppTextField(
            controller: controller.storeNameController,
            hintText: 'Enter store name',
            prefixIcon: const Icon(Icons.storefront_outlined, color: AppColors.primaryPurple, size: 22),
            validator: (val) => val == null || val.trim().isEmpty ? 'Store name is required' : null,
          ),
          const SizedBox(height: 16),
          _buildLabel('Store Tagline *'),
          AppTextField(
            controller: controller.storeTaglineController,
            hintText: 'Enter store tagline',
            prefixIcon: const Icon(Icons.label_important_outline, color: AppColors.primaryPurple, size: 22),
            validator: (val) => val == null || val.trim().isEmpty ? 'Tagline is required' : null,
          ),
          const SizedBox(height: 16),
          _buildLabel('Description *'),
          AppTextField(
            controller: controller.descriptionController,
            hintText: 'Describe your store and products',
            maxLines: 3,
            prefixIcon: const Icon(Icons.description_outlined, color: AppColors.primaryPurple, size: 22),
            validator: (val) => val == null || val.trim().isEmpty ? 'Description is required' : null,
          ),
          const SizedBox(height: 16),
          _buildLabel('Language *'),
          Obx(() => _buildSelectionDropdown(
            value: controller.selectedLanguage.value,
            items: controller.languages,
            prefixIcon: Icons.language_outlined,
            onChanged: (val) {
              if (val != null) controller.setLanguage(val);
            },
          )),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // STEP 2: Contact & Warehouse Address
  Widget _buildStep2Contact(CreateStoreController controller) {
    return Form(
      key: controller.step2FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: 'Contact Details',
            subtitle: 'Customer support communication channels',
          ),
          const SizedBox(height: 16),
          _buildLabel('Store Contact Email *'),
          AppTextField(
            controller: controller.storeContactEmailController,
            hintText: 'Enter contact email',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primaryPurple, size: 22),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Contact email is required';
              if (!GetUtils.isEmail(val.trim())) return 'Enter a valid email address';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildLabel('Store WhatsApp *'),
          AppTextField(
            controller: controller.storeWhatsappController,
            hintText: 'Enter WhatsApp number',
            keyboardType: TextInputType.phone,
            prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.primaryPurple, size: 22),
            validator: (val) => val == null || val.trim().isEmpty ? 'WhatsApp number is required' : null,
          ),
          const SizedBox(height: 24),

          _buildSectionHeader(
            title: 'Warehouse & Location',
            subtitle: 'Dispatch center and social presence',
          ),
          const SizedBox(height: 16),
          _buildLabel('Primary City *'),
          AppTextField(
            controller: controller.primaryCityController,
            hintText: 'Enter primary city',
            prefixIcon: const Icon(Icons.location_city_outlined, color: AppColors.primaryPurple, size: 22),
            validator: (val) => val == null || val.trim().isEmpty ? 'City is required' : null,
          ),
          const SizedBox(height: 16),
          _buildLabel('Warehouse Address *'),
          AppTextField(
            controller: controller.warehouseAddressController,
            hintText: 'Enter warehouse address',
            prefixIcon: const Icon(Icons.warehouse_outlined, color: AppColors.primaryPurple, size: 22),
            validator: (val) => val == null || val.trim().isEmpty ? 'Warehouse address is required' : null,
          ),
          const SizedBox(height: 16),
          _buildLabel('Social Links (Optional)'),
          AppTextField(
            controller: controller.socialLinksController,
            hintText: 'e.g. https://instagram.com/yourstore',
            prefixIcon: const Icon(Icons.link_outlined, color: AppColors.primaryPurple, size: 22),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // STEP 3: Policies & Shipping
  Widget _buildStep3Policies(CreateStoreController controller) {
    return Form(
      key: controller.step3FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: 'Policies & Fulfillment',
            subtitle: 'Return, warranty, and order handling rules',
          ),
          const SizedBox(height: 16),
          _buildLabel('Return Policy *'),
          Obx(() => _buildSelectionDropdown(
            value: controller.selectedReturnPolicy.value,
            items: controller.returnPolicies,
            prefixIcon: Icons.assignment_return_outlined,
            onChanged: (val) {
              if (val != null) controller.setReturnPolicy(val);
            },
          )),
          const SizedBox(height: 16),
          _buildLabel('Warranty *'),
          Obx(() => _buildSelectionDropdown(
            value: controller.selectedWarranty.value,
            items: controller.warranties,
            prefixIcon: Icons.verified_user_outlined,
            onChanged: (val) {
              if (val != null) controller.setWarranty(val);
            },
          )),
          const SizedBox(height: 16),
          _buildLabel('Processing Time *'),
          Obx(() => _buildSelectionDropdown(
            value: controller.selectedProcessingTime.value,
            items: controller.processingTimes,
            prefixIcon: Icons.timer_outlined,
            onChanged: (val) {
              if (val != null) controller.setProcessingTime(val);
            },
          )),
          const SizedBox(height: 16),
          _buildLabel('Cancellation Policy *'),
          Obx(() => _buildSelectionDropdown(
            value: controller.selectedCancellationPolicy.value,
            items: controller.cancellationPolicies,
            prefixIcon: Icons.cancel_outlined,
            onChanged: (val) {
              if (val != null) controller.setCancellationPolicy(val);
            },
          )),
          const SizedBox(height: 24),

          _buildSectionHeader(
            title: 'Shipping Configuration',
            subtitle: 'Courier and delivery zone pricing',
          ),
          const SizedBox(height: 16),
          _buildLabel('Shipping Method *'),
          Obx(() => _buildSelectionDropdown(
            value: controller.selectedShippingMethod.value,
            items: controller.shippingMethods,
            prefixIcon: Icons.local_shipping_outlined,
            onChanged: (val) {
              if (val != null) controller.setShippingMethod(val);
            },
          )),
          const SizedBox(height: 16),
          _buildLabel('Delivery Zones *'),
          Obx(() => _buildSelectionDropdown(
            value: controller.selectedDeliveryZone.value,
            items: controller.deliveryZonesList,
            prefixIcon: Icons.map_outlined,
            onChanged: (val) {
              if (val != null) controller.setDeliveryZone(val);
            },
          )),
          const SizedBox(height: 16),
          _buildLabel('Shipping Charges (PKR) *'),
          AppTextField(
            controller: controller.shippingChargesController,
            hintText: 'Enter shipping charges',
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(Icons.attach_money_outlined, color: AppColors.primaryPurple, size: 22),
            validator: (val) => val == null || val.trim().isEmpty ? 'Shipping charge is required' : null,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // Helpers
  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryPurple.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.primaryPurple, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Some fields have been automatically filled from your signup details.',
              style: AppTextStyles.medium.copyWith(fontSize: 12.5, color: AppColors.primaryPurple),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.bold.copyWith(fontSize: 15.5, color: AppColors.darkText),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: AppTextStyles.medium.copyWith(fontSize: 12, color: AppColors.hintText),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: AppTextStyles.bold.copyWith(fontSize: 13, color: AppColors.darkText),
      ),
    );
  }

  Widget _buildImageUploadTile({
    required String title,
    required String subtitle,
    required String? imagePath,
    required bool isCircle,
    required VoidCallback onTap,
    required VoidCallback onRemove,
  }) {
    final hasImage = imagePath != null && imagePath.isNotEmpty;

    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasImage ? AppColors.primaryPurple : Colors.grey.shade300,
          width: hasImage ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: hasImage
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Image.file(File(imagePath), fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: onRemove,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isCircle ? Icons.add_photo_alternate_outlined : Icons.panorama_outlined,
                      color: AppColors.primaryPurple,
                      size: 28,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      style: AppTextStyles.bold.copyWith(fontSize: 12, color: AppColors.darkText),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.medium.copyWith(fontSize: 10, color: AppColors.hintText),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void _showPickerSheet(BuildContext context, Function(ImageSource) onSelected) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_photo_alternate_rounded, color: AppColors.primaryPurple, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Select Image Source',
                      style: AppTextStyles.bold.copyWith(fontSize: 15, color: AppColors.darkText),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close, size: 20, color: AppColors.hintText),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Choose an option to capture or select image',
                  style: AppTextStyles.medium.copyWith(fontSize: 12.5, color: AppColors.hintText),
                ),
              ),
              const SizedBox(height: 20),

              // Camera Option
              InkWell(
                onTap: () {
                  Get.back();
                  onSelected(ImageSource.camera);
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryPurple.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt_rounded, color: AppColors.primaryPurple, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Take Photo from Camera',
                              style: AppTextStyles.bold.copyWith(fontSize: 14, color: AppColors.darkText),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Use device camera to capture',
                              style: AppTextStyles.medium.copyWith(fontSize: 11.5, color: AppColors.hintText),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.hintText, size: 14),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Gallery Option
              InkWell(
                onTap: () {
                  Get.back();
                  onSelected(ImageSource.gallery);
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.accentOrange.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.photo_library_rounded, color: AppColors.accentOrange, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Choose from Gallery',
                              style: AppTextStyles.bold.copyWith(fontSize: 14, color: AppColors.darkText),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Select an existing image from gallery',
                              style: AppTextStyles.medium.copyWith(fontSize: 11.5, color: AppColors.hintText),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.hintText, size: 14),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionDropdown({
    required String value,
    required List<String> items,
    required IconData prefixIcon,
    required ValueChanged<String?> onChanged,
  }) {
    final validValue = items.contains(value) ? value : items.first;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: validValue,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.hintText),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Row(
                children: [
                  Icon(prefixIcon, color: AppColors.primaryPurple, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: AppTextStyles.medium.copyWith(fontSize: 14, color: AppColors.darkText),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
