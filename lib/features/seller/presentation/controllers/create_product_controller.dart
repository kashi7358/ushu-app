import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/errors/exception_handler.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/custom_popup.dart';
import '../../../../core/utils/session_manager.dart';
import '../../data/datasources/seller_remote_data_source.dart';
import '../../data/models/create_product_request_model.dart';
import '../../data/repositories/seller_repository_impl.dart';
import '../../domain/repositories/seller_repository.dart';

class CreateProductController extends GetxController {
  // Step Navigation
  final RxInt currentStep = 0.obs;
  final step1FormKey = GlobalKey<FormState>();
  final step2FormKey = GlobalKey<FormState>();
  final step3FormKey = GlobalKey<FormState>();

  String storeId = '';

  // STEP 1: Basic Information Controllers
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final skuController = TextEditingController();
  final categoryController = TextEditingController(text: 'Electronics');
  final subCategoryController = TextEditingController(text: 'Earbuds');
  final brandController = TextEditingController();
  final conditionController = TextEditingController(text: 'new');
  final tagsController = TextEditingController();

  // Reactive dropdowns
  final RxString selectedCategory = 'Electronics'.obs;
  final RxString selectedCondition = 'new'.obs;

  void setCategory(String val) {
    selectedCategory.value = val;
    categoryController.text = val;
  }

  void setCondition(String val) {
    selectedCondition.value = val;
    conditionController.text = val;
  }

  // STEP 2: Pricing, Inventory & Dimensions Controllers
  final priceController = TextEditingController();
  final priceCurrencyController = TextEditingController(text: 'PKR');
  final stockController = TextEditingController();
  final lowStockThresholdController = TextEditingController(text: '10');
  final weightController = TextEditingController();
  final lengthController = TextEditingController();
  final heightController = TextEditingController();
  final widthController = TextEditingController();
  final RxBool trackInventory = true.obs;

  // STEP 3: Variants & Media
  final variantController = TextEditingController();
  final RxList<String> variantsList = <String>[].obs;
  final variantAttributes1Controller = TextEditingController();

  // Media
  final RxList<String> imagePaths = <String>[].obs;
  final Rx<String?> videoPath = Rx<String?>(null);
  final RxList<String> variantImagePaths = <String>[].obs;

  final RxBool isLoading = false.obs;
  final ImagePicker _picker = ImagePicker();
  late final SellerRepository _repository;

  // Dropdown lists
  final List<String> categories = [
    'Electronics',
    'Fashion & Apparel',
    'Health & Beauty',
    'Home & Lifestyle',
    'Sports & Outdoors',
    'Automotive & Motorbike',
  ];

  final List<String> conditions = ['new', 'refurbished', 'used'];

  @override
  void onInit() {
    super.onInit();
    final apiClient = ApiClient();
    final remoteDataSource = SellerRemoteDataSourceImpl(apiClient);
    _repository = SellerRepositoryImpl(remoteDataSource);

    final args = Get.arguments;
    if (args is Map && args['storeId'] != null) {
      storeId = args['storeId'].toString();
    }
    if (storeId.isEmpty && SessionManager.sellerStoreId != null) {
      storeId = SessionManager.sellerStoreId!;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    skuController.dispose();
    categoryController.dispose();
    subCategoryController.dispose();
    brandController.dispose();
    conditionController.dispose();
    tagsController.dispose();
    priceController.dispose();
    priceCurrencyController.dispose();
    stockController.dispose();
    lowStockThresholdController.dispose();
    weightController.dispose();
    lengthController.dispose();
    heightController.dispose();
    widthController.dispose();
    variantController.dispose();
    variantAttributes1Controller.dispose();
    super.onClose();
  }

  // Variant helper
  void addVariant() {
    final text = variantController.text.trim();
    if (text.isNotEmpty && !variantsList.contains(text)) {
      variantsList.add(text);
      variantController.clear();
    }
  }

  void removeVariant(int index) {
    if (index >= 0 && index < variantsList.length) {
      variantsList.removeAt(index);
    }
  }

  // Navigation Logic
  void nextStep() {
    if (currentStep.value == 0) {
      if (!step1FormKey.currentState!.validate()) return;
      currentStep.value = 1;
    } else if (currentStep.value == 1) {
      if (!step2FormKey.currentState!.validate()) return;
      currentStep.value = 2;
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    } else {
      Get.back();
    }
  }

  // Image Picking
  Future<void> pickProductImages({required ImageSource source}) async {
    try {
      if (source == ImageSource.gallery) {
        final List<XFile> pickedFiles = await _picker.pickMultiImage(
          maxWidth: 1600,
          maxHeight: 1600,
          imageQuality: 85,
        );
        for (final file in pickedFiles) {
          if (!imagePaths.contains(file.path)) {
            imagePaths.add(file.path);
          }
        }
      } else {
        final XFile? file = await _picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1600,
          maxHeight: 1600,
          imageQuality: 85,
        );
        if (file != null && !imagePaths.contains(file.path)) {
          imagePaths.add(file.path);
        }
      }
    } catch (e) {
      CustomPopup.showError('Image Error', 'Failed to pick product images: $e');
    }
  }

