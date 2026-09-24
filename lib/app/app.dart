import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';
import '../core/network/network_controller.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(NetworkController(), permanent: true);
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
          initialRoute: AppRoutes.mainLayout,
          getPages: AppRoutes.routes,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
