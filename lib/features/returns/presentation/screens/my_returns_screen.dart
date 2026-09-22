import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../controllers/return_controller.dart';

class MyReturnsScreen extends StatelessWidget {
  const MyReturnsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReturnController());

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('My Returns', style: AppTextStyles.bold.copyWith(color: AppColors.darkText, fontSize: 18)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryPurple));
        }

        if (controller.buyerReturnRequests.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.assignment_return_rounded, size: 72, color: AppColors.primaryPurple),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No returns yet',
                    style: AppTextStyles.extraBold.copyWith(fontSize: 22, color: AppColors.darkText),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You have not requested any returns or refunds. Your return history will appear here.',
                    style: AppTextStyles.medium.copyWith(color: AppColors.hintText, fontSize: 14, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  AppButton(
                    text: 'Start Shopping',
                    onPressed: () {
                      Get.offAllNamed('/main');
                    },
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.buyerReturnRequests.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final request = controller.buyerReturnRequests[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order #${request['orderId']?.toString().substring(0, 8) ?? 'Unknown'}',
                        style: AppTextStyles.bold.copyWith(fontSize: 14, color: AppColors.darkText),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          request['status'] ?? 'Requested',
                          style: AppTextStyles.bold.copyWith(fontSize: 12, color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(),
                  ),
                  Text(
                    'Reason: ${request['reason'] ?? 'N/A'}',
                    style: AppTextStyles.medium.copyWith(fontSize: 13, color: AppColors.darkText),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