  void removeProductImage(int index) {
    if (index >= 0 && index < imagePaths.length) {
      imagePaths.removeAt(index);
    }
  }

  Future<void> pickVariantImage({required ImageSource source}) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (file != null && !variantImagePaths.contains(file.path)) {
        variantImagePaths.add(file.path);
      }
    } catch (e) {
      CustomPopup.showError('Image Error', 'Failed to pick variant image: $e');
    }
  }

  void removeVariantImage(int index) {
    if (index >= 0 && index < variantImagePaths.length) {
      variantImagePaths.removeAt(index);
    }
  }

  Future<void> pickVideo() async {
    try {
      final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);
      if (file != null) {
        videoPath.value = file.path;
      }
    } catch (e) {
      CustomPopup.showError('Video Error', 'Failed to pick video: $e');
    }
  }

  void removeVideo() {
    videoPath.value = null;
  }

  // Final Submit
  Future<void> createProduct() async {
    if (storeId.isEmpty) {
      CustomPopup.showError('Store Required', 'Store ID is missing. Please create or select a store first.');
      return;
    }

    if (imagePaths.isEmpty) {
      CustomPopup.showError('Product Images', 'Please upload at least 1 image for your product.');
      return;
    }

    try {
      isLoading.value = true;
      CustomPopup.showLoading('Uploading product details & media...');

      final model = CreateProductRequestModel(
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        sku: skuController.text.trim(),
        price: priceController.text.trim(),
        priceCurrency: priceCurrencyController.text.trim(),
        category: categoryController.text.trim(),
        subCategory: subCategoryController.text.trim(),
        brand: brandController.text.trim(),
        condition: conditionController.text.trim(),
        stock: stockController.text.trim(),
        lowStockThreshold: lowStockThresholdController.text.trim(),
        trackInventory: trackInventory.value,
        tags: tagsController.text.trim(),
        weight: weightController.text.trim(),
        length: lengthController.text.trim(),
        height: heightController.text.trim(),
        width: widthController.text.trim(),
        variants: variantsList,
        variantAttributes1: variantAttributes1Controller.text.trim().isNotEmpty
            ? variantAttributes1Controller.text.trim()
            : null,
        imagePaths: imagePaths,
        videoPath: videoPath.value,
        variantImagePaths: variantImagePaths,
      );

      final response = await _repository.createProduct(storeId: storeId, model: model);
      CustomPopup.hideLoading();

      final message = (response is Map && response['message'] != null)
          ? response['message'].toString()
          : 'Product published successfully!';

      CustomPopup.showSuccess('Product Created!', message);

      // Navigate to seller approval / main screen
      Get.offAllNamed(AppRoutes.sellerPendingApproval);
    } catch (e) {
      CustomPopup.hideLoading();
      final error = ExceptionHandler.handle(e);
      CustomPopup.showError('Failed to Create Product', error.message);
    } finally {
      isLoading.value = false;
    }
  }
}
