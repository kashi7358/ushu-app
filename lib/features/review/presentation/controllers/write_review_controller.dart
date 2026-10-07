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

  static const int maxImages = 5;

  final rating = 0.obs;
  final titleController = TextEditingController();
  final bodyController = TextEditingController();
  final selectedImages = <File>[].obs;

  final isLoading = false.obs;
  
  late String productId;
  late String orderId;

  String get ratingLabel {
    switch (rating.value) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent!';
      default:
        return 'Tap a star to rate';
    }
  }

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

    if (productId.isEmpty || orderId.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CustomPopup.showToast('Error', 'Product or order information is missing', isError: true);
        if (Get.context != null && Navigator.of(Get.context!).canPop()) {
          Get.back();
        }
      });
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
    if (selectedImages.length >= maxImages) {
      CustomPopup.showToast('Limit Reached', 'You can upload up to $maxImages photos only.', isError: true);
      return;
    }
    try {
      final List<XFile> images = await _picker.pickMultiImage(imageQuality: 70);
      if (images.isNotEmpty) {
        final remaining = maxImages - selectedImages.length;
        final toAdd = images.take(remaining).map((img) => File(img.path));
        selectedImages.addAll(toAdd);
        if (images.length > remaining) {
          CustomPopup.showToast('Notice', 'Maximum $maxImages photos allowed. First $remaining were added.');
        }
      }
    } catch (e) {
      CustomPopup.showToast('Error', 'Could not pick images', isError: true);
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < selectedImages.length) {
      selectedImages.removeAt(index);
    }
  }

  Future<void> submitReview() async {
    if (rating.value == 0) {
      CustomPopup.showToast('Validation Error', 'Please select a star rating', isError: true);
      return;
    }
    if (titleController.text.trim().isEmpty) {
      CustomPopup.showToast('Validation Error', 'Please enter a review headline', isError: true);
      return;
    }
    if (bodyController.text.trim().isEmpty) {
      CustomPopup.showToast('Validation Error', 'Please write your review', isError: true);
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
        
        _navigateBack();
      } else if (msg.toLowerCase().contains('already reviewed') || msg.toLowerCase().contains('already review')) {
        await SessionManager.markReviewed(orderId, productId);

        if (Get.isRegistered<OrderController>()) {
          Get.find<OrderController>().fetchMyOrders();
        }

        CustomPopup.showToast('Notice', 'You have already reviewed this product for this order.');

        _navigateBack();
      } else {
        CustomPopup.showToast('Failed', msg.isNotEmpty ? msg : 'Could not submit review', isError: true);
      }
    } catch (e) {
      CustomPopup.showToast('Error', 'An error occurred while submitting review', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  void _navigateBack() {
    if (Get.context != null && Navigator.of(Get.context!).canPop()) {
      Get.back(result: true);
    } else {
      Get.offNamed('/my-orders');
    }
  }
}
