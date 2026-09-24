import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../controllers/home_controller.dart';

class HomeSlider extends StatefulWidget {
  const HomeSlider({super.key});

  @override
  State<HomeSlider> createState() => _HomeSliderState();
}

class _HomeSliderState extends State<HomeSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isAutoPlaying = true;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted || !_isAutoPlaying) return;
      final controller = Get.find<HomeController>();
      final banners = controller.bannerProducts;
      if (banners.isNotEmpty && _pageController.hasClients) {
        int nextPage = _currentPage + 1;
        if (nextPage >= (banners.length > 5 ? 5 : banners.length)) {
          nextPage = 0;
        }
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.fastOutSlowIn,
        );
      }
      _startAutoPlay();
    });
  }

  @override
  void dispose() {
    _isAutoPlaying = false;
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(() {
      if (controller.isBannerLoading.value && controller.bannerProducts.isEmpty) {
        return Container(
          height: 160,
          margin: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      }

      final banners = controller.bannerProducts;
      if (banners.isEmpty) {
        return Container(
          height: 160,
          margin: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
          decoration: BoxDecoration(
            color: AppColors.primaryPurple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(child: Text("Welcome to Ushu!", style: TextStyle(fontWeight: FontWeight.bold))),
        );
      }

      final itemCount = banners.length > 5 ? 5 : banners.length;

      return Container(
        height: 170,
        margin: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  final product = banners[index];
                  return GestureDetector(
                    onTap: () {
                      if (product.id.isNotEmpty && product.name.isNotEmpty) {
                        Get.toNamed('/product-detail', arguments: product.id);
                      }
                    },
                    child: Image.network(
                      product.image,
                      fit: BoxFit.fill,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image, color: Colors.grey, size: 40),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Dots Indicator Overlaid
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  itemCount,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _currentPage == index ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _currentPage == index ? AppColors.primaryPurple : Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
