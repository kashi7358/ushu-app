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
      );

      CustomPopup.hideLoading();

      if (response.statusCode == 200 || response.statusCode == 201 || (response.data != null && response.data['success'] == true)) {
        await SessionManager.markReturned(orderId);
        if (Get.isRegistered<OrderController>()) {
          Get.find<OrderController>().fetchMyOrders();
        }
        CustomPopup.showSuccess('Success', 'Return request submitted successfully!');
        Get.back(); // close the form
        fetchBuyerReturnRequests(); // Refresh list
      } else {
        CustomPopup.showError('Error', 'Failed to submit return request');
      }
    } catch (e) {
      CustomPopup.hideLoading();
      CustomPopup.showError('Error', 'An error occurred. Please try again.');
      debugPrint('Error submitting return: $e');
    }
  }
}
