class ApiEndpoints {
  ApiEndpoints._();

  static const String domain = 'https://ecombackend.ushu.pk';
  static const String baseUrl = '$domain/api';
  
  static const String registerBuyer = '$baseUrl/buyer/register';
  static const String loginBuyer = '$baseUrl/buyer/login';
  static const String verifyEmail = '$baseUrl/buyer/verify-email';
  static const String resendOtp = '$baseUrl/buyer/resend-otp';
  static const String forgetPassword = '$baseUrl/buyer/forget-password';
  static const String resetPassword = '$baseUrl/buyer/reset';

  // Home apis
  static const String allHomepageProducts = '$baseUrl/product/all-homepage';
  static const String singleProduct = '$baseUrl/product/single/';
  static const String flashSale = '$baseUrl/flashSale/active';
  static const String trendingProducts = '$baseUrl/product/trending';
  static const String homeBanner = '$baseUrl/banner/homepage';
  static const String categoriesWithImages = '$baseUrl/category/categories-withImages';
  static const String chatMessage = '$baseUrl/chat/message';
  static const String addToCart = '$baseUrl/cart/add';
  static const String getCart = '$baseUrl/cart/all';
  static String removeCartItem(String itemId) => '$baseUrl/cart/items/$itemId';
  static String updateCartQuantity(String itemId) => '$baseUrl/cart/quantity/$itemId';
  static const String selectCartItem = '$baseUrl/cart/select';
  static String getStore(String id) => '$domain/store/get/$id';
  static const String checkout = '$baseUrl/order/place';
  static const String addAddress = '$baseUrl/address/add';
  static const String getAddresses = '$baseUrl/address/all';

  // Order
  static const String myOrders = '$baseUrl/order/my-orders';
  static String cancelOrder(String orderId) => '$baseUrl/order/cancel/$orderId';

  // Wishlist
  static const String addWishlist = '$baseUrl/wishlist/add';
  static const String getWishlist = '$baseUrl/wishlist/item';
  static String removeWishlist(String productId) => '$baseUrl/wishlist/remove/$productId';

  // Contact
  static const String contactUs = '$baseUrl/contact/sendMessage';

  // Reviews
  static String createReview(String productId) => '$baseUrl/review/create/$productId';
  static String getReviews(String productId) => '$baseUrl/review/all/$productId';
  static String voteReview(String reviewId) => '$baseUrl/review/vote/$reviewId';
  // Returns
  static const String createReturnRequest = '$baseUrl/return/create-request';
  static const String getBuyerReturnRequests = '$baseUrl/return/buyer-request';
  
  // Search
  static String searchKeyword(String keyword) => '$baseUrl/search/keyword?keyword=${Uri.encodeComponent(keyword)}';
}
