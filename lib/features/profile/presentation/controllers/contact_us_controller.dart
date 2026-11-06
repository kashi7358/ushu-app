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
    final userEmail = SessionManager.email ?? SessionManager.sellerEmail;
    if (userEmail != null && userEmail.isNotEmpty) {
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

    final String? rawToken = SessionManager.token ?? SessionManager.sellerToken;
    String cleanToken = (rawToken ?? '').trim();
    if (cleanToken.toLowerCase().startsWith('bearer ')) {
      cleanToken = cleanToken.substring(7).trim();
    }
    if (cleanToken == 'null' || cleanToken == 'undefined') {
      cleanToken = '';
    }

    if (cleanToken.isEmpty) {
      CustomPopup.showWarning(
        'Login Required',
        'Please sign in to your account so our support team can assist you and track your ticket.',
        buttonText: 'Sign In',
        onConfirm: () => Get.to(() => const LoginScreen()),
      );
      return;
    }

    final userName = SessionManager.fullName ?? SessionManager.sellerName ?? 'Customer';
    final userId = SessionManager.userId ?? SessionManager.sellerId ?? '';

    try {
      isLoading.value = true;
      final response = await _apiClient.dio.post(
        ApiEndpoints.contactUs,
        data: {
          'name': userName,
          'fullName': userName,
          'FullName': userName,
          'email': email,
          'Email': email,
          'subject': subject,
          'Subject': subject,
          'message': message,
          'Message': message,
          if (userId.isNotEmpty) 'userId': userId,
          if (userId.isNotEmpty) 'buyerId': userId,
        },
        options: Options(
          validateStatus: (status) => true,
          headers: {
            'Authorization': 'Bearer $cleanToken',
            'auth-token': cleanToken,
            'token': cleanToken,
            'x-auth-token': cleanToken,
          },
        ),
      );

      final data = response.data;
      final bool isSuccess = response.statusCode == 200 ||
          response.statusCode == 201 ||
          (data != null && (data['success'] == true || data['status'] == 'success'));

      if (isSuccess) {
        subjectController.clear();
        messageController.clear();
        CustomPopup.showSuccess(
          'Message Sent!',
          'Thank you for reaching out to us. Your message has been sent successfully, and our team will get back to you shortly.',
        );
      } else if (response.statusCode == 401 ||
          (data != null &&
              data['message'] != null &&
              data['message'].toString().toLowerCase().contains('unauthorized'))) {
        CustomPopup.showWarning(
          'Authentication Required',
          'Could not verify your login session. Please sign in again to submit your support message.',
          buttonText: 'Sign In',
          onConfirm: () => Get.to(() => const LoginScreen()),
        );
      } else {
        final errorMsg = data != null && data['message'] != null
            ? data['message'].toString()
            : 'Failed to send message. Please try again.';
        CustomPopup.showToast('Failed', errorMsg, isError: true);
      }
    } catch (e) {
      CustomPopup.showToast('Error', 'An error occurred while sending message', isError: true);
    } finally {
      isLoading.value = false;
    }
  }
}
