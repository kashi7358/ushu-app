import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../controllers/profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryPurple,
        title: Text(
          'Profile',
          style: AppTextStyles.bold.copyWith(color: AppColors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          children: [
            const SizedBox(height: AppDimensions.xxl),
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primaryPurple.withOpacity(0.1),
              child: const Icon(Icons.person, size: 50, color: AppColors.primaryPurple),
            ),
            const SizedBox(height: AppDimensions.md),
            Obx(() => Text(
              controller.userName.value,
              style: AppTextStyles.extraBold.copyWith(fontSize: 22),
            )),
            const SizedBox(height: 4),
            Obx(() => Text(
              controller.userEmail.value,
              style: AppTextStyles.regular.copyWith(color: AppColors.hintText),
            )),
            const SizedBox(height: AppDimensions.xxl),
            
            // Logout Button
            ListTile(
              onTap: () {
                Get.dialog(
                  AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.back();
                          controller.logout();
                        },
                        child: const Text('Logout', style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  )
                );
              },
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout, color: AppColors.error),
              ),
              title: Text('Logout', style: AppTextStyles.semiBold.copyWith(color: AppColors.error)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.hintText),
            ),
          ],
        ),
      ),
    );
  }
}
