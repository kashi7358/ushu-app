import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio;
import 'dart:io';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/utils/custom_popup.dart';
import '../../../../core/utils/session_manager.dart';
import '../../../order/presentation/controllers/order_controller.dart';

class WriteReviewController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  final ImagePicker _picker = ImagePicker();

  final rating = 0.obs;
  final titleController = TextEditingController();
  final bodyController = TextEditingController();
  final selectedImages = <File>[].obs;

  final isLoading = false.obs;
  
  late String productId;
  late String orderId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      productId = args['productId']?.toString() ?? '';
      orderId = args['orderId']?.toString() ?? '';
    } else {
      productId = '';
      orderId = '';
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    bodyController.dispose();
    super.onClose();
  }

  void setRating(int value) {
    rating.value = value;
  }

  Future<void> pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(imageQuality: 70);
      if (images.isNotEmpty) {
        selectedImages.addAll(images.map((img) => File(img.path)));
      }
    } catch (e) {
      CustomPopup.showToast('Error', 'Could not pick images', isError: true);
    }
  }

  void removeImage(int index) {
    selectedImages.removeAt(index);
  }

  Future<void> submitReview() async {
    if (rating.value == 0) {
      CustomPopup.showToast('Validation Error', 'Please give a rating', isError: true);
      return;
    }
    if (titleController.text.trim().isEmpty) {
      CustomPopup.showToast('Validation Error', 'Please enter a title', isError: true);
      return;
    }
    if (bodyController.text.trim().isEmpty) {
      CustomPopup.showToast('Validation Error', 'Please enter your review', isError: true);
      return;
    }

    try {
      isLoading.value = true;
      
      final formData = dio.FormData.fromMap({
        'rating': rating.value,
        'title': titleController.text.trim(),
        'body': bodyController.text.trim(),
        'orderId': orderId,
      });

      for (var file in selectedImages) {
        formData.files.add(MapEntry(
          'images',
          await dio.MultipartFile.fromFile(file.path, filename: file.path.split(RegExp(r'[/\\]')).last),
        ));
      }

      final response = await _apiClient.dio.post(
        ApiEndpoints.createReview(productId),
        data: formData,
        options: dio.Options(
          validateStatus: (status) => true,
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      final data = response.data;
      final String msg = (data?['message'] ?? '').toString();
      final bool isSuccess = response.statusCode == 200 ||
          response.statusCode == 201 ||
          (data != null && (data['success'] == true || data['status'] == 'success'));

      if (isSuccess) {
        await SessionManager.markReviewed(orderId, productId);

        if (Get.isRegistered<OrderController>()) {
          Get.find<OrderController>().fetchMyOrders();
        }

        CustomPopup.showToast('Success', 'Review submitted successfully!');
        
        Get.until((route) => Get.currentRoute == '/my-orders' || Get.currentRoute == '/main');
        if (Get.currentRoute != '/my-orders') {
          Get.offNamed('/my-orders');
        }
      } else if (msg.toLowerCase().contains('already reviewed') || msg.toLowerCase().contains('already review')) {
        await SessionManager.markReviewed(orderId, productId);

        if (Get.isRegistered<OrderController>()) {
          Get.find<OrderController>().fetchMyOrders();
        }

        CustomPopup.showToast('Notice', 'You have already reviewed this product for this order.');

        Get.until((route) => Get.currentRoute == '/my-orders' || Get.currentRoute == '/main');
        if (Get.currentRoute != '/my-orders') {
          Get.offNamed('/my-orders');
        }
      } else {
        CustomPopup.showToast('Failed', msg.isNotEmpty ? msg : 'Could not submit review', isError: true);
      }
    } catch (e) {
      CustomPopup.showToast('Error', 'An error occurred while submitting review', isError: true);
    } finally {
      isLoading.value = false;
    }
  }
}
