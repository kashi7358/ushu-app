import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/seller_register_controller.dart';
import '../widgets/cnic_upload_card.dart';
import '../widgets/seller_step_indicator.dart';

class SellerRegisterScreen extends StatelessWidget {
  const SellerRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SellerRegisterController());

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
          'Become a Seller',
          style: AppTextStyles.bold.copyWith(color: AppColors.darkText, fontSize: 17),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            Obx(() => SellerStepIndicator(currentStep: controller.currentStep.value)),
            const Divider(height: 1),

            // Step Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Obx(() {
                  switch (controller.currentStep.value) {
                    case 0:
                      return _buildStep1Account(controller);
                    case 1:
                      return _buildStep2Business(context, controller);
                    case 2:
                    default:
                      return _buildStep3BankAndVerification(context, controller);
                  }
                }),
              ),
            ),

            // Bottom Action Bar
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
                              : (isLastStep ? controller.submitRegistration : controller.nextStep),
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
                                  isLastStep ? 'Submit Application' : 'Next Step',
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

  // STEP 1: Account Information
  Widget _buildStep1Account(SellerRegisterController controller) {
    return Form(
      key: controller.step1FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: 'Seller Account Details',
            subtitle: 'Provide your personal and login credentials',
          ),
          const SizedBox(height: 20),
          _buildLabel('Full Name *'),
          AppTextField(
            controller: controller.fullNameController,
            hintText: 'Enter full name',
            prefixIcon: const Icon(Icons.person_outline, color: AppColors.primaryPurple, size: 22),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Full Name is required';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildLabel('Display Name *'),
          AppTextField(
            controller: controller.displayNameController,
            hintText: 'Enter display name',
            prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.primaryPurple, size: 22),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Display Name is required';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildLabel('Email Address *'),
          AppTextField(
            controller: controller.emailController,
            hintText: 'Enter email address',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primaryPurple, size: 22),
            validator: Validators.validateEmail,
          ),
          const SizedBox(height: 16),
          _buildLabel('Phone Number *'),
          AppTextField(
            controller: controller.phoneController,
            hintText: 'Enter phone number',
            keyboardType: TextInputType.phone,
            maxLength: 11,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
            prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.primaryPurple, size: 22),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Phone number is required';
              if (val.trim().length != 11) return 'Phone number must be exactly 11 digits';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildLabel('Password *'),
          Obx(() => AppTextField(
            controller: controller.passwordController,
            hintText: 'Enter password',
            isPassword: !controller.isPasswordVisible.value,
            validator: Validators.validatePassword,
            prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryPurple, size: 22),
            suffixIcon: IconButton(
              icon: Icon(
                controller.isPasswordVisible.value
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.hintText,
                size: 20,
              ),
              onPressed: controller.togglePasswordVisibility,
            ),
          )),
          const SizedBox(height: 16),
          _buildLabel('Confirm Password *'),
          Obx(() => AppTextField(
            controller: controller.confirmPasswordController,
            hintText: 'Confirm password',
            isPassword: !controller.isConfirmPasswordVisible.value,
            validator: (val) {
              if (val == null || val.isEmpty) return 'Please confirm your password';
              if (val != controller.passwordController.text) return 'Passwords do not match';
              return null;
            },
            prefixIcon: const Icon(Icons.lock_reset_outlined, color: AppColors.primaryPurple, size: 22),
            suffixIcon: IconButton(
              icon: Icon(
                controller.isConfirmPasswordVisible.value
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.hintText,
                size: 20,
              ),
              onPressed: controller.toggleConfirmPasswordVisibility,
            ),
          )),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // STEP 2: Store & Business Details
  Widget _buildStep2Business(BuildContext context, SellerRegisterController controller) {
    return Form(
      key: controller.step2FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: 'Store & Business Profile',
            subtitle: 'Provide details about your store, location, and sales',
          ),
          const SizedBox(height: 20),
          _buildLabel('Store Name *'),
          AppTextField(
            controller: controller.storeNameController,
            hintText: 'Enter store name',
            prefixIcon: const Icon(Icons.storefront_outlined, color: AppColors.primaryPurple, size: 22),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Store Name is required';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildLabel('Business Type *'),
          Obx(() => _buildSelectionDropdown(
            value: controller.selectedBusinessType.value,
            items: controller.businessTypes,
            prefixIcon: Icons.business_outlined,
            onChanged: (val) {
              if (val != null) controller.setBusinessType(val);
            },
          )),
          const SizedBox(height: 16),
          _buildLabel('Province *'),
          Obx(() => _buildSelectionDropdown(
            value: controller.selectedProvince.value,
            items: controller.provinces,
            prefixIcon: Icons.map_outlined,
            onChanged: (val) {
              if (val != null) controller.setProvince(val);
            },
          )),
          const SizedBox(height: 16),
          _buildLabel('City *'),
          AppTextField(
            controller: controller.cityController,
            hintText: 'Enter city',
            prefixIcon: const Icon(Icons.location_city_outlined, color: AppColors.primaryPurple, size: 22),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'City is required';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildLabel('Business Address *'),
          AppTextField(
            controller: controller.businessAddressController,
            hintText: 'Enter business address',
            prefixIcon: const Icon(Icons.pin_drop_outlined, color: AppColors.primaryPurple, size: 22),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Business Address is required';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildLabel('Monthly Sales Estimate *'),
          Obx(() => _buildSelectionDropdown(
            value: controller.selectedMonthlySalesEstimate.value,
            items: controller.salesEstimates,
            prefixIcon: Icons.trending_up_outlined,
            onChanged: (val) {
              if (val != null) controller.setMonthlySalesEstimate(val);
            },
          )),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // STEP 3: Bank & Identity Verification
  Widget _buildStep3BankAndVerification(BuildContext context, SellerRegisterController controller) {
    return Form(
      key: controller.step3FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: 'Bank & Identity Verification',
            subtitle: 'Payout information and CNIC verification for legal compliance',
          ),
          const SizedBox(height: 20),
          _buildLabel('Bank Name *'),
          Obx(() => _buildSelectionDropdown(
            value: controller.selectedBankName.value,
            items: controller.popularBanks,
            prefixIcon: Icons.account_balance_outlined,
            onChanged: (val) {
              if (val != null) controller.setBankName(val);
            },
          )),
          const SizedBox(height: 16),
          _buildLabel('Account Holder Name *'),
          AppTextField(
            controller: controller.accountHolderController,
            hintText: 'Enter account holder name',
            prefixIcon: const Icon(Icons.person_pin_outlined, color: AppColors.primaryPurple, size: 22),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Account Holder Name is required';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildLabel('IBAN Number *'),
          AppTextField(
            controller: controller.ibanController,
            hintText: 'Enter IBAN number',
            prefixIcon: const Icon(Icons.numbers_outlined, color: AppColors.primaryPurple, size: 22),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'IBAN Number is required';
              if (val.trim().length < 16) return 'Enter a valid IBAN number';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildLabel('CNIC Number (13 digits) *'),
          AppTextField(
            controller: controller.cnicController,
            hintText: 'Enter 13-digit CNIC',
            keyboardType: TextInputType.number,
            maxLength: 13,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(13),
            ],
            prefixIcon: const Icon(Icons.credit_card_outlined, color: AppColors.primaryPurple, size: 22),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'CNIC Number is required';
              final cleaned = val.replaceAll(RegExp(r'[^0-9]'), '');
              if (cleaned.length != 13) return 'CNIC must be exactly 13 digits';
              return null;
            },
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(
            title: 'CNIC Document Photos *',
            subtitle: 'Upload clear photos of both sides of your national ID card',
          ),
          const SizedBox(height: 16),
          Obx(() => CnicUploadCard(
            title: 'CNIC Front Photo',
            subtitle: 'Take photo or upload front side',
            imagePath: controller.cnicFrontPhotoPath.value,
            onImageSelected: (source) => controller.pickCnicImage(isFront: true, source: source),
            onRemove: () => controller.removeCnicImage(isFront: true),
          )),
          const SizedBox(height: 16),
          Obx(() => CnicUploadCard(
            title: 'CNIC Back Photo',
            subtitle: 'Take photo or upload back side',
            imagePath: controller.cnicBackPhotoPath.value,
            onImageSelected: (source) => controller.pickCnicImage(isFront: false, source: source),
            onRemove: () => controller.removeCnicImage(isFront: false),
          )),
          const SizedBox(height: 24),
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
          style: AppTextStyles.bold.copyWith(fontSize: 18, color: AppColors.darkText),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: AppTextStyles.medium.copyWith(fontSize: 13, color: AppColors.hintText),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: AppTextStyles.bold.copyWith(fontSize: 13.5, color: AppColors.darkText),
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
