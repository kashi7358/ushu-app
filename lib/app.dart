import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


import '../core/network/network_controller.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';

import 'features/wishlist/presentation/controllers/wishlist_controller.dart';
import 'features/cart/presentation/controllers/cart_controller.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(NetworkController(), permanent: true);
    Get.put(WishlistController(), permanent: true);
    Get.put(CartController(), permanent: true);
  }
}

class UshuApp extends StatelessWidget {
  const UshuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'USHU',
          theme: AppTheme.lightTheme,
          initialBinding: InitialBindings(),
          initialRoute: AppRoutes.getInitialRoute(),
          getPages: AppRoutes.routes,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
