import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../controllers/categories_controller.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CategoriesController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text('Categories', style: AppTextStyles.bold.copyWith(color: AppColors.darkText, fontSize: 18)),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryPurple));
        }

        if (controller.categoriesList.isEmpty) {
          return Center(
            child: Text('No Categories Found', style: AppTextStyles.medium.copyWith(color: AppColors.hintText)),
          );
        }

        return Row(
          children: [
            // Left Sidebar
            Container(
              width: 100,
              color: Colors.grey.shade50,
              child: ListView.builder(
                itemCount: controller.categoriesList.length,
                itemBuilder: (context, index) {
                  final cat = controller.categoriesList[index];
                  final isSelected = controller.selectedIndex.value == index;

                  return GestureDetector(
                    onTap: () => controller.selectedIndex.value = index,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.transparent,
                        border: Border(
                          left: BorderSide(
                            color: isSelected ? AppColors.primaryPurple : Colors.transparent,
                            width: 4,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: AppColors.primaryPurple.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.network(
                                cat.image,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 24, color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            cat.category,
                            textAlign: TextAlign.center,
                            style: isSelected
                                ? AppTextStyles.bold.copyWith(fontSize: 11, color: AppColors.primaryPurple)
                                : AppTextStyles.medium.copyWith(fontSize: 11, color: AppColors.darkText),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Right Content Area
            Expanded(
              child: Container(
                color: Colors.white,
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.categoriesList[controller.selectedIndex.value].category,
                              style: AppTextStyles.bold.copyWith(fontSize: 16, color: AppColors.darkText),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${controller.categoriesList[controller.selectedIndex.value].productCount} Products Available',
                              style: AppTextStyles.medium.copyWith(fontSize: 12, color: AppColors.hintText),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final subCat = controller.categoriesList[controller.selectedIndex.value].subCategories[index];
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: InkWell(
                                onTap: () {
                                  // Can navigate to product list by subcategory later
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.category, color: AppColors.primaryPurple, size: 32),
                                    const SizedBox(height: 12),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Text(
                                        subCat,
                                        textAlign: TextAlign.center,
                                        style: AppTextStyles.semiBold.copyWith(fontSize: 12, color: AppColors.darkText),
                                        maxLines: 2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          childCount: controller.categoriesList[controller.selectedIndex.value].subCategories.length,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
