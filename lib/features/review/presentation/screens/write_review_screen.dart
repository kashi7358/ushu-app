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
            Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    final isSelected = index < controller.rating.value;
                    return GestureDetector(
                      onTap: () => controller.setRating(index + 1),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(
                          isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: isSelected ? const Color(0xFFFFB800) : Colors.grey.shade300,
                          size: 38,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 6),
                Text(
                  controller.ratingLabel,
                  style: TextStyle(
                    color: controller.rating.value > 0 ? AppColors.primaryPurple : AppColors.hintText,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
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
                hintText: 'What did you like or dislike about this product?',
                hintStyle: AppTextStyles.regular.copyWith(color: AppColors.hintText),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primaryPurple)),
              ),
            ),
            const SizedBox(height: 24),
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Add Photos', style: AppTextStyles.bold.copyWith(fontSize: 16, color: AppColors.darkText)),
                Text(
                  '${controller.selectedImages.length}/5 photos',
                  style: AppTextStyles.medium.copyWith(fontSize: 12, color: AppColors.hintText),
                ),
              ],
            )),
            const SizedBox(height: 8),
            Obx(() => Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                if (controller.selectedImages.length < 5)
                  InkWell(
                    onTap: controller.pickImages,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_outlined, color: AppColors.primaryPurple, size: 28),
                          SizedBox(height: 4),
                          Text('Upload', style: TextStyle(color: AppColors.primaryPurple, fontSize: 11, fontWeight: FontWeight.w600)),
                        ],
                      ),
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
                        right: 4,
                        top: 4,
                        child: GestureDetector(
                          onTap: () => controller.removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 12),
                          ),
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
