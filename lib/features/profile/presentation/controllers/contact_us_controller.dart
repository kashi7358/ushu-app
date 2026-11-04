import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/utils/custom_popup.dart';
import '../../../../core/utils/session_manager.dart';
import '../../../authentication/presentation/screens/login_screen.dart';
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

    final String? token = SessionManager.token ?? SessionManager.sellerToken;
    if (token == null || token.isEmpty) {
      CustomPopup.showWarning(
        'Login Required',
        'Please sign in to your account so our support team can assist you and track your ticket.',
        buttonText: 'Sign In',
        onConfirm: () => Get.to(() => const LoginScreen()),
      );
      return;
    }

    try {
      isLoading.value = true;
      final response = await _apiClient.dio.post(
        ApiEndpoints.contactUs,
        data: {
          'email': email,
          'subject': subject,
          'message': message,
          'Email': email,
          'Subject': subject,
          'Message': message,
        },
        options: Options(
          validateStatus: (status) => true,
          headers: {
            'Authorization': 'Bearer $token',
            'auth-token': token,
          },
        ),
      );

      final data = response.data;
      if (response.statusCode == 200 || response.statusCode == 201 || (data != null && data['success'] == true)) {
        subjectController.clear();
        messageController.clear();
        CustomPopup.showSuccess(
          'Message Sent!',
          'Thank you for reaching out to us. Your message has been sent successfully, and our team will get back to you shortly.',
        );
      } else if (response.statusCode == 401 ||
          (data != null && data['message'] != null && data['message'].toString().toLowerCase().contains('unauthorized'))) {
        CustomPopup.showError(
          'Session Expired',
          'Your session has expired or requires authentication. Please sign in again.',
          buttonText: 'Sign In',
          onConfirm: () => Get.to(() => const LoginScreen()),
        );
      } else {
        final errorMsg = data != null && data['message'] != null ? data['message'].toString() : 'Failed to send message';
        CustomPopup.showToast('Failed', errorMsg, isError: true);
      }
    } catch (e) {
      CustomPopup.showToast('Error', 'An error occurred while sending message', isError: true);
    } finally {
      isLoading.value = false;
    }
  }
}
