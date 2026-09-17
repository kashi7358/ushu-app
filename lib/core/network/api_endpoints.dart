class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://ecombackend.ushu.pk/api';
  
  static const String registerBuyer = '$baseUrl/buyer/register';
  static const String loginBuyer = '$baseUrl/buyer/login';
  static const String verifyEmail = '$baseUrl/buyer/verify-email';
  static const String resendOtp = '$baseUrl/buyer/resend-otp';
  static const String forgetPassword = '$baseUrl/buyer/forget-password';
  static const String resetPassword = '$baseUrl/buyer/reset';
  static const String allHomepageProducts = 'https://ecombackend.ushu.pk/api/product/all-homepage';
  static const String singleProduct = 'https://ecombackend.ushu.pk/api/product/single/';
  static const String flashSale = 'https://ecombackend.ushu.pk/api/flashSale/active';
  static const String trendingProducts = 'https://ecombackend.ushu.pk/api/product/trending';
  static const String homeBanner = 'https://ecombackend.ushu.pk/api/banner/homepage';
  static const String chatMessage = 'https://ecombackend.ushu.pk/api/chat/message';
  static const String addToCart = 'https://ecombackend.ushu.pk/api/cart/add';
  static const String getCart = 'https://ecombackend.ushu.pk/api/cart/all';
  static String removeCartItem(String itemId) => 'https://ecombackend.ushu.pk/api/cart/items/$itemId';
  static String updateCartQuantity(String itemId) => 'https://ecombackend.ushu.pk/api/cart/quantity/$itemId';
  static const String selectCartItem = 'https://ecombackend.ushu.pk/api/cart/select';
}
