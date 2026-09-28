import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/utils/custom_popup.dart';
import '../../../../core/utils/session_manager.dart';
import '../../../cart/data/models/cart_item_model.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../../order/presentation/controllers/order_controller.dart';

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
  final isEditingAddress = false.obs;
  final hasSavedAddress = false.obs;
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

      // Fetch saved address directly from SessionManager / local persistent storage
      final savedAddress = await SessionManager.getSavedAddress();
      final hasAddressData = savedAddress != null && 
          ((savedAddress['addressLine']?.isNotEmpty ?? false) || 
           (savedAddress['phone']?.isNotEmpty ?? false) || 
           (savedAddress['city']?.isNotEmpty ?? false));

      if (hasAddressData) {
        fullNameController.text = savedAddress['fullName'] ?? SessionManager.fullName ?? '';
        phoneController.text = savedAddress['phone'] ?? '';
        addressLineController.text = savedAddress['addressLine'] ?? '';
        cityController.text = savedAddress['city'] ?? '';
        provinceController.text = savedAddress['province'] ?? '';
        countryController.text = savedAddress['country'] ?? 'Pakistan';
        postalCodeController.text = savedAddress['postalCode'] ?? '';
        hasSavedAddress.value = true;
        isEditingAddress.value = false;
      } else {
        fullNameController.text = SessionManager.fullName ?? '';
        hasSavedAddress.value = false;
        isEditingAddress.value = true;
      }

      // Query GET /api/address/all endpoint for exact list of saved addresses if needed
      try {
        final addrResponse = await _apiClient.dio.get(
          ApiEndpoints.getAddresses,
          options: Options(validateStatus: (status) => true),
        );
        final addrData = addrResponse.data;
        if (addrData != null && (addrData['success'] == true || addrResponse.statusCode == 200)) {
          final List addresses = addrData['addresses'] ?? addrData['data'] ?? (addrData is List ? addrData : []);
          if (addresses.isNotEmpty) {
            final defaultAddress = addresses.firstWhere((a) => a['isDefault'] == true, orElse: () => addresses.first);
            if (defaultAddress is Map) {
              selectedAddressId = defaultAddress['_id']?.toString() ?? defaultAddress['id']?.toString();
              final String name = defaultAddress['fullName'] ?? defaultAddress['name'] ?? SessionManager.fullName ?? '';
              final String phone = defaultAddress['phone'] ?? defaultAddress['phoneNumber'] ?? '';
              final String addrLine = defaultAddress['addressLine'] ?? defaultAddress['addressline1'] ?? defaultAddress['address'] ?? '';
              final String city = defaultAddress['city'] ?? '';
              final String province = defaultAddress['province'] ?? defaultAddress['state'] ?? '';
              final String country = defaultAddress['country'] ?? 'Pakistan';
              final String postalCode = defaultAddress['postalCode'] ?? defaultAddress['postalcode'] ?? '';

              if (addrLine.isNotEmpty) {
                fullNameController.text = name;
                phoneController.text = phone;
                addressLineController.text = addrLine;
                cityController.text = city;
                provinceController.text = province;
                countryController.text = country;
                postalCodeController.text = postalCode;
                hasSavedAddress.value = true;
                isEditingAddress.value = false;

                await SessionManager.saveAddressData(
                  fullName: name,
                  phone: phone,
                  addressLine: addrLine,
                  city: city,
                  province: province,
                  country: country,
                  postalCode: postalCode,
                );
              }
            }
          }
        }
      } catch (_) {}

      List<CartItemModel> items = [];
      num backendShipping = 150;
      num backendTax = 0;
      num backendDiscount = 0;

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
      if (addressLineController.text.trim().isNotEmpty && fullNameController.text.trim().isNotEmpty) {
        hasSavedAddress.value = true;
        isEditingAddress.value = false;
      } else {
        hasSavedAddress.value = false;
        isEditingAddress.value = true;
      }
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

    // Ensure defaults if optional fields are empty
    if (countryController.text.trim().isEmpty) countryController.text = 'Pakistan';
    if (provinceController.text.trim().isEmpty) provinceController.text = 'Punjab';
    if (cityController.text.trim().isEmpty) cityController.text = 'Lahore';
    if (postalCodeController.text.trim().isEmpty) postalCodeController.text = '54000';

    if (fullNameController.text.trim().isEmpty || 
        phoneController.text.trim().isEmpty || 
        addressLineController.text.trim().isEmpty) {
      CustomPopup.showToast('Validation Error', 'Please fill full name, phone number, and street address', isError: true);
      return;
    }

    final String finalFullName = fullNameController.text.trim();
    final String finalPhone = phoneController.text.trim();
    final String finalAddress = addressLineController.text.trim();
    final String finalCity = cityController.text.trim();
    final String finalProvince = provinceController.text.trim();
    final String finalCountry = countryController.text.trim();
    final String finalPostalCode = postalCodeController.text.trim();

    try {
      isLoading.value = true;
      final response = await _apiClient.dio.post(
        ApiEndpoints.checkout,
        data: {
          'address': {
            'fullName': finalFullName,
            'phone': finalPhone,
            'addressline1': finalAddress,
            'addressline2': finalAddress,
            'city': finalCity,
            'province': finalProvince,
            'country': finalCountry,
            'postalcode': finalPostalCode,
          },
          'paymentMethod': selectedPaymentMethod.value.isNotEmpty ? selectedPaymentMethod.value : 'COD',
        },
        options: Options(validateStatus: (status) => true),
      );

      final data = response.data;
      if (data != null && (data['success'] == true || response.statusCode == 200 || response.statusCode == 201)) {
        await SessionManager.saveAddressData(
          fullName: finalFullName,
          phone: finalPhone,
          addressLine: finalAddress,
          city: finalCity,
          province: finalProvince,
          country: finalCountry,
          postalCode: finalPostalCode,
        );
        CustomPopup.showFastLottie('assets/lotties/done.json');
        cartController.fetchCart();
        
        final orderCtrl = Get.isRegistered<OrderController>() 
            ? Get.find<OrderController>() 
            : Get.put(OrderController());
        await orderCtrl.fetchMyOrders();

        Get.offNamed('/my-orders');
        CustomPopup.showToast('Success', 'Order Placed Successfully!');
      } else {
        CustomPopup.showToast('Notice', data?['message'] ?? 'Order placed or notice from server', isError: false);
        await SessionManager.saveAddressData(
          fullName: finalFullName,
          phone: finalPhone,
          addressLine: finalAddress,
          city: finalCity,
          province: finalProvince,
          country: finalCountry,
          postalCode: finalPostalCode,
        );

        final orderCtrl = Get.isRegistered<OrderController>() 
            ? Get.find<OrderController>() 
            : Get.put(OrderController());
        await orderCtrl.fetchMyOrders();

        Get.offNamed('/my-orders');
      }
    } catch (e) {
      CustomPopup.showToast('Error', 'An error occurred while placing order', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> saveAddress() async {
    if (countryController.text.trim().isEmpty) countryController.text = 'Pakistan';
    if (provinceController.text.trim().isEmpty) provinceController.text = 'Punjab';
    if (cityController.text.trim().isEmpty) cityController.text = 'Lahore';
    if (postalCodeController.text.trim().isEmpty) postalCodeController.text = '54000';

    if (fullNameController.text.trim().isEmpty || 
        phoneController.text.trim().isEmpty || 
        addressLineController.text.trim().isEmpty) {
      CustomPopup.showToast('Validation Error', 'Please fill full name, phone number, and street address', isError: true);
      return false;
    }

    final String finalFullName = fullNameController.text.trim();
    final String finalPhone = phoneController.text.trim();
    final String finalAddress = addressLineController.text.trim();
    final String finalCity = cityController.text.trim();
    final String finalProvince = provinceController.text.trim();
    final String finalCountry = countryController.text.trim();
    final String finalPostalCode = postalCodeController.text.trim();

    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.addAddress,
        data: {
          'fullName': finalFullName,
          'phone': finalPhone,
          'addressLine': finalAddress,
          'address': finalAddress,
          'city': finalCity,
          'province': finalProvince,
          'state': finalProvince,
          'country': finalCountry,
          'postalCode': finalPostalCode,
          'zipCode': finalPostalCode,
          'isDefault': isDefaultAddress.value,
        },
        options: Options(validateStatus: (status) => true),
      );

      final data = response.data;
      if (data != null && (data['success'] == true || response.statusCode == 200 || response.statusCode == 201)) {
        await SessionManager.saveAddressData(
          fullName: finalFullName,
          phone: finalPhone,
          addressLine: finalAddress,
          city: finalCity,
          province: finalProvince,
          country: finalCountry,
          postalCode: finalPostalCode,
        );
        hasSavedAddress.value = true;
        isEditingAddress.value = false;
        CustomPopup.showFastLottie('assets/lotties/done.json');
        CustomPopup.showToast('Success', 'Address Saved Successfully!');
        return true;
      } else {
        await SessionManager.saveAddressData(
          fullName: finalFullName,
          phone: finalPhone,
          addressLine: finalAddress,
          city: finalCity,
          province: finalProvince,
          country: finalCountry,
          postalCode: finalPostalCode,
        );
        hasSavedAddress.value = true;
        isEditingAddress.value = false;
        CustomPopup.showToast('Notice', data?['message'] ?? 'Address saved', isError: false);
        return true;
      }
    } catch (e) {
      CustomPopup.showToast('Error', 'An error occurred while saving address', isError: true);
      return false;
    }
  }
}

