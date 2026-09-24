import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/utils/custom_popup.dart';
import '../../../../core/utils/session_manager.dart';
import 'package:dio/dio.dart';

class ContactUsController extends GetxController {
  final ApiClient _apiClient = ApiClient();

  final emailController = TextEditingController();
  final subjectController = TextEditingController();
  final messageController = TextEditingController();

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final userEmail = SessionManager.email;
    if (userEmail != null) {
      emailController.text = userEmail;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    subjectController.dispose();
    messageController.dispose();
    super.onClose();
  }

  Future<void> sendMessage() async {
    final email = emailController.text.trim();
    final subject = subjectController.text.trim();
    final message = messageController.text.trim();

    if (email.isEmpty || subject.isEmpty || message.isEmpty) {
      CustomPopup.showToast('Validation Error', 'Please fill all fields', isError: true);
      return;
    }

    if (!GetUtils.isEmail(email)) {
      CustomPopup.showToast('Validation Error', 'Please enter a valid email', isError: true);
      return;
    }

    try {
      isLoading.value = true;
      final response = await _apiClient.dio.post(
        ApiEndpoints.contactUs,
        data: {
          'Email': email,
          'Subject': subject,
          'Message': message,
        },
        options: Options(validateStatus: (status) => true),
      );

      final data = response.data;
      if (data != null && data['success'] == true) {
        subjectController.clear();
        messageController.clear();
        CustomPopup.showSuccess(
          'Message Sent!',
          'Thank you for reaching out to us. Your message has been sent successfully, and our team will get back to you shortly.',
        );
      } else {
        CustomPopup.showToast('Failed', data['message'] ?? 'Failed to send message', isError: true);
      }
    } catch (e) {
      CustomPopup.showToast('Error', 'An error occurred while sending message', isError: true);
    } finally {
      isLoading.value = false;
    }
  }
}
