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

  // AI Seller Copilot Chatbot System
  final RxList<Map<String, dynamic>> copilotChatMessages = <Map<String, dynamic>>[].obs;
  final RxBool isCopilotChatLoading = false.obs;
  final ScrollController copilotScrollController = ScrollController();

  void openCopilotChat(BuildContext context) {
    if (copilotChatMessages.isEmpty) {
      copilotChatMessages.add({
        'sender': 'bot',
        'type': 'text',
        'text': 'Assalam-o-Alaikum! 👋 Main aapka AI Product Copilot hoon.\n\nApne product ki image send karein, main automatically title, category, description aur pricing attributes suggest karunga. Agar pasand aaye to aap one-tap me apne form me apply kar sakte hain!',
      });
    }

    Get.bottomSheet(
      _buildCopilotChatBottomSheet(context),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (copilotScrollController.hasClients) {
        copilotScrollController.animateTo(
          copilotScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> sendImageToCopilot({required ImageSource source}) async {
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

      // Add user's message with image thumbnail
      copilotChatMessages.add({
        'sender': 'user',
        'type': 'image',
        'imagePath': file.path,
        'text': 'Please analyze this product photo.',
      });
      _scrollToBottom();

      isCopilotChatLoading.value = true;

      // Call API directly
      final dynamic rawResponse = await _repository.generateProductFromImage(
        imagePath: file.path,
        storeId: storeId,
      );

      isCopilotChatLoading.value = false;

      // Directly extract raw map from API response (No custom model class)
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

      copilotChatMessages.add({
        'sender': 'bot',
        'type': 'suggestion',
        'imagePath': file.path,
        'data': apiData,
      });
      _scrollToBottom();
    } catch (e) {
      isCopilotChatLoading.value = false;
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
      copilotChatMessages.add({
        'sender': 'bot',
        'type': 'error',
        'text': cleanError,
      });
      _scrollToBottom();
    }
  }

  void applyCopilotSuggestion(Map<String, dynamic> data, String? imagePath) {
    final title = (data['title'] ?? data['name'] ?? data['productName'] ?? '').toString();
    final desc = (data['description'] ?? data['desc'] ?? data['details'] ?? '').toString();
    final cat = (data['category'] ?? data['categoryName'] ?? '').toString();
    final subCat = (data['subCategory'] ?? data['sub_category'] ?? '').toString();
    final brand = (data['brand'] ?? data['brandName'] ?? '').toString();
    final condition = (data['condition'] ?? 'new').toString().toLowerCase();
    final priceRaw = data['price'] ?? data['suggestedPrice'] ?? data['targetPrice'];
    final stockRaw = data['stock'] ?? data['quantity'] ?? data['suggestedStock'];
    final sku = (data['sku'] ?? data['SKU'] ?? '').toString();
    final rawTags = data['tags'] ?? data['keywords'] ?? [];

    if (title.isNotEmpty) nameController.text = title;
    if (desc.isNotEmpty) descriptionController.text = desc;
    if (subCat.isNotEmpty) subCategoryController.text = subCat;
    if (brand.isNotEmpty) brandController.text = brand;
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
    }

    if (sku.isNotEmpty) skuController.text = sku;

    if (rawTags is List && rawTags.isNotEmpty) {
      tagsController.text = rawTags.map((e) => e.toString().trim()).join(', ');
    } else if (rawTags is String && rawTags.isNotEmpty) {
      tagsController.text = rawTags;
    }

    if (imagePath != null && imagePath.isNotEmpty && !imagePaths.contains(imagePath)) {
      imagePaths.insert(0, imagePath);
    }

    Get.back();
    CustomPopup.showSuccess('Applied! ✨', 'Copilot details applied to your product form.');
  }

  Widget _buildCopilotChatBottomSheet(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Container(
      height: mediaQuery.size.height * 0.88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Chat Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
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
                    ),
                  ),
                ),
                const SizedBox(width: 12),
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
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Color(0xFF38A169),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Online • Product Assistant',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
          ),
          // Messages thread
          Expanded(
            child: Obx(
              () => ListView.builder(
                controller: copilotScrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                itemCount: copilotChatMessages.length + (isCopilotChatLoading.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == copilotChatMessages.length && isCopilotChatLoading.value) {
                    return _buildBotLoadingBubble();
                  }
                  final msg = copilotChatMessages[index];
                  final isBot = msg['sender'] == 'bot';
                  if (isBot) {
                    return _buildBotMessageBubble(context, msg);
                  } else {
                    return _buildUserMessageBubble(context, msg);
                  }
                },
              ),
            ),
          ),
          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isCopilotChatLoading.value
                          ? null
                          : () => sendImageToCopilot(source: ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_outlined, color: Color(0xFF6B46C1), size: 20),
                      label: const Text(
                        'Take Photo',
                        style: TextStyle(color: Color(0xFF6B46C1), fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF6B46C1), width: 1.2),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isCopilotChatLoading.value
                          ? null
                          : () => sendImageToCopilot(source: ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined, color: Colors.white, size: 20),
                      label: const Text(
                        'Upload Image',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B46C1),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserMessageBubble(BuildContext context, Map<String, dynamic> msg) {
    final imagePath = msg['imagePath'] as String?;
    final text = msg['text'] as String? ?? '';
    final screenWidth = MediaQuery.of(context).size.width;

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, left: 44, right: 2),
        constraints: BoxConstraints(maxWidth: screenWidth * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6B46C1), Color(0xFF7C3AED)],
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(4),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (imagePath != null && imagePath.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(imagePath),
                  height: 110,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              text,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotMessageBubble(BuildContext context, Map<String, dynamic> msg) {
    final type = msg['type'] as String? ?? 'text';
    final text = msg['text'] as String? ?? '';
    final data = msg['data'] as Map<String, dynamic>? ?? {};
    final imagePath = msg['imagePath'] as String?;
    final screenWidth = MediaQuery.of(context).size.width;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14, right: 8),
        constraints: BoxConstraints(maxWidth: screenWidth * 0.88),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: const Color(0xFF6B46C1).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Lottie.asset(
                'assets/lotties/chatbot.json',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.smart_toy_outlined,
                  size: 18,
                  color: Color(0xFF6B46C1),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: type == 'error' ? const Color(0xFFFEF2F2) : const Color(0xFFF7FAFC),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  border: Border.all(
                    color: type == 'error' ? const Color(0xFFFECACA) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: type == 'suggestion'
                    ? _buildSuggestionCard(data, imagePath)
                    : type == 'error'
                        ? _buildErrorBubbleContent(text)
                        : Text(
                            text,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.45,
                              color: Color(0xFF2D3748),
                            ),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBubbleContent(String errorText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 18),
            SizedBox(width: 6),
            Text(
              'Backend AI Error',
              style: TextStyle(
                color: Color(0xFFDC2626),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          errorText,
          style: const TextStyle(
            fontSize: 12,
            height: 1.4,
            color: Color(0xFF991B1B),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFFCA5A5)),
          ),
          child: const Text(
            '💡 Server Issue: Backend developer ko server par configured AI model name update karna hoga.',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF7F1D1D),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionCard(Map<String, dynamic> data, String? imagePath) {
    final title = (data['title'] ?? data['name'] ?? data['productName'] ?? 'Detected Product').toString();
    final desc = (data['description'] ?? data['desc'] ?? data['details'] ?? '').toString();
    final cat = (data['category'] ?? data['categoryName'] ?? '').toString();
    final subCat = (data['subCategory'] ?? data['sub_category'] ?? '').toString();
    final brand = (data['brand'] ?? data['brandName'] ?? '').toString();
    final price = (data['price'] ?? data['suggestedPrice'] ?? data['targetPrice'] ?? '').toString();
    final tags = data['tags'] ?? data['keywords'] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF6B46C1).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, color: Color(0xFF6B46C1), size: 12),
                  SizedBox(width: 4),
                  Text(
                    'AI Suggestion',
                    style: TextStyle(
                      color: Color(0xFF6B46C1),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            if (price.isNotEmpty && price != '0')
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFDEF7EC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Rs. $price',
                  style: const TextStyle(
                    color: Color(0xFF03543F),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A202C)),
        ),
        if (cat.isNotEmpty || subCat.isNotEmpty) ...[
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              if (cat.isNotEmpty)
                _buildChip(Icons.category_outlined, cat),
              if (subCat.isNotEmpty)
                _buildChip(Icons.account_tree_outlined, subCat),
              if (brand.isNotEmpty)
                _buildChip(Icons.verified_outlined, brand),
            ],
          ),
        ],
        if (desc.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            desc,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.3),
          ),
        ],
        if (tags is List && tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Tags: ${tags.take(4).join(', ')}',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
          ),
        ],
        const SizedBox(height: 14),
        // Action Buttons: Apply or Dismiss
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => applyCopilotSuggestion(data, imagePath),
                icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 16),
                label: const Text(
                  'Apply to Product Form',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B46C1),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            'If you don\'t like it, you can take another photo or close this chat.',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
          ),
        ),
      ],
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10.5, color: Colors.grey.shade800, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildBotLoadingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14, right: 40),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 34,
              height: 34,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: const Color(0xFF6B46C1).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Lottie.asset(
                'assets/lotties/chatbot.json',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.smart_toy_outlined,
                  size: 20,
                  color: Color(0xFF6B46C1),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF6B46C1),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Analyzing product image with AI...',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
