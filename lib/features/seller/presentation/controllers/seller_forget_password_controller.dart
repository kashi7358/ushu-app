import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/errors/exception_handler.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/custom_popup.dart';
import '../../data/datasources/seller_remote_data_source.dart';
import '../../data/repositories/seller_repository_impl.dart';
import '../../domain/repositories/seller_repository.dart';

class SellerForgetPasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final RxBool isLoading = false.obs;

  late final SellerRepository _repository;

  @override
  void onInit() {
    super.onInit();
    final apiClient = ApiClient();
    final remoteDataSource = SellerRemoteDataSourceImpl(apiClient);
    _repository = SellerRepositoryImpl(remoteDataSource);
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  Future<void> sendResetLink() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      final response = await _repository.forgetPassword(emailController.text.trim());

      if (response is Map && response['success'] == false) {
        final errorMsg = response['message']?.toString() ?? 'Failed to send reset link';
        CustomPopup.showError('Error', errorMsg);
        return;
      }

      final message = (response is Map && response['message'] != null)
          ? response['message'].toString()
          : 'Password reset link has been sent to your email!';

      CustomPopup.showSuccess(
        'Email Sent!',
        message,
        buttonText: 'Back to Login',
        onConfirm: () => Get.back(),
      );
    } catch (e) {
      final error = ExceptionHandler.handle(e);
      CustomPopup.showError('Error', error.message);
    } finally {
      isLoading.value = false;
    }
  }
}
