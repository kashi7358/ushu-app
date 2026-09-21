import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio;
import 'dart:io';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/utils/custom_popup.dart';

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
    productId = Get.arguments['productId'];
    orderId = Get.arguments['orderId'];
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
          'images', // Key might be 'images' or 'images[]', assuming 'images' for now based on user prompt
          await dio.MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
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
      if (data != null && data['success'] == true) {
        CustomPopup.showToast('Success', 'Review submitted successfully!');
        Get.back(result: true);
      } else {
        CustomPopup.showToast('Failed', data['message'] ?? 'Could not submit review', isError: true);
      }
    } catch (e) {
      CustomPopup.showToast('Error', 'An error occurred while submitting review', isError: true);
    } finally {
      isLoading.value = false;
    }
  }
}
