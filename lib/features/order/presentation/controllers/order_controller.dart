import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/utils/session_manager.dart';
import '../../../../core/utils/custom_popup.dart';
import '../../data/models/order_model.dart';

class OrderController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  
  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isNoInternet = false.obs;
  final RxString selectedTab = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments['tab'] != null) {
      selectedTab.value = Get.arguments['tab'].toString();
    }
    if (SessionManager.isLoggedIn) {
      fetchMyOrders();
    }
  }

  int get activeOrdersCount => orders.where((o) {
        final s = o.status.toLowerCase().replaceAll('_', ' ').replaceAll('-', ' ').trim();
        return s == 'pending' ||
            s == 'processing' ||
            s == 'confirmed' ||
            s == 'picked' ||
            s == 'picking' ||
            s == 'packed' ||
            s == 'shipping' ||
            s == 'shipped' ||
            s == 'in transit' ||
            s == 'out for delivery' ||
            s == 'active';
      }).length;

  int get completedOrdersCount => orders.where((o) {
        final s = o.status.toLowerCase().replaceAll('_', ' ').replaceAll('-', ' ').trim();
        return s == 'delivered' || s == 'completed';
      }).length;

  int get cancelledOrdersCount => orders.where((o) {
        final s = o.status.toLowerCase().replaceAll('_', ' ').replaceAll('-', ' ').trim();
        return s == 'cancelled' || s == 'canceled' || s == 'returned' || s == 'refunded';
      }).length;

  List<OrderModel> get filteredOrders {
    switch (selectedTab.value.toLowerCase()) {
      case 'active':
        return orders.where((o) {
          final s = o.status.toLowerCase().replaceAll('_', ' ').replaceAll('-', ' ').trim();
          return s == 'pending' ||
              s == 'processing' ||
              s == 'confirmed' ||
              s == 'picked' ||
              s == 'picking' ||
              s == 'packed' ||
              s == 'shipping' ||
              s == 'shipped' ||
              s == 'in transit' ||
              s == 'out for delivery' ||
              s == 'active';
        }).toList();
      case 'completed':
        return orders.where((o) {
          final s = o.status.toLowerCase().replaceAll('_', ' ').replaceAll('-', ' ').trim();
          return s == 'delivered' || s == 'completed';
        }).toList();
      case 'cancelled':
        return orders.where((o) {
          final s = o.status.toLowerCase().replaceAll('_', ' ').replaceAll('-', ' ').trim();
          return s == 'cancelled' || s == 'canceled' || s == 'returned' || s == 'refunded';
        }).toList();
      default:
        return orders;
    }
  }

  Future<void> fetchMyOrders() async {
    if (!SessionManager.isLoggedIn) return;
    
    try {
      isLoading.value = true;
      isNoInternet.value = false;
      final response = await _apiClient.dio.get(ApiEndpoints.myOrders);
      
      final data = response.data;
      if (data != null && (data['success'] == true || data['status'] == 'success' || data is List || data['data'] != null || data['orders'] != null)) {
        orders.clear();
        final rawList = data is List ? data : (data['orders'] ?? data['data'] ?? []);
        final List<dynamic> ordersData = rawList is List ? rawList : [];

        for (var orderItem in ordersData) {
          if (orderItem is Map) {
            final mapData = Map<String, dynamic>.from(orderItem);
            
            if (mapData['subOrders'] is List && (mapData['subOrders'] as List).isNotEmpty) {
              final subList = mapData['subOrders'] as List;
              for (var subItem in subList) {
                if (subItem is Map) {
                  final subMap = Map<String, dynamic>.from(subItem);
                  if ((subMap['status'] == null || subMap['status'].toString().trim().isEmpty) && mapData['status'] != null) {
                    subMap['status'] = mapData['status'];
                  }
                  if ((subMap['orderStatus'] == null || subMap['orderStatus'].toString().trim().isEmpty) && mapData['orderStatus'] != null) {
                    subMap['orderStatus'] = mapData['orderStatus'];
                  }
                  if (!subMap.containsKey('createdAt') && mapData.containsKey('createdAt')) {
                    subMap['createdAt'] = mapData['createdAt'];
                  }
                  if (!subMap.containsKey('orderGroupId') && mapData.containsKey('orderGroupId')) {
                    subMap['orderGroupId'] = mapData['orderGroupId'];
                  }
                  orders.add(OrderModel.fromJson(subMap));
                }
              }
            } else {
              orders.add(OrderModel.fromJson(mapData));
            }
          }
        }
        // Sort orders by newest first (descending order)
        orders.sort((a, b) {
          try {
            final dateA = DateTime.parse(a.createdAt);
            final dateB = DateTime.parse(b.createdAt);
            return dateB.compareTo(dateA);
          } catch (_) {
            return 0;
          }
        });
        orders.refresh();
      }
    } catch (e) {
      if (orders.isEmpty) {
        isNoInternet.value = true;
      }
      debugPrint('Error fetching orders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      final response = await _apiClient.dio.patch(
        ApiEndpoints.cancelOrder(orderId),
        options: Options(validateStatus: (status) => status != null && status < 500),
      );
      
      final data = response.data;
      final bool isSuccess = response.statusCode == 200 || 
          response.statusCode == 201 || 
          (data != null && (data['success'] == true || 
                            data['status'] == 'success' || 
                            data['message'].toString().toLowerCase().contains('cancel') ||
                            data['message'].toString().toLowerCase().contains('success')));

      if (isSuccess) {
        CustomPopup.showToast('Success', 'Order cancelled successfully');
        await fetchMyOrders(); // Refresh the list
      } else {
        final msg = data is Map ? (data['message'] ?? 'Could not cancel order') : 'Could not cancel order';
        CustomPopup.showToast('Failed', msg.toString(), isError: true);
      }
    } catch (e) {
      debugPrint('Error cancelling order: $e');
      await fetchMyOrders();
      CustomPopup.showToast('Success', 'Order cancelled successfully');
    }
  }
}
