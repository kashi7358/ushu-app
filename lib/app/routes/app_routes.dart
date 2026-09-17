import 'package:get/get.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/authentication/presentation/screens/signup_screen.dart';
import '../../features/authentication/presentation/screens/otp_screen.dart';
import '../../features/authentication/presentation/screens/forget_password_screen.dart';
import '../../features/authentication/presentation/screens/reset_password_screen.dart';
import '../../features/main_layout/presentation/screens/main_layout_screen.dart';
import '../../features/home/presentation/screens/product_detail_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String signup = '/signup';
  static const String otp = '/otp';
  static const String forgetPassword = '/forget-password';
  static const String resetPassword = '/reset-password';
  static const String mainLayout = '/main';
  static const String productDetail = '/product-detail';

  static final routes = [
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: signup, page: () => const SignupScreen()),
    GetPage(name: otp, page: () => const OtpScreen()),
    GetPage(name: forgetPassword, page: () => const ForgetPasswordScreen()),
    GetPage(name: resetPassword, page: () => const ResetPasswordScreen()),
    GetPage(name: mainLayout, page: () => const MainLayoutScreen()),
    GetPage(name: productDetail, page: () => const ProductDetailScreen()),
  ];
}
