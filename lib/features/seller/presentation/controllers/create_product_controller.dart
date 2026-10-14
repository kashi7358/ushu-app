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

  // ==========================================
  // AI SELLER COPILOT (FAB Flow)
  // ==========================================
  final RxBool isCopilotAnalyzing = false.obs;

  void startCopilotFlow([BuildContext? context]) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 8,
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with close button
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B46C1).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Lottie.asset(
                      'assets/lotties/chatbot.json',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.smart_toy_outlined,
                        color: Color(0xFF6B46C1),
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Seller Copilot',
                          style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A202C),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Select photo source to analyze',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close_rounded, color: Colors.grey, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Camera Option
              InkWell(
                onTap: () {
                  Get.back();
                  processImageWithCopilot(source: ImageSource.camera);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6B46C1).withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF6B46C1), size: 22),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Take Photo',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, color: Color(0xFF1A202C)),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Capture item using camera',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Gallery Option
              InkWell(
                onTap: () {
                  Get.back();
                  processImageWithCopilot(source: ImageSource.gallery);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF97316).withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.photo_library_rounded, color: Color(0xFFF97316), size: 22),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Choose from Gallery',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, color: Color(0xFF1A202C)),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Pick photo from your device',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> processImageWithCopilot({required ImageSource source}) async {
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

      isCopilotAnalyzing.value = true;

      // Show sleek high-tech AI processing dialog with copilot.json (no hello text)
      Get.dialog(
        PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: const EdgeInsets.symmetric(horizontal: 28),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6B46C1).withValues(alpha: 0.2),
                    blurRadius: 40,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated futuristic Copilot with glowing background
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF6B46C1).withValues(alpha: 0.16),
                              const Color(0xFF6B46C1).withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 110,
                        width: 110,
                        child: Lottie.asset(
                          'assets/lotties/copilot.json',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 70,
                            height: 70,
                            decoration: const BoxDecoration(
                              color: Color(0xFF6B46C1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 36),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // AI Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B46C1).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome, color: Color(0xFF6B46C1), size: 14),
                        SizedBox(width: 5),
                        Text(
                          'AI Vision Engine',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6B46C1),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Analyzing Product Photo...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Extracting title, category, pricing & key features automatically',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Sleek Linear Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      height: 6,
                      child: LinearProgressIndicator(
                        backgroundColor: const Color(0xFF6B46C1).withValues(alpha: 0.12),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6B46C1)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      final dynamic rawResponse = await _repository.generateProductFromImage(
        imagePath: file.path,
        storeId: storeId,
      );

      if (Get.isDialogOpen == true) {
        Get.back();
      }
      isCopilotAnalyzing.value = false;

      // Extract raw map directly from API response
      Map<String, dynamic> apiData = {};
      if (rawResponse is Map) {
        if (rawResponse['data'] is Map) {
          apiData = Map<String, dynamic>.from(rawResponse['data'] as Map);
        } else if (rawResponse['product'] is Map) {
          apiData = Map<String, dynamic>.from(rawResponse['product'] as Map);
        } else if (rawResponse['result'] is Map) {
          apiData = Map<String, dynamic>.from(rawResponse['result'] as Map);
        } else {
          apiData = Map<String, dynamic>.from(rawResponse);
        }
      }

      // Show Review Bottom Sheet with Accept ("Ok") and Reject buttons
      showCopilotReviewSheet(apiData, file.path);
    } catch (e) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      isCopilotAnalyzing.value = false;

      String cleanError = ExceptionHandler.handle(e).message;
      if (e is dio.DioException) {
        final resData = e.response?.data;
        if (resData is Map) {
          if (resData['error'] is Map && resData['error']['message'] != null) {
            cleanError = resData['error']['message'].toString();
          } else if (resData['message'] != null) {
            cleanError = resData['message'].toString();
          }
        }
      }

      CustomPopup.showError(
        'AI Copilot Failed',
        cleanError.contains('qwen') || cleanError.contains('model')
            ? '$cleanError\n\n(Backend server par AI model configure nahi hai. Backend developer ko model update karna hoga.)'
            : cleanError,
      );
    }
  }

  void showCopilotReviewSheet(Map<String, dynamic> data, String imagePath) {
    final title = (data['name'] ?? data['title'] ?? data['productName'] ?? 'Detected Product').toString();
    final rawDesc = (data['description'] ?? data['desc'] ?? data['details'] ?? '').toString();
    final features = data['features'];
    String desc = rawDesc;
    if (features is List && features.isNotEmpty) {
      final featList = features.map((f) => '• ${f.toString().trim()}').join('\n');
      if (desc.isNotEmpty) {
        desc += '\n\nKey Features:\n$featList';
      } else {
        desc = 'Key Features:\n$featList';
      }
    }
    final cat = (data['category'] ?? data['categoryName'] ?? '').toString();
    final subCat = (data['SubCategory'] ?? data['subCategory'] ?? data['sub_category'] ?? '').toString();
    final brand = (data['brand'] ?? data['brandName'] ?? '').toString();
    final condition = (data['condition'] ?? 'new').toString();
    final price = (data['suggestedPrice'] ?? data['price'] ?? data['targetPrice'] ?? '').toString();
    final tags = data['keywords'] ?? data['tags'] ?? [];
    final reasoning = (data['reasoning'] ?? '').toString();
    final cloudImageUrl = (data['imageUrl'] ?? '').toString();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 10,
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: Get.height * 0.82,
          ),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B46C1).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Lottie.asset(
                      'assets/lotties/chatbot.json',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.smart_toy_outlined,
                        color: Color(0xFF6B46C1),
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Copilot Result',
                          style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A202C),
                          ),
                        ),
                        SizedBox(height: 1),
                        Text(
                          'Review detected details below',
                          style: TextStyle(fontSize: 11.5, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.grey, size: 22),
                    onPressed: () => Get.back(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const Divider(height: 18),
              // Scrollable Details
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image preview
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: File(imagePath).existsSync()
                              ? Image.file(
                                  File(imagePath),
                                  height: 130,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : (cloudImageUrl.isNotEmpty
                                  ? Image.network(
                                      cloudImageUrl,
                                      height: 130,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 50),
                                    )
                                  : const SizedBox.shrink()),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Title & Price Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A202C),
                              ),
                            ),
                          ),
                          if (price.isNotEmpty && price != '0') ...[
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDEF7EC),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Rs. $price',
                                style: const TextStyle(
                                  color: Color(0xFF03543F),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (reasoning.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFBBF7D0)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.lightbulb_outline, size: 14, color: Color(0xFF16A34A)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  reasoning,
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF15803D)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      // Chips for category, subCat, brand, condition
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          if (cat.isNotEmpty) _buildReviewChip(Icons.category_outlined, cat),
                          if (subCat.isNotEmpty) _buildReviewChip(Icons.account_tree_outlined, subCat),
                          if (brand.isNotEmpty && brand != 'null') _buildReviewChip(Icons.verified_outlined, brand),
                          if (condition.isNotEmpty) _buildReviewChip(Icons.check_circle_outline, condition),
                        ],
                      ),
                      if (desc.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Text(
                          'Description & Features',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF4A5568),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          desc,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Colors.grey.shade700,
                            height: 1.4,
                          ),
                        ),
                      ],
                      if (tags is List && tags.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          'Tags: ${tags.join(', ')}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Decision Buttons
              Row(
                children: [
                  // Reject Button
                  Expanded(
                    flex: 2,
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back();
                        CustomPopup.showError(
                          'Rejected',
                          'AI suggestions rejected. Form remains unchanged.',
                          buttonText: 'Close',
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red, width: 1.2),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.close_rounded, color: Colors.red, size: 18),
                          SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Reject',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // OK / Accept Button
                  Expanded(
                    flex: 3,
                    child: ElevatedButton(
                      onPressed: () {
                        applyCopilotSuggestion(data, imagePath);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B46C1),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'OK (Apply to Form)',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewChip(IconData icon, String label) {
    return Container(
      constraints: BoxConstraints(maxWidth: Get.width * 0.42),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF6B46C1)),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Color(0xFF2D3748), fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void applyCopilotSuggestion(Map<String, dynamic> data, String? imagePath) {
    final title = (data['name'] ?? data['title'] ?? data['productName'] ?? '').toString();
    final rawDesc = (data['description'] ?? data['desc'] ?? data['details'] ?? '').toString();
    final features = data['features'];
    String desc = rawDesc;
    if (features is List && features.isNotEmpty) {
      final featList = features.map((f) => '• ${f.toString().trim()}').join('\n');
      if (desc.isNotEmpty) {
        desc += '\n\nKey Features:\n$featList';
      } else {
        desc = 'Key Features:\n$featList';
      }
    }
    final cat = (data['category'] ?? data['categoryName'] ?? '').toString();
    final subCat = (data['SubCategory'] ?? data['subCategory'] ?? data['sub_category'] ?? '').toString();
    final brand = (data['brand'] ?? data['brandName'] ?? '').toString();
    final condition = (data['condition'] ?? 'new').toString().toLowerCase();
    final priceRaw = data['suggestedPrice'] ?? data['price'] ?? data['targetPrice'];
    final stockRaw = data['stock'] ?? data['quantity'] ?? data['suggestedStock'];
    final sku = (data['sku'] ?? data['SKU'] ?? '').toString();
    final rawTags = data['keywords'] ?? data['tags'] ?? [];
    final weightRaw = data['weight'];

    if (title.isNotEmpty) nameController.text = title;
    if (desc.isNotEmpty) descriptionController.text = desc;
    if (subCat.isNotEmpty) subCategoryController.text = subCat;
    if (brand.isNotEmpty && brand != 'null') brandController.text = brand;
    if (conditions.contains(condition)) setCondition(condition);

    if (cat.isNotEmpty) {
      final matchedCat = categories.firstWhere(
        (c) =>
            c.toLowerCase().contains(cat.toLowerCase()) ||
            cat.toLowerCase().contains(c.toLowerCase()),
        orElse: () => cat,
      );
      if (!categories.contains(matchedCat)) {
        categories.add(matchedCat);
      }
      setCategory(matchedCat);
    }

    if (priceRaw != null) {
      final p = double.tryParse(priceRaw.toString()) ?? 0.0;
      if (p > 0) {
        priceController.text = p.toStringAsFixed(p.truncateToDouble() == p ? 0 : 2);
      }
    }

    if (stockRaw != null) {
      final s = int.tryParse(stockRaw.toString()) ?? 10;
      if (s > 0) stockController.text = s.toString();
    } else if (stockController.text.trim().isEmpty) {
      stockController.text = '10';
    }

    if (sku.isNotEmpty) {
      skuController.text = sku;
    } else if (skuController.text.trim().isEmpty) {
      final prefix = title.isNotEmpty
          ? title.split(' ').first.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase()
          : 'PRD';
      skuController.text = '${prefix}_${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    }

    if (weightRaw != null && weightRaw.toString().isNotEmpty && weightRaw.toString() != 'null') {
      weightController.text = weightRaw.toString();
    }

    if (rawTags is List && rawTags.isNotEmpty) {
      tagsController.text = rawTags.map((e) => e.toString().trim()).join(', ');
    } else if (rawTags is String && rawTags.isNotEmpty) {
      tagsController.text = rawTags;
    }

    if (imagePath != null && imagePath.isNotEmpty && !imagePaths.contains(imagePath)) {
      imagePaths.insert(0, imagePath);
    }

    Get.back();
    CustomPopup.showSuccess('Applied! ✨', 'Product details auto-filled by AI Copilot.');
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
