import 'package:get/get.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/utils/custom_popup.dart';
import '../../../../core/utils/session_manager.dart';
import '../../../order/presentation/controllers/order_controller.dart';
import 'package:flutter/material.dart';

import 'dart:convert';

import 'package:dio/dio.dart' as dio;

class ReturnController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  
  final RxBool isLoading = false.obs;
  final RxList<dynamic> buyerReturnRequests = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchBuyerReturnRequests();
  }

  Future<void> fetchBuyerReturnRequests() async {
    try {
      isLoading.value = true;
      final response = await _apiClient.dio.get(ApiEndpoints.getBuyerReturnRequests);
      
      if (response.data['success'] == true) {
        buyerReturnRequests.value = response.data['data'] ?? [];
      }
    } catch (e) {
      debugPrint('Error fetching buyer return requests: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitReturnRequest({
    required String orderId,
    required String orderItemId,
    required String name,
    required String email,
    required String phone,
    required String iban,
    required String accountHolderName,
    required String bankName,
    required String reason,
    required int quantity,
  }) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    if (cleanPhone.length != 11) {
      CustomPopup.showToast('Validation Error', 'Phone number must be exactly 11 digits (e.g. 03001234567)', isError: true);
      return;
    }
    try {
      CustomPopup.showLoading('Submitting return request...');
      
      final formData = dio.FormData.fromMap({
        'name': name,
        'email': email,
        'IBAN_Number': iban,
        'orderId': orderId,
        'phone': phone,
        'accountHolderName': accountHolderName,
        'Bank_Name': bankName,
        'items': jsonEncode([
          {
            'orderItemId': orderItemId,
            'quantity': quantity,
            'reason': reason,
          }
        ]),
        // 'images': [], // Will implement images picker later if requested
      });
      
      final response = await _apiClient.dio.post(
        ApiEndpoints.createReturnRequest,
        data: formData,
        options: dio.Options(validateStatus: (status) => true),
      );

      CustomPopup.hideLoading();

      final data = response.data;
      final bool isSuccess = (response.statusCode == 200 || response.statusCode == 201) &&
          (data == null || data['success'] != false);

      if (isSuccess) {
        await SessionManager.markReturned(orderId);
        if (Get.isRegistered<OrderController>()) {
          Get.find<OrderController>().fetchMyOrders();
        }
        CustomPopup.showSuccess('Success', 'Return request submitted successfully!');
        Get.back(); // close the form
        fetchBuyerReturnRequests(); // Refresh list
      } else {
        final errorMsg = (data is Map && data['message'] != null)
            ? data['message'].toString()
            : (data is Map && data['error'] != null)
                ? data['error'].toString()
                : 'Failed to submit return request. Please verify your details.';
        CustomPopup.showError('Return Failed', errorMsg);
      }
    } catch (e) {
      CustomPopup.hideLoading();
      final err = (e is dio.DioException && e.response?.data is Map && e.response?.data['message'] != null)
          ? e.response?.data['message'].toString()
          : 'Could not submit return request. Please try again.';
      CustomPopup.showError('Error', err ?? 'An error occurred. Please try again.');
      debugPrint('Error submitting return: $e');
    }
  }
}
