import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/utils/custom_popup.dart';
import '../../../../core/utils/session_manager.dart';
import '../../../cart/data/models/cart_item_model.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';

class CheckoutController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  final CartController cartController = Get.find<CartController>();

  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressLineController = TextEditingController();
  final cityController = TextEditingController();
  final provinceController = TextEditingController();
  final countryController = TextEditingController(text: 'Pakistan');
  final postalCodeController = TextEditingController();

  final isDefaultAddress = false.obs;
  final selectedPaymentMethod = 'COD'.obs;
  final isLoading = false.obs;
  final isFetching = true.obs;

  final selectedItems = <CartItemModel>[].obs;
  final summary = <String, dynamic>{
    'subtotal': 0,
    'shipping': 0,
    'tax': 0,
    'discount': 0,
    'total': 0,
  }.obs;

  String? selectedAddressId;

  @override
  void onInit() {
    super.onInit();
    fetchCheckoutData();
  }

  Future<void> fetchCheckoutData() async {
    try {
      isFetching.value = true;

      if (cartController.cartItems.isEmpty) {
        await cartController.fetchCart();
      }

      final response = await _apiClient.dio.get(
        ApiEndpoints.checkout,
        options: Options(validateStatus: (status) => true),
      );
      
      final data = response.data;
      List<CartItemModel> items = [];
      num backendShipping = 150;
      num backendTax = 0;
      num backendDiscount = 0;

      if (data != null && data['success'] == true) {
        final resData = data['data'] ?? data;
        
        // Parse items if returned by backend
        if (resData['selectedItems'] != null && (resData['selectedItems'] as List).isNotEmpty) {
          for (var raw in resData['selectedItems']) {
            if (raw is Map<String, dynamic>) {
              final productObj = raw['product'] is Map<String, dynamic> ? raw['product'] : {};
              final imageUrl = raw['image'] ?? productObj['image'] ?? (productObj['images'] is List && (productObj['images'] as List).isNotEmpty ? productObj['images'][0] : '');
              
              items.add(CartItemModel(
                id: raw['_id'] ?? raw['id'] ?? '',
                productId: raw['productId'] ?? productObj['_id'] ?? productObj['id'] ?? '',
                name: raw['name'] ?? productObj['name'] ?? productObj['title'] ?? 'Product',
                image: imageUrl,
                price: raw['price'] ?? productObj['price'] ?? 0,
                quantity: raw['quantity'] ?? 1,
                isSelected: true,
              ));
            }
          }
        }
        
        // Parse backend summary hints
        if (resData['summary'] != null && resData['summary'] is Map<String, dynamic>) {
          if (resData['summary']['shipping'] != null && (resData['summary']['shipping'] as num) > 0) {
            backendShipping = resData['summary']['shipping'];
          }
          backendTax = resData['summary']['tax'] ?? 0;
          backendDiscount = resData['summary']['discount'] ?? 0;
        }

        // Addresses
        if (resData['addresses'] != null && (resData['addresses'] as List).isNotEmpty) {
          final List addresses = resData['addresses'];
          final defaultAddress = addresses.firstWhere((a) => a['isDefault'] == true, orElse: () => addresses.first);
          
          selectedAddressId = defaultAddress['_id'];
          fullNameController.text = defaultAddress['fullName'] ?? SessionManager.fullName ?? '';
          phoneController.text = defaultAddress['phone'] ?? '';
          addressLineController.text = defaultAddress['addressLine'] ?? '';
          cityController.text = defaultAddress['city'] ?? '';
          provinceController.text = defaultAddress['province'] ?? '';
          countryController.text = defaultAddress['country'] ?? 'Pakistan';
          postalCodeController.text = defaultAddress['postalCode'] ?? '';
          isDefaultAddress.value = defaultAddress['isDefault'] ?? false;
        } else {
          fullNameController.text = SessionManager.fullName ?? '';
        }
      } else {
        fullNameController.text = SessionManager.fullName ?? '';
      }

      // Fallback to local cart selection if backend returned no selected items
      if (items.isEmpty) {
        final activeCart = cartController.cartItems.where((i) => i.isSelected).toList();
        items = activeCart.isNotEmpty ? activeCart : cartController.cartItems.toList();
      }

      selectedItems.value = items;

      // Calculate exact subtotal & total based on current selected items
      num localSubtotal = 0;
      for (var item in items) {
        localSubtotal += (item.price * item.quantity);
      }

      num finalShipping = localSubtotal > 0 ? backendShipping : 0;
      num finalTotal = localSubtotal + finalShipping + backendTax - backendDiscount;

      summary.value = {
        'subtotal': localSubtotal,
        'shipping': finalShipping,
        'tax': backendTax,
        'discount': backendDiscount,
        'total': finalTotal < 0 ? 0 : finalTotal,
      };
    } catch (e) {
      print('Checkout GET API error: $e');
      fullNameController.text = SessionManager.fullName ?? '';

      final activeCart = cartController.cartItems.where((i) => i.isSelected).toList();
      final items = activeCart.isNotEmpty ? activeCart : cartController.cartItems.toList();
      selectedItems.value = items;

      num localSubtotal = 0;
      for (var item in items) {
        localSubtotal += (item.price * item.quantity);
      }

      summary.value = {
        'subtotal': localSubtotal,
        'shipping': localSubtotal > 0 ? 150 : 0,
        'tax': 0,
        'discount': 0,
        'total': localSubtotal > 0 ? localSubtotal + 150 : 0,
      };
    } finally {
      isFetching.value = false;
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    phoneController.dispose();
    addressLineController.dispose();
    cityController.dispose();
    provinceController.dispose();
    countryController.dispose();
    postalCodeController.dispose();
    super.onClose();
  }

  Future<void> placeOrder() async {
    if (selectedItems.isEmpty) {
      CustomPopup.showToast('Error', 'No items selected for checkout', isError: true);
      return;
    }

    if (fullNameController.text.trim().isEmpty || 
        phoneController.text.trim().isEmpty || 
        addressLineController.text.trim().isEmpty || 
        cityController.text.trim().isEmpty || 
        provinceController.text.trim().isEmpty || 
        countryController.text.trim().isEmpty) {
      CustomPopup.showToast('Validation Error', 'Please fill all required address fields', isError: true);
      return;
    }

    try {
      isLoading.value = true;
      final response = await _apiClient.dio.post(
        ApiEndpoints.checkout,
        data: {
          'fullName': fullNameController.text.trim(),
          'phone': phoneController.text.trim(),
          'addressLine': addressLineController.text.trim(),
          'city': cityController.text.trim(),
          'province': provinceController.text.trim(),
          'country': countryController.text.trim(),
          'postalCode': postalCodeController.text.trim(),
          'isDefault': isDefaultAddress.value,
          'paymentMethod': selectedPaymentMethod.value,
          'items': selectedItems.map((i) => {
            'productId': i.productId,
            'quantity': i.quantity,
            'price': i.price,
            'name': i.name,
          }).toList(),
          'subtotal': summary['subtotal'],
          'shipping': summary['shipping'],
          'total': summary['total'],
        },
        options: Options(validateStatus: (status) => true),
      );

      final data = response.data;
      if (data != null && data['success'] == true) {
        CustomPopup.showFastLottie('assets/lotties/done.json');
        cartController.fetchCart();
        Get.offAllNamed('/main');
        CustomPopup.showToast('Success', 'Order Placed Successfully!');
      } else {
        CustomPopup.showToast('Failed', data?['message'] ?? 'Could not place order', isError: true);
      }
    } catch (e) {
      CustomPopup.showToast('Error', 'An error occurred while placing order', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> saveAddress() async {
    if (fullNameController.text.trim().isEmpty || 
        phoneController.text.trim().isEmpty || 
        addressLineController.text.trim().isEmpty || 
        cityController.text.trim().isEmpty || 
        provinceController.text.trim().isEmpty || 
        countryController.text.trim().isEmpty) {
      CustomPopup.showToast('Validation Error', 'Please fill all required address fields', isError: true);
      return false;
    }

    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.addAddress,
        data: {
          'fullName': fullNameController.text.trim(),
          'phone': phoneController.text.trim(),
          'addressLine': addressLineController.text.trim(),
          'city': cityController.text.trim(),
          'province': provinceController.text.trim(),
          'country': countryController.text.trim(),
          'postalCode': postalCodeController.text.trim(),
          'isDefault': isDefaultAddress.value,
        },
        options: Options(validateStatus: (status) => true),
      );

      final data = response.data;
      if (data != null && data['success'] == true) {
        CustomPopup.showFastLottie('assets/lotties/done.json');
        CustomPopup.showToast('Success', 'Address Saved Successfully!');
        return true;
      } else {
        CustomPopup.showToast('Notice', data?['message'] ?? 'Could not save address', isError: true);
        return false;
      }
    } catch (e) {
      CustomPopup.showToast('Error', 'An error occurred while saving address', isError: true);
      return false;
    }
  }
}

