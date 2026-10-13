import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/errors/exception_handler.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/custom_popup.dart';
import '../../../../core/utils/session_manager.dart';
import '../../data/datasources/seller_remote_data_source.dart';
import '../../data/models/create_flash_sale_request_model.dart';
import '../../data/models/flash_sale_campaign_model.dart';
import '../../data/models/seller_product_model.dart';
import '../../data/repositories/seller_repository_impl.dart';

class CreateFlashSaleController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final discountValueController = TextEditingController(text: '20');
  final stockLimitController = TextEditingController(text: '50');
  final maxPerUserController = TextEditingController(text: '2');

  final Rx<DateTime?> startTime = Rx<DateTime?>(null);
  final Rx<DateTime?> endTime = Rx<DateTime?>(null);

  final RxString discountType = 'percentage'.obs; // 'percentage' or 'fixed'
  final RxBool isFreeShipping = false.obs;

  final RxList<SellerProductModel> storeProducts = <SellerProductModel>[].obs;
  final RxSet<String> selectedProductIds = <String>{}.obs;

  final RxBool isLoadingProducts = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isEditMode = false.obs;
  final RxString errorMessage = ''.obs;

  late final SellerRepositoryImpl _repository;
  String storeId = '';
  String editingCampaignId = '';

  @override
  void onInit() {
    super.onInit();
    final apiClient = ApiClient();
    final remoteDataSource = SellerRemoteDataSourceImpl(apiClient);
    _repository = SellerRepositoryImpl(remoteDataSource);

    storeId = SessionManager.sellerStoreId ?? '';

    // Default start now + end in 2 days
    final now = DateTime.now();
    startTime.value = now;
    endTime.value = now.add(const Duration(days: 2));

    // Check if opened in Edit Mode
    final args = Get.arguments;
    if (args is Map) {
      final campaign = args['campaign'];
      if (campaign is FlashSaleCampaignModel) {
        isEditMode.value = true;
        editingCampaignId = campaign.id;
        if (campaign.storeId.isNotEmpty) {
          storeId = campaign.storeId;
        }
        titleController.text = campaign.title;
        descriptionController.text = campaign.description;
        if (campaign.startTime != null) {
          startTime.value = campaign.startTime!.toLocal();
        }
        if (campaign.endTime != null) {
          endTime.value = campaign.endTime!.toLocal();
        }
        if (campaign.products.isNotEmpty) {
          final firstProd = campaign.products.first;
          discountType.value = firstProd.discountType.toLowerCase() == 'fixed' ? 'fixed' : 'percentage';
          discountValueController.text = firstProd.discountValue.toString();
          stockLimitController.text = firstProd.stockLimit.toString();
          maxPerUserController.text = firstProd.maxPerUser.toString();
          isFreeShipping.value = firstProd.isFreeShipping;

          for (final p in campaign.products) {
            if (p.productId.isNotEmpty) {
              selectedProductIds.add(p.productId);
            }
          }
        }
      }
    }

    loadStoreProducts();
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    discountValueController.dispose();
    stockLimitController.dispose();
    maxPerUserController.dispose();
    super.onClose();
  }

  Future<void> loadStoreProducts() async {
    if (storeId.isEmpty) {
      storeId = SessionManager.sellerStoreId ?? '';
    }

    if (storeId.isEmpty) {
      try {
        final storeRes = await _repository.getMyStore();
        if (storeRes is Map && storeRes['data'] != null) {
          final sid = storeRes['data']['_id']?.toString() ?? storeRes['data']['id']?.toString();
          if (sid != null && sid.isNotEmpty) {
            storeId = sid;
            await SessionManager.saveSellerStoreId(sid);
          }
        }
      } catch (_) {}
    }

    if (storeId.isEmpty) {
      errorMessage.value = 'Store reference not found. Please setup your store first.';
      return;
    }

    try {
      isLoadingProducts.value = true;
      errorMessage.value = '';

      final response = await _repository.getProductsByStore(storeId);
      final List<SellerProductModel> loaded = [];

      dynamic rawList;
      if (response is Map) {
        rawList = response['products'] ?? response['data'] ?? response['allProducts'];
      } else if (response is List) {
        rawList = response;
      }

      if (rawList is List) {
        for (var item in rawList) {
          if (item is Map<String, dynamic>) {
            loaded.add(SellerProductModel.fromJson(item));
          } else if (item is Map) {
            loaded.add(SellerProductModel.fromJson(Map<String, dynamic>.from(item)));
          }
        }
      }

      storeProducts.assignAll(loaded);
      if (storeProducts.isNotEmpty && selectedProductIds.isEmpty) {
        // Auto select first product only when creating new
        selectedProductIds.add(storeProducts.first.id);
      }
    } catch (e) {
      final error = ExceptionHandler.handle(e);
      errorMessage.value = error.message;
    } finally {
      isLoadingProducts.value = false;
    }
  }

  void toggleProductSelection(String productId) {
    if (selectedProductIds.contains(productId)) {
      if (selectedProductIds.length > 1) {
        selectedProductIds.remove(productId);
      } else {
        CustomPopup.showError('Required', 'At least 1 product must be selected for flash sale');
      }
    } else {
      selectedProductIds.add(productId);
    }
  }

  void setDiscountType(String type) {
    discountType.value = type;
  }

  void toggleFreeShipping(bool? val) {
    isFreeShipping.value = val ?? false;
  }

  Future<void> pickDateTime({required bool isStart, required BuildContext context}) async {
    final initial = isStart ? (startTime.value ?? DateTime.now()) : (endTime.value ?? DateTime.now().add(const Duration(days: 1)));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate == null || !context.mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );

    if (pickedTime == null) return;

    final combined = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    if (isStart) {
      startTime.value = combined;
      if (endTime.value != null && endTime.value!.isBefore(combined)) {
        endTime.value = combined.add(const Duration(days: 1));
      }
    } else {
      if (startTime.value != null && combined.isBefore(startTime.value!)) {
        CustomPopup.showError('Invalid Date', 'End time cannot be earlier than start time');
        return;
      }
      endTime.value = combined;
    }
  }

  Future<void> submitFlashSale() async {
    if (!formKey.currentState!.validate()) return;

    if (selectedProductIds.isEmpty) {
      CustomPopup.showError('No Products Selected', 'Please select at least one product for the flash sale');
      return;
    }

    if (startTime.value == null || endTime.value == null) {
      CustomPopup.showError('Date Required', 'Please specify both start time and end time');
      return;
    }

    if (endTime.value!.isBefore(startTime.value!)) {
      CustomPopup.showError('Invalid Time', 'End time must be after start time');
      return;
    }

    try {
      isSubmitting.value = true;
      CustomPopup.showLoading(
        isEditMode.value ? 'Updating flash sale campaign...' : 'Creating flash sale campaign...',
      );

      final discountVal = num.tryParse(discountValueController.text.trim()) ?? 0;
      final stockLim = int.tryParse(stockLimitController.text.trim()) ?? 10;
      final maxPerU = int.tryParse(maxPerUserController.text.trim()) ?? 1;

      final productsPayload = selectedProductIds.map((pId) {
        return FlashSaleProductItemModel(
          productId: pId,
          discountType: discountType.value,
          discountValue: discountVal,
          stockLimit: stockLim,
          isFreeShipping: isFreeShipping.value,
          maxPerUser: maxPerU,
        );
      }).toList();

      final requestModel = CreateFlashSaleRequestModel(
        title: titleController.text.trim(),
        storeId: storeId,
        description: descriptionController.text.trim(),
        startTime: startTime.value!.toUtc().toIso8601String(),
        endTime: endTime.value!.toUtc().toIso8601String(),
        products: productsPayload,
      );

      final dynamic response;
      if (isEditMode.value && editingCampaignId.isNotEmpty) {
        response = await _repository.updateFlashSale(
          id: editingCampaignId,
          model: requestModel,
        );
      } else {
        response = await _repository.createFlashSale(requestModel);
      }

      CustomPopup.hideLoading();

      final defaultMsg = isEditMode.value
          ? 'Flash Sale updated successfully!'
          : 'Flash Sale created successfully!';
      final msg = (response is Map && response['message'] != null)
          ? response['message'].toString()
          : defaultMsg;

      CustomPopup.showSuccess(
        isEditMode.value ? 'Flash Sale Updated!' : 'Flash Sale Live!',
        msg,
      );
      Get.back(result: true);
    } catch (e) {
      CustomPopup.hideLoading();
      final error = ExceptionHandler.handle(e);
      CustomPopup.showError('Flash Sale Failed', error.message);
    } finally {
      isSubmitting.value = false;
    }
  }
}
