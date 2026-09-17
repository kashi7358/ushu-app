import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';
import '../core/utils/session_manager.dart';

class UshuApp extends StatelessWidget {
  const UshuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'USHU',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.mainLayout,
      getPages: AppRoutes.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
