import 'package:get/get.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/authentication/presentation/screens/signup_screen.dart';
import '../../features/authentication/presentation/screens/otp_screen.dart';
import '../../features/authentication/presentation/screens/forget_password_screen.dart';
import '../../features/main_layout/presentation/screens/main_layout_screen.dart';
import '../../features/home/presentation/screens/product_detail_screen.dart';
import '../../features/store/presentation/screens/store_screen.dart';
import '../../features/wishlist/presentation/screens/wishlist_screen.dart';
import '../../features/order/presentation/screens/my_orders_screen.dart';
import '../../features/profile/presentation/screens/contact_us_screen.dart';
import '../../features/profile/presentation/screens/privacy_policy_screen.dart';
import '../../features/profile/presentation/screens/about_us_screen.dart';
import '../../features/review/presentation/screens/write_review_screen.dart';
import '../../features/checkout/presentation/screens/checkout_screen.dart';
import '../../features/returns/presentation/screens/my_returns_screen.dart';
import '../../features/returns/presentation/screens/return_request_screen.dart';
import '../../features/seller/presentation/screens/seller_login_screen.dart';
import '../../features/seller/presentation/screens/seller_register_screen.dart';
import '../../features/seller/presentation/screens/seller_otp_screen.dart';
import '../../features/seller/presentation/screens/create_store_screen.dart';
import '../../features/seller/presentation/screens/seller_pending_approval_screen.dart';
import '../../features/seller/presentation/screens/seller_forget_password_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String signup = '/signup';
  static const String otp = '/otp';
  static const String forgetPassword = '/forget-password';
  static const String mainLayout = '/main';
  static const String productDetail = '/product-detail';
  static const String store = '/store';
  static const String wishlist = '/wishlist';
  static const String changePassword = '/change-password';
  static const String search = '/search';
  static const String myOrders = '/my-orders';
  static const String contactUs = '/contact-us';
  static const String writeReview = '/write-review';
  static const String checkout = '/checkout';
  static const String myReturns = '/my-returns';
  static const String returnRequest = '/return-request';
  static const String privacyPolicy = '/privacy-policy';
  static const String aboutUs = '/about-us';

  // Seller Routes
  static const String sellerLogin = '/seller/login';
  static const String sellerRegister = '/seller/register';
  static const String sellerOtp = '/seller/otp';
  static const String sellerForgetPassword = '/seller/forget-password';
  static const String sellerCreateStore = '/seller/create-store';
  static const String sellerPendingApproval = '/seller/pending-approval';

  static final routes = [
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: signup, page: () => const SignupScreen()),
    GetPage(name: otp, page: () => const OtpScreen()),
    GetPage(name: forgetPassword, page: () => const ForgetPasswordScreen()),
    GetPage(name: mainLayout, page: () => const MainLayoutScreen()),
    GetPage(name: productDetail, page: () => const ProductDetailScreen()),
    GetPage(name: store, page: () => const StoreScreen()),
    GetPage(name: wishlist, page: () => const WishlistScreen()),
    GetPage(name: myOrders, page: () => const MyOrdersScreen()),
    GetPage(name: contactUs, page: () => const ContactUsScreen()),
    GetPage(name: writeReview, page: () => const WriteReviewScreen()),
    GetPage(name: checkout, page: () => const CheckoutScreen()),
    GetPage(name: myReturns, page: () => const MyReturnsScreen()),
    GetPage(name: returnRequest, page: () => const ReturnRequestScreen()),
    GetPage(name: privacyPolicy, page: () => const PrivacyPolicyScreen()),
    GetPage(name: aboutUs, page: () => const AboutUsScreen()),
    GetPage(name: sellerLogin, page: () => const SellerLoginScreen()),
    GetPage(name: sellerRegister, page: () => const SellerRegisterScreen()),
    GetPage(name: sellerOtp, page: () => const SellerOtpScreen()),
    GetPage(name: sellerForgetPassword, page: () => const SellerForgetPasswordScreen()),
    GetPage(name: sellerCreateStore, page: () => const CreateStoreScreen()),
    GetPage(name: sellerPendingApproval, page: () => const SellerPendingApprovalScreen()),
  ];
}
