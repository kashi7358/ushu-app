import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_colors.dart';
import '../controllers/main_layout_controller.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../cart/presentation/screens/cart_screen.dart';
import 'package:lottie/lottie.dart';
import '../../../../features/chatbot/presentation/screens/chatbot_screen.dart';

import 'package:add_to_cart_animation/add_to_cart_animation.dart';

class MainLayoutScreen extends StatelessWidget {
  const MainLayoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MainLayoutController());

    final List<Widget> pages = [
      const HomeScreen(),
      const Center(child: Text("Categories")),
      const CartScreen(),
      const ProfileScreen(),
    ];

    return AddToCartAnimation(
      cartKey: controller.cartKey,
      height: 30,
      width: 30,
      opacity: 0.85,
      dragAnimation: const DragToCartAnimationOptions(
        rotation: false,
      ),
      jumpAnimation: const JumpAnimationOptions(active: false),
      createAddToCartAnimation: (runAddToCartAnimation) {
        controller.runAddToCartAnimation = runAddToCartAnimation;
      },
      child: Scaffold(
        body: Obx(() => IndexedStack(
          index: controller.currentIndex.value,
          children: pages,
        )),
        bottomNavigationBar: Obx(
          () => BottomNavigationBar(
            currentIndex: controller.currentIndex.value,
            onTap: controller.changePage,
            selectedItemColor: AppColors.primaryPurple,
            unselectedItemColor: AppColors.hintText,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.grid_view_outlined),
                activeIcon: Icon(Icons.grid_view),
                label: 'Categories',
              ),
              BottomNavigationBarItem(
                icon: AddToCartIcon(
                  key: controller.cartKey,
                  icon: const Icon(Icons.shopping_cart_outlined),
                  badgeOptions: const BadgeOptions(
                    active: false,
                  ),
                ),
                activeIcon: const Icon(Icons.shopping_cart),
                label: 'Cart',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      floatingActionButton: Obx(() {
        if (controller.currentIndex.value != 0) {
          return const SizedBox.shrink();
        }
        
        return Transform.translate(
          offset: const Offset(15, 35), // pushed further right and much closer to the bottom nav
          child: GestureDetector(
            onTap: () {
              Get.to(() => const ChatbotScreen());
            },
            child: SizedBox(
              width: 140,
              height: 140,
              child: Lottie.asset(
                'assets/lotties/chatbot.json',
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      }),
      ),
    );
  }
}
