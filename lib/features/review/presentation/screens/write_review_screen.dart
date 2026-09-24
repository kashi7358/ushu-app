import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../controllers/write_review_controller.dart';

class WriteReviewScreen extends StatelessWidget {
  const WriteReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WriteReviewController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Write Review', style: AppTextStyles.bold.copyWith(fontSize: 18, color: AppColors.darkText)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Overall Rating', style: AppTextStyles.bold.copyWith(fontSize: 16, color: AppColors.darkText)),
            const SizedBox(height: 12),
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () => controller.setRating(index + 1),
                  icon: Icon(
                    index < controller.rating.value ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: index < controller.rating.value ? Colors.amber : Colors.grey.shade400,
                    size: 40,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                );
              }),
            )),
            const SizedBox(height: 24),
            Text('Add a Headline', style: AppTextStyles.bold.copyWith(fontSize: 16, color: AppColors.darkText)),
            const SizedBox(height: 8),
            TextField(
              controller: controller.titleController,
              decoration: InputDecoration(
                hintText: 'What is most important to know?',
                hintStyle: AppTextStyles.regular.copyWith(color: AppColors.hintText),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primaryPurple)),
              ),
            ),
            const SizedBox(height: 24),
            Text('Add a Written Review', style: AppTextStyles.bold.copyWith(fontSize: 16, color: AppColors.darkText)),
            const SizedBox(height: 8),
            TextField(
              controller: controller.bodyController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'What did you like or dislike?',
                hintStyle: AppTextStyles.regular.copyWith(color: AppColors.hintText),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primaryPurple)),
              ),
            ),
            const SizedBox(height: 24),
            Text('Add Photos', style: AppTextStyles.bold.copyWith(fontSize: 16, color: AppColors.darkText)),
            const SizedBox(height: 8),
            Obx(() => Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                InkWell(
                  onTap: controller.pickImages,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add_a_photo_outlined, color: AppColors.primaryPurple, size: 30),
                  ),
                ),
                ...List.generate(controller.selectedImages.length, (index) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          controller.selectedImages[index],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: -5,
                        top: -5,
                        child: IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () => controller.removeImage(index),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            )),
            const SizedBox(height: 40),
            Obx(() => AppButton(
              text: 'Submit Review',
              isLoading: controller.isLoading.value,
              onPressed: controller.submitReview,
            )),
          ],
        ),
      ),
    );
  }
}
