import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/create_product_controller.dart';
import '../widgets/seller_step_indicator.dart';

class CreateProductScreen extends StatelessWidget {
  const CreateProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreateProductController());

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
          'Add New Product',
          style: AppTextStyles.bold.copyWith(color: AppColors.darkText, fontSize: 17),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Step Indicator
            Obx(
              () => SellerStepIndicator(
                currentStep: controller.currentStep.value,
                steps: const ['Basic Info', 'Stock & Price', 'Media & Variants'],
              ),
            ),
            const Divider(height: 1),

            // Step Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Obx(() {
                  switch (controller.currentStep.value) {
                    case 0:
                      return _buildStep1BasicInfo(controller);
                    case 1:
                      return _buildStep2StockAndPricing(controller);
                    case 2:
                    default:
                      return _buildStep3MediaAndVariants(context, controller);
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
                              : (isLastStep ? controller.createProduct : controller.nextStep),
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
                                  isLastStep ? 'Publish Product' : 'Next Step',
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

  // STEP 1: Basic Information
  Widget _buildStep1BasicInfo(CreateProductController controller) {
    return Form(
      key: controller.step1FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: '1. Basic Information',
            subtitle: 'Enter product name, category, brand and details',
          ),
          const SizedBox(height: 16),
          _buildLabel('Product Name *'),
          AppTextField(
            controller: controller.nameController,
            hintText: 'e.g. Wireless Bluetooth Earbuds',
            prefixIcon: const Icon(Icons.shopping_bag_outlined, color: AppColors.primaryPurple, size: 22),
            validator: (val) => val == null || val.trim().isEmpty ? 'Product name is required' : null,
          ),
          const SizedBox(height: 16),
          _buildLabel('Description *'),
          AppTextField(
            controller: controller.descriptionController,
            hintText: 'Detailed product description...',
            maxLines: 3,
            prefixIcon: const Icon(Icons.description_outlined, color: AppColors.primaryPurple, size: 22),
            validator: (val) => val == null || val.trim().isEmpty ? 'Description is required' : null,
          ),
          const SizedBox(height: 16),
          _buildLabel('Category *'),
          Obx(() => _buildSelectionDropdown(
            value: controller.selectedCategory.value,
            items: controller.categories,
            prefixIcon: Icons.category_outlined,
            onChanged: (val) {
              if (val != null) controller.setCategory(val);
            },
          )),
          const SizedBox(height: 16),
          _buildLabel('SubCategory *'),
          AppTextField(
            controller: controller.subCategoryController,
            hintText: 'e.g. Earbuds, Smartwatches, Shoes',
            prefixIcon: const Icon(Icons.account_tree_outlined, color: AppColors.primaryPurple, size: 22),
            validator: (val) => val == null || val.trim().isEmpty ? 'SubCategory is required' : null,
          ),
          const SizedBox(height: 16),
          _buildLabel('Brand *'),
          AppTextField(
            controller: controller.brandController,
            hintText: 'e.g. SoundMax, Apple, Samsung',
            prefixIcon: const Icon(Icons.verified_outlined, color: AppColors.primaryPurple, size: 22),
            validator: (val) => val == null || val.trim().isEmpty ? 'Brand is required' : null,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Condition *'),
                    Obx(() => _buildSelectionDropdown(
                      value: controller.selectedCondition.value,
                      items: controller.conditions,
                      prefixIcon: Icons.check_circle_outline,
                      onChanged: (val) {
                        if (val != null) controller.setCondition(val);
                      },
                    )),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('SKU / Code *'),
                    AppTextField(
                      controller: controller.skuController,
                      hintText: 'EARBUDS_229',
                      prefixIcon: const Icon(Icons.qr_code, color: AppColors.primaryPurple, size: 22),
                      validator: (val) => val == null || val.trim().isEmpty ? 'SKU is required' : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildLabel('Tags (comma-separated) *'),
          AppTextField(
            controller: controller.tagsController,
            hintText: 'wireless, noise-cancellation, bluetooth',
            prefixIcon: const Icon(Icons.tag_outlined, color: AppColors.primaryPurple, size: 22),
            validator: (val) => val == null || val.trim().isEmpty ? 'At least 1 tag is required' : null,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // STEP 2: Stock, Pricing & Dimensions
  Widget _buildStep2StockAndPricing(CreateProductController controller) {
    return Form(
      key: controller.step2FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: '2. Pricing & Inventory',
            subtitle: 'Set selling price, quantity and weight specifications',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Price *'),
                    AppTextField(
                      controller: controller.priceController,
                      hintText: '10000',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.attach_money_outlined, color: AppColors.primaryPurple, size: 22),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Price is required' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Currency'),
                    AppTextField(
                      controller: controller.priceCurrencyController,
                      hintText: 'PKR',
                      readOnly: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Stock Quantity *'),
                    AppTextField(
                      controller: controller.stockController,
                      hintText: '89',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.inventory_2_outlined, color: AppColors.primaryPurple, size: 22),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Stock is required' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Low Stock Alert *'),
                    AppTextField(
                      controller: controller.lowStockThresholdController,
                      hintText: '20',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.warning_amber_outlined, color: AppColors.primaryPurple, size: 22),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Threshold is required' : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(
            () => SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeThumbColor: AppColors.primaryPurple,
              title: Text('Track Inventory', style: AppTextStyles.bold.copyWith(fontSize: 14)),
              subtitle: Text('Manage real-time stock deductions on orders',
                  style: AppTextStyles.medium.copyWith(fontSize: 12, color: AppColors.hintText)),
              value: controller.trackInventory.value,
              onChanged: (val) => controller.trackInventory.value = val,
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionHeader(
            title: 'Package Weight & Dimensions',
            subtitle: 'Required for courier delivery charges estimation',
          ),
          const SizedBox(height: 16),
          _buildLabel('Weight (grams) *'),
          AppTextField(
            controller: controller.weightController,
            hintText: 'e.g. 50',
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(Icons.scale_outlined, color: AppColors.primaryPurple, size: 22),
            validator: (val) => val == null || val.trim().isEmpty ? 'Weight is required' : null,
          ),
          const SizedBox(height: 16),
          _buildLabel('Dimensions (cm) *'),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: controller.lengthController,
                  hintText: 'Length',
                  keyboardType: TextInputType.number,
                  validator: (val) => val == null || val.trim().isEmpty ? 'Req' : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppTextField(
                  controller: controller.widthController,
                  hintText: 'Width',
                  keyboardType: TextInputType.number,
                  validator: (val) => val == null || val.trim().isEmpty ? 'Req' : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppTextField(
                  controller: controller.heightController,
                  hintText: 'Height',
                  keyboardType: TextInputType.number,
                  validator: (val) => val == null || val.trim().isEmpty ? 'Req' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // STEP 3: Media & Variants
  Widget _buildStep3MediaAndVariants(BuildContext context, CreateProductController controller) {
    return Form(
      key: controller.step3FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: '3. Media & Product Photos',
            subtitle: 'Upload product showcase pictures and video',
          ),
          const SizedBox(height: 16),
          _buildLabel('Product Images * (At least 1 required)'),
          Obx(() {
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ...controller.imagePaths.asMap().entries.map((entry) {
                  final index = entry.key;
                  final path = entry.value;
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(path),
                          width: 85,
                          height: 85,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => controller.removeProductImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                InkWell(
                  onTap: () => _showPickerModal(
                    context,
                    title: 'Add Product Image',
                    onCamera: () => controller.pickProductImages(source: ImageSource.camera),
                    onGallery: () => controller.pickProductImages(source: ImageSource.gallery),
                  ),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 85,
                    height: 85,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primaryPurple, width: 1.2),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined, color: AppColors.primaryPurple, size: 26),
                        SizedBox(height: 4),
                        Text('Add Photo', style: TextStyle(fontSize: 11, color: AppColors.primaryPurple, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 20),

          // Video Upload
          _buildLabel('Product Video (Optional)'),
          Obx(() {
            final hasVideo = controller.videoPath.value != null;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(
                    hasVideo ? Icons.videocam : Icons.video_call_outlined,
                    color: hasVideo ? AppColors.primaryPurple : AppColors.hintText,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      hasVideo
                          ? controller.videoPath.value!.split(Platform.pathSeparator).last
                          : 'Tap to select product demonstration video',
                      style: AppTextStyles.medium.copyWith(
                        fontSize: 12.5,
                        color: hasVideo ? AppColors.darkText : AppColors.hintText,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (hasVideo)
                    IconButton(
                      icon: const Icon(Icons.close, size: 18, color: Colors.red),
                      onPressed: controller.removeVideo,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    )
                  else
                    TextButton(
                      onPressed: controller.pickVideo,
                      child: const Text('Upload', style: TextStyle(color: AppColors.primaryPurple, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),

          _buildSectionHeader(
            title: 'Variants & Attributes',
            subtitle: 'Colors, Sizes or specific product variations',
          ),
          const SizedBox(height: 16),
          _buildLabel('Add Variants (e.g. Black, White, 128GB)'),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: controller.variantController,
                  hintText: 'Enter variant name',
                  prefixIcon: const Icon(Icons.palette_outlined, color: AppColors.primaryPurple, size: 22),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: controller.addVariant,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                child: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Obx(() {
            if (controller.variantsList.isEmpty) {
              return Text('No variants added yet', style: AppTextStyles.medium.copyWith(fontSize: 12, color: AppColors.hintText));
            }
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.variantsList.asMap().entries.map((entry) {
                final index = entry.key;
                final variant = entry.value;
                return Chip(
                  backgroundColor: AppColors.primaryPurple.withValues(alpha: 0.1),
                  label: Text(variant, style: const TextStyle(color: AppColors.primaryPurple, fontWeight: FontWeight.w600)),
                  deleteIcon: const Icon(Icons.close, size: 16, color: AppColors.primaryPurple),
                  onDeleted: () => controller.removeVariant(index),
                );
              }).toList(),
            );
          }),
          const SizedBox(height: 16),
          _buildLabel('Variant Attributes Description (Optional)'),
          AppTextField(
            controller: controller.variantAttributes1Controller,
            hintText: 'e.g. Color variation details',
            prefixIcon: const Icon(Icons.tune_outlined, color: AppColors.primaryPurple, size: 22),
          ),
          const SizedBox(height: 16),

          _buildLabel('Variant Images (Optional)'),
          Obx(() {
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ...controller.variantImagePaths.asMap().entries.map((entry) {
                  final index = entry.key;
                  final path = entry.value;
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(path),
                          width: 75,
                          height: 75,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => controller.removeVariantImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                InkWell(
                  onTap: () => _showPickerModal(
                    context,
                    title: 'Variant Image',
                    onCamera: () => controller.pickVariantImage(source: ImageSource.camera),
                    onGallery: () => controller.pickVariantImage(source: ImageSource.gallery),
                  ),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined, color: AppColors.hintText, size: 22),
                        SizedBox(height: 4),
                        Text('Variant', style: TextStyle(fontSize: 10, color: AppColors.hintText)),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Helpers
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

  void _showPickerModal(
    BuildContext context, {
    required String title,
    required VoidCallback onCamera,
    required VoidCallback onGallery,
  }) {
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
                      title,
                      style: AppTextStyles.bold.copyWith(fontSize: 15, color: AppColors.darkText),
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
              const SizedBox(height: 20),
              InkWell(
                onTap: () {
                  Get.back();
                  onCamera();
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
                            Text('Take Photo from Camera', style: AppTextStyles.bold.copyWith(fontSize: 14)),
                            const SizedBox(height: 2),
                            Text('Use device camera to capture', style: AppTextStyles.medium.copyWith(fontSize: 11.5, color: AppColors.hintText)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  Get.back();
                  onGallery();
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
                            Text('Choose from Gallery', style: AppTextStyles.bold.copyWith(fontSize: 14)),
                            const SizedBox(height: 2),
                            Text('Select images from phone gallery', style: AppTextStyles.medium.copyWith(fontSize: 11.5, color: AppColors.hintText)),
                          ],
                        ),
                      ),
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
