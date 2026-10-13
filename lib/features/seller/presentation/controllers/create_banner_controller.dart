import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/errors/exception_handler.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/custom_popup.dart';
import '../../../../core/utils/session_manager.dart';
import '../../data/datasources/seller_remote_data_source.dart';
import '../../data/models/create_banner_request_model.dart';
import '../../data/models/update_banner_request_model.dart';
import '../../data/repositories/seller_repository_impl.dart';

class CreateBannerController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);
  final Rx<File?> selectedBannerImage = Rx<File?>(null);
  final RxString existingImageUrl = ''.obs;

  final RxBool isEditMode = false.obs;
  final RxString editingBannerId = ''.obs;
  final RxBool isSubmitting = false.obs;

  late final SellerRepositoryImpl _repository;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    final apiClient = ApiClient();
    final remoteDataSource = SellerRemoteDataSourceImpl(apiClient);
    _repository = SellerRepositoryImpl(remoteDataSource);

    // Pre-fill seller details from SessionManager / Store Details
    final sName = SessionManager.sellerName ?? '';
    final sEmail = SessionManager.sellerEmail ?? '';
    final storeMap = SessionManager.getSellerStoreDetailsMap();

    String sPhone = '';
    if (storeMap != null) {
      sPhone = storeMap['phone']?.toString() ??
          storeMap['Phone']?.toString() ??
          storeMap['phoneNumber']?.toString() ??
          storeMap['contactNumber']?.toString() ??
          '';
    }

    if (sName.isNotEmpty) {
      nameController.text = sName;
    }
    if (sEmail.isNotEmpty) {
      emailController.text = sEmail;
    }
    if (sPhone.isNotEmpty) {
      phoneController.text = sPhone;
    }

    // Default dates
    final now = DateTime.now();
    startDate.value = DateTime(now.year, now.month, now.day);
    endDate.value = DateTime(now.year, now.month, now.day).add(const Duration(days: 7));

    // Check if opened in Edit / Update Mode
    final args = Get.arguments;
    if (args is Map) {
      if (args['isEdit'] == true || args['bannerId'] != null || args['id'] != null) {
        isEditMode.value = true;
        editingBannerId.value = (args['bannerId'] ?? args['id'] ?? '').toString();

        if (args['title'] != null && args['title'].toString().isNotEmpty) {
          titleController.text = args['title'].toString();
        }
        if (args['description'] != null && args['description'].toString().isNotEmpty) {
          descriptionController.text = args['description'].toString();
        }
        if (args['name'] != null && args['name'].toString().isNotEmpty) {
          nameController.text = args['name'].toString();
        }
        if (args['email'] != null && args['email'].toString().isNotEmpty) {
          emailController.text = args['email'].toString();
        }
        if (args['phone'] != null && args['phone'].toString().isNotEmpty) {
          phoneController.text = args['phone'].toString();
        }

        final bannerImg = args['image'] ?? args['bannerImage'] ?? args['Bannerimage'];
        if (bannerImg != null && bannerImg.toString().isNotEmpty) {
          existingImageUrl.value = bannerImg.toString();
        }

        if (args['startDate'] is DateTime) {
          startDate.value = args['startDate'] as DateTime;
        } else if (args['startDate'] != null) {
          startDate.value = DateTime.tryParse(args['startDate'].toString());
        }

        if (args['endDate'] is DateTime) {
          endDate.value = args['endDate'] as DateTime;
        } else if (args['endDate'] != null) {
          endDate.value = DateTime.tryParse(args['endDate'].toString());
        }
      }
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  /// Formats date as `d/MM/yyyy` (e.g. `1/08/2026` or `10/08/2026`)
  String formatDateForApi(DateTime date) {
    final day = date.day.toString();
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  Future<void> pickBannerImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
      );
      if (pickedFile != null) {
        selectedBannerImage.value = File(pickedFile.path);
      }
    } catch (e) {
      CustomPopup.showError('Image Error', 'Could not select banner image.');
    }
  }

  void removeBannerImage() {
    selectedBannerImage.value = null;
    existingImageUrl.value = '';
  }

  Future<void> pickDate(BuildContext context, {required bool isStart}) async {
    final now = DateTime.now();
    final initial = isStart
        ? (startDate.value ?? now)
        : (endDate.value ?? (startDate.value ?? now).add(const Duration(days: 7)));

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0F172A),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (isStart) {
        startDate.value = picked;
        if (endDate.value != null && endDate.value!.isBefore(picked)) {
          endDate.value = picked.add(const Duration(days: 7));
        }
      } else {
        endDate.value = picked;
      }
    }
  }

  Future<void> submitBanner() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (selectedBannerImage.value == null && existingImageUrl.value.isEmpty) {
      CustomPopup.showError(
        'Banner Image Required',
        'Please upload a promotional banner image to continue.',
      );
      return;
    }

    if (startDate.value == null || endDate.value == null) {
      CustomPopup.showError(
        'Dates Required',
        'Please select both start date and end date for the banner.',
      );
      return;
    }

    if (endDate.value!.isBefore(startDate.value!)) {
      CustomPopup.showError(
        'Invalid Date Range',
        'End date cannot be earlier than start date.',
      );
      return;
    }

    try {
      isSubmitting.value = true;

      if (isEditMode.value) {
        // PATCH /api/banner/update-seller/:id
        final updateModel = UpdateBannerRequestModel(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          phone: phoneController.text.trim(),
          title: titleController.text.trim(),
          description: descriptionController.text.trim(),
          startDate: formatDateForApi(startDate.value!),
          endDate: formatDateForApi(endDate.value!),
          bannerImagePath: selectedBannerImage.value?.path,
        );

        final response = await _repository.updateSellerBanner(
          id: editingBannerId.value,
          model: updateModel,
        );

        String successMessage = 'Seller banner updated successfully!';
        if (response is Map && response['message'] != null) {
          successMessage = response['message'].toString();
        }

        Get.back(result: true);
        CustomPopup.showSuccess('Banner Updated', successMessage);
      } else {
        // POST /api/banner/create
        final requestModel = CreateBannerRequestModel(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          phone: phoneController.text.trim(),
          title: titleController.text.trim(),
          description: descriptionController.text.trim(),
          startDate: formatDateForApi(startDate.value!),
          endDate: formatDateForApi(endDate.value!),
          bannerImagePath: selectedBannerImage.value!.path,
        );

        final response = await _repository.createBanner(requestModel);

        String successMessage = 'Promotional banner created successfully!';
        if (response is Map && response['message'] != null) {
          successMessage = response['message'].toString();
        }

        Get.back(result: true);
        CustomPopup.showSuccess('Banner Created', successMessage);
      }
    } catch (e) {
      final error = ExceptionHandler.handle(e);
      CustomPopup.showError(
        isEditMode.value ? 'Failed to Update Banner' : 'Failed to Create Banner',
        error.message,
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}
