import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:add_to_cart_animation/add_to_cart_animation.dart';
import '../../../../core/utils/session_manager.dart';
import '../../../../core/utils/custom_popup.dart';

class MainLayoutController extends GetxController {
  final RxInt currentIndex = 0.obs;
  
  GlobalKey<CartIconKey> cartKey = GlobalKey<CartIconKey>();
  late Function(GlobalKey) runAddToCartAnimation;

  void changePage(int index) {
    // If trying to access Cart (2) or Profile (3) and not logged in
    if ((index == 2 || index == 3) && !SessionManager.isLoggedIn) {
      CustomPopup.showLoginRequired();
      return;
    }
    currentIndex.value = index;
  }
}
