import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/return_controller.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';

class ReturnRequestScreen extends StatefulWidget {
  const ReturnRequestScreen({super.key});

  @override
  State<ReturnRequestScreen> createState() => _ReturnRequestScreenState();
}

class _ReturnRequestScreenState extends State<ReturnRequestScreen> {
  final _ibanController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountHolderController = TextEditingController();
  final _reasonController = TextEditingController();
  
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _ibanController.dispose();
    _bankNameController.dispose();
    _accountHolderController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = Get.arguments ?? {};
    final String orderId = args['orderId'] ?? '';
    final String orderItemId = args['orderItemId'] ?? '';
    final int quantity = args['quantity'] ?? 1;

    final controller = Get.put(ReturnController());
    final profileCtrl = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text('Return Request', style: AppTextStyles.bold.copyWith(color: AppColors.darkText, fontSize: 18)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.primaryPurple),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Please provide your bank details below for the refund process. Ensure the details match the account holder.',
                        style: AppTextStyles.medium.copyWith(fontSize: 13, color: AppColors.primaryPurple),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              Text('Reason for Return', style: AppTextStyles.semiBold.copyWith(color: AppColors.darkText)),
              const SizedBox(height: 8),
              AppTextField(
                controller: _reasonController,
                hintText: 'e.g. Damaged, Wrong Item',
                prefixIcon: const Icon(Icons.help_outline),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              
              Text('Bank Name', style: AppTextStyles.semiBold.copyWith(color: AppColors.darkText)),
              const SizedBox(height: 8),
              AppTextField(
                controller: _bankNameController,
                hintText: 'e.g. UBL, Meezan Bank',
                prefixIcon: const Icon(Icons.account_balance_outlined),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              Text('Account Holder Name', style: AppTextStyles.semiBold.copyWith(color: AppColors.darkText)),
              const SizedBox(height: 8),
              AppTextField(
                controller: _accountHolderController,
                hintText: 'Full Name on Account',
                prefixIcon: const Icon(Icons.person_outline),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              Text('IBAN Number', style: AppTextStyles.semiBold.copyWith(color: AppColors.darkText)),
              const SizedBox(height: 8),
              AppTextField(
                controller: _ibanController,
                hintText: 'PK36... (24 characters)',
                prefixIcon: const Icon(Icons.numbers_outlined),
                validator: (v) => v!.length < 16 ? 'Valid IBAN required' : null,
              ),
              const SizedBox(height: 32),

              AppButton(
                text: 'Submit Request',
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    controller.submitReturnRequest(
                      orderId: orderId,
                      orderItemId: orderItemId,
                      name: profileCtrl.userName.value,
                      email: profileCtrl.userEmail.value,
                      phone: '00000000000', // Need phone from profile or order
                      iban: _ibanController.text,
                      accountHolderName: _accountHolderController.text,
                      bankName: _bankNameController.text,
                      reason: _reasonController.text,
                      quantity: quantity,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
