import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/utils/custom_popup.dart';
import '../../../../core/utils/session_manager.dart';
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

  final selectedItems = <dynamic>[].obs;
  final summary = {
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
      final response = await _apiClient.dio.get(ApiEndpoints.checkout);
      final data = response.data;
      if (data != null && data['success'] == true) {
        final resData = data['data'] ?? data; // Depending on backend wrapper
        
        // Items
        if (resData['selectedItems'] != null) {
          selectedItems.value = resData['selectedItems'];
        }
        
        // Summary
        if (resData['summary'] != null) {
          summary.value = {
            'subtotal': resData['summary']['subtotal'] ?? 0,
            'shipping': resData['summary']['shipping'] ?? 0,
            'tax': resData['summary']['tax'] ?? 0,
            'discount': resData['summary']['discount'] ?? 0,
            'total': resData['summary']['total'] ?? 0,
          };
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
      }
    } catch (e) {
      print('Checkout GET API error: $e');
      CustomPopup.showToast('Error', 'Failed to fetch checkout details', isError: true);
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
          // Sending items list just in case backend expects it, but usually backend resolves cart internally
        },
        options: Options(validateStatus: (status) => true),
      );

      final data = response.data;
      if (data != null && data['success'] == true) {
        CustomPopup.showFastLottie('assets/lotties/done.json');
        cartController.fetchCart(); // refresh cart after order
        Get.offAllNamed('/main');
        CustomPopup.showToast('Success', 'Order Placed Successfully!');
      } else {
        CustomPopup.showToast('Failed', data['message'] ?? 'Could not place order', isError: true);
      }
    } catch (e) {
      CustomPopup.showToast('Error', 'An error occurred while placing order', isError: true);
    } finally {
      isLoading.value = false;
    }
  }
}
