import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

class CnicUploadCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? imagePath;
  final Function(ImageSource) onImageSelected;
  final VoidCallback onRemove;

  const CnicUploadCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.onImageSelected,
    required this.onRemove,
  });

  void _showImagePickerDialog(BuildContext context) {
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
                    child: const Icon(Icons.upload_file, color: AppColors.primaryPurple, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Upload $title',
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
                  onImageSelected(ImageSource.camera);
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
                  onImageSelected(ImageSource.gallery);
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
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null && imagePath!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasImage ? AppColors.primaryPurple : Colors.grey.shade300,
          width: hasImage ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showImagePickerDialog(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          hasImage ? Icons.check_circle : Icons.badge_outlined,
                          color: hasImage ? AppColors.success : AppColors.primaryPurple,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          title,
                          style: AppTextStyles.bold.copyWith(fontSize: 14, color: AppColors.darkText),
                        ),
                      ],
                    ),
                    if (hasImage)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: onRemove,
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Required',
                          style: AppTextStyles.medium.copyWith(fontSize: 11, color: AppColors.hintText),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (hasImage)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 140,
                      width: double.infinity,
                      color: Colors.grey.shade100,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(
                            File(imagePath!),
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.refresh, color: Colors.white, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Change',
                                    style: AppTextStyles.medium.copyWith(color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200, style: BorderStyle.solid),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined, color: Colors.grey.shade400, size: 30),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: AppTextStyles.medium.copyWith(fontSize: 12, color: AppColors.hintText),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
