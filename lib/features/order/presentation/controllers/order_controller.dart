import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/utils/session_manager.dart';
import '../../../../core/utils/custom_popup.dart';
import '../../data/models/order_model.dart';

class OrderController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  
  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (SessionManager.isLoggedIn) {
      fetchMyOrders();
    }
  }

  Future<void> fetchMyOrders() async {
    if (!SessionManager.isLoggedIn) return;
    
    try {
      isLoading.value = true;
      final response = await _apiClient.dio.get(ApiEndpoints.myOrders);
      
      final data = response.data;
      if (data != null && data['success'] == true) {
        orders.clear();
        final List<dynamic> ordersData = data['orders'] ?? data['data'] ?? [];
        for (var orderJson in ordersData) {
          orders.add(OrderModel.fromJson(orderJson));
        }
      }
    } catch (e) {
      debugPrint('Error fetching orders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      final response = await _apiClient.dio.patch(
        ApiEndpoints.cancelOrder(orderId),
      );
      
      final data = response.data;
      if (data != null && data['success'] == true) {
        CustomPopup.showToast('Success', 'Order cancelled successfully');
        fetchMyOrders(); // Refresh the list
      } else {
        CustomPopup.showToast('Failed', data['message'] ?? 'Could not cancel order', isError: true);
      }
    } catch (e) {
      CustomPopup.showToast('Error', 'An error occurred while cancelling the order.', isError: true);
      debugPrint('Error cancelling order: $e');
    }
  }
}
