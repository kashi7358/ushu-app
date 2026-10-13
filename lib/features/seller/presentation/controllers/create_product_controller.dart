import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/errors/exception_handler.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/custom_popup.dart';
import '../../../../core/utils/session_manager.dart';
import '../../data/datasources/seller_remote_data_source.dart';
import '../../data/models/create_product_request_model.dart';
import '../../data/models/seller_copilot_product_model.dart';
import '../../data/models/seller_product_model.dart';
import '../../data/repositories/seller_repository_impl.dart';

class CreateProductController extends GetxController {
  // Step Navigation
  final RxInt currentStep = 0.obs;
  final step1FormKey = GlobalKey<FormState>();
  final step2FormKey = GlobalKey<FormState>();
  final step3FormKey = GlobalKey<FormState>();

  String storeId = '';
  final RxBool isEditMode = false.obs;
  String productId = '';
  final RxList<String> existingImages = <String>[].obs;

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
  final RxBool isCopilotGenerating = false.obs;
  final ImagePicker _picker = ImagePicker();
  late final SellerRepositoryImpl _repository;

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
    if (args is Map) {
      if (args['storeId'] != null) {
        storeId = args['storeId'].toString();
      }
      if (args['isEdit'] == true || args['product'] != null) {
        isEditMode.value = true;
        if (args['product'] is SellerProductModel) {
          final product = args['product'] as SellerProductModel;
          productId = product.id;
          nameController.text = product.name;
          descriptionController.text = product.description;
          skuController.text = product.sku;
          priceController.text = product.price > 0
              ? product.price.toStringAsFixed(product.price.truncateToDouble() == product.price ? 0 : 2)
              : '';
          priceCurrencyController.text = product.priceCurrency.isNotEmpty ? product.priceCurrency : 'PKR';
          if (product.category.isNotEmpty) {
            setCategory(product.category);
          }
          subCategoryController.text = product.subCategory;
          brandController.text = product.brand;
          if (product.condition.isNotEmpty) {
            setCondition(product.condition);
          }
          stockController.text = product.stock.toString();
          lowStockThresholdController.text = product.lowStockThreshold.toString();
          trackInventory.value = product.trackInventory;

          if (product.images.isNotEmpty) {
            existingImages.assignAll(product.images);
          } else if (product.primaryImage.isNotEmpty) {
            existingImages.add(product.primaryImage);
          }
        }
      }
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

  // AI Seller Copilot Integration
  void promptAiCopilot(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6B46C1), Color(0xFF9F7AEA)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.auto_awesome, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AI Seller Copilot',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A202C),
                          ),
                        ),
                        Text(
                          'Select product photo to auto-fill details',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B46C1).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_outlined, color: Color(0xFF6B46C1)),
                ),
                title: const Text(
                  'Take Photo',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                subtitle: Text(
                  'Capture product with camera',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () {
                  Get.back();
                  generateWithAiCopilot(source: ImageSource.camera);
                },
              ),
              Divider(height: 1, color: Colors.grey.shade200),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B46C1).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library_outlined, color: Color(0xFF6B46C1)),
                ),
                title: const Text(
                  'Choose from Gallery',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                subtitle: Text(
                  'Pick an existing photo from library',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () {
                  Get.back();
                  generateWithAiCopilot(source: ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> generateWithAiCopilot({required ImageSource source}) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (file == null) return;

      if (storeId.isEmpty && SessionManager.sellerStoreId != null) {
        storeId = SessionManager.sellerStoreId!;
      }
      if (storeId.isEmpty) {
        CustomPopup.showError(
          'Store Required',
          'Store ID is missing. Please ensure your store is active.',
        );
        return;
      }

      isCopilotGenerating.value = true;

      // Show futuristic AI processing dialog with copilot.json (without "Hello")
      Get.dialog(
        PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6B46C1).withValues(alpha: 0.18),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 130,
                    width: 130,
                    child: Lottie.asset(
                      'assets/lotties/copilot.json',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF6B46C1).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.auto_awesome, color: Color(0xFF6B46C1), size: 48),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF6B46C1), Color(0xFFD53F8C)],
                    ).createShader(bounds),
                    child: const Text(
                      'AI Copilot is Thinking...',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Analyzing product image, auto-crafting title, description, category, and pricing...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      final response = await _repository.generateProductFromImage(
        imagePath: file.path,
        storeId: storeId,
      );

      if (Get.isDialogOpen == true) {
        Get.back();
      }
      isCopilotGenerating.value = false;

      final copilotData = SellerCopilotProductModel.fromJson(
        response is Map<String, dynamic>
            ? response
            : (response is Map ? Map<String, dynamic>.from(response) : {}),
      );

      // Auto-fill form fields
      if (copilotData.title.isNotEmpty) {
        nameController.text = copilotData.title;
      }
      if (copilotData.description.isNotEmpty) {
        descriptionController.text = copilotData.description;
      }
      if (copilotData.category.isNotEmpty) {
        final matchedCat = categories.firstWhere(
          (c) =>
              c.toLowerCase().contains(copilotData.category.toLowerCase()) ||
              copilotData.category.toLowerCase().contains(c.toLowerCase()),
          orElse: () => copilotData.category,
        );
        if (!categories.contains(matchedCat)) {
          categories.add(matchedCat);
        }
        setCategory(matchedCat);
      }
      if (copilotData.subCategory.isNotEmpty) {
        subCategoryController.text = copilotData.subCategory;
      }
      if (copilotData.brand.isNotEmpty) {
        brandController.text = copilotData.brand;
      }
      if (copilotData.condition.isNotEmpty) {
        final cond = copilotData.condition.toLowerCase();
        if (conditions.contains(cond)) {
          setCondition(cond);
        }
      }
      if (copilotData.price > 0) {
        priceController.text = copilotData.price.toStringAsFixed(
          copilotData.price.truncateToDouble() == copilotData.price ? 0 : 2,
        );
      }
      if (copilotData.stock > 0) {
        stockController.text = copilotData.stock.toString();
      }
      if (copilotData.tags.isNotEmpty) {
        tagsController.text = copilotData.tags.join(', ');
      }
      if (copilotData.sku.isNotEmpty) {
        skuController.text = copilotData.sku;
      }

      // Add picked image to product images list
      if (!imagePaths.contains(file.path)) {
        imagePaths.insert(0, file.path);
      }

      CustomPopup.showSuccess(
        'Copilot Magic ✨',
        'Product details auto-generated successfully! You can review or edit any field.',
      );
    } catch (e) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      isCopilotGenerating.value = false;
      CustomPopup.showError(
        'Copilot Failed',
        ExceptionHandler.handle(e).message,
      );
    }
  }

  // Final Submit
  Future<void> createProduct() async {
    if (isEditMode.value) {
      await updateProduct();
      return;
    }

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

  // Update Product (PATCH API Multipart Form Data)
  Future<void> updateProduct() async {
    if (productId.isEmpty) {
      CustomPopup.showError('Error', 'Product ID is missing');
      return;
    }

    if (nameController.text.trim().isEmpty) {
      CustomPopup.showError('Required Field', 'Product Name is required');
      currentStep.value = 0;
      return;
    }

    if (priceController.text.trim().isEmpty) {
      CustomPopup.showError('Required Field', 'Price is required');
      currentStep.value = 1;
      return;
    }

    try {
      isLoading.value = true;
      CustomPopup.showLoading('Updating product details & media...');

      final Map<String, dynamic> map = {
        'name': nameController.text.trim(),
        'description': descriptionController.text.trim(),
        'sku': skuController.text.trim(),
        'price': priceController.text.trim(),
        'priceCurrency': priceCurrencyController.text.trim(),
        'category': categoryController.text.trim(),
        'SubCategory': subCategoryController.text.trim(),
        'brand': brandController.text.trim(),
        'condition': conditionController.text.trim(),
        'stock': stockController.text.trim(),
        'lowStockThreshold': lowStockThresholdController.text.trim(),
        'trackInventory': trackInventory.value.toString(),
        'tags': tagsController.text.trim(),
        'weight': weightController.text.trim(),
        'dimensions[length]': lengthController.text.trim(),
        'dimensions[height]': heightController.text.trim(),
        'dimensions[width]': widthController.text.trim(),
      };

      for (int i = 0; i < variantsList.length; i++) {
        map['variants[$i]'] = variantsList[i];
      }

      if (variantAttributes1Controller.text.trim().isNotEmpty) {
        map['variant_attributes_1'] = variantAttributes1Controller.text.trim();
      }

      // Add any newly picked image files
      final List<dio.MultipartFile> newImageFiles = [];
      for (final path in imagePaths) {
        final file = File(path);
        if (await file.exists()) {
          final filename = path.split(Platform.pathSeparator).last;
          newImageFiles.add(await dio.MultipartFile.fromFile(path, filename: filename));
        }
      }
      if (newImageFiles.isNotEmpty) {
        map['images'] = newImageFiles.length == 1 ? newImageFiles.first : newImageFiles;
      }

      final formData = dio.FormData.fromMap(map);

      final response = await _repository.updateProduct(
        productId: productId,
        formData: formData,
      );

      CustomPopup.hideLoading();

      final message = (response is Map && response['message'] != null)
          ? response['message'].toString()
          : 'Product updated successfully!';

      CustomPopup.showSuccess('Product Updated!', message);

      // Return to manage products with refresh signal
      Get.back(result: true);
    } catch (e) {
      CustomPopup.hideLoading();
      final error = ExceptionHandler.handle(e);
      CustomPopup.showError('Update Failed', error.message);
    } finally {
      isLoading.value = false;
    }
  }
}
