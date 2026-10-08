import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/errors/exception_handler.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/custom_popup.dart';
import '../../../../core/utils/session_manager.dart';
import '../../data/datasources/seller_remote_data_source.dart';
import '../../data/models/create_store_request_model.dart';
import '../../data/repositories/seller_repository_impl.dart';
import '../../domain/repositories/seller_repository.dart';

class CreateStoreController extends GetxController {
  final formKey = GlobalKey<FormState>();

  // Text Controllers
  final storeNameController = TextEditingController();
  final storeTaglineController = TextEditingController();
  final descriptionController = TextEditingController();
  final languageController = TextEditingController(text: 'Urdu');
  final storeContactEmailController = TextEditingController();
  final storeWhatsappController = TextEditingController();
  final primaryCityController = TextEditingController();
  final warehouseAddressController = TextEditingController();
  final socialLinksController = TextEditingController();
  final returnPolicyController = TextEditingController(text: '14 days');
  final warrantyController = TextEditingController(text: '6 months');
  final processingTimeController = TextEditingController(text: '5-6 working days');
  final cancellationPolicyController = TextEditingController(text: 'No');
  final shippingMethodController = TextEditingController(text: 'Ecomme  service ');
  final deliveryZonesController = TextEditingController(text: 'All over Pakistan');
  final shippingChargesController = TextEditingController(text: '200');

  // Reactive dropdown selection variables
  final RxString selectedLanguage = 'Urdu'.obs;
  final RxString selectedReturnPolicy = '14 days'.obs;
  final RxString selectedWarranty = '6 months'.obs;
  final RxString selectedProcessingTime = '5-6 working days'.obs;
  final RxString selectedCancellationPolicy = 'No'.obs;
  final RxString selectedShippingMethod = 'Ecomme  service '.obs;
  final RxString selectedDeliveryZone = 'All over Pakistan'.obs;

  void setLanguage(String val) {
    selectedLanguage.value = val;
    languageController.text = val;
  }

  void setReturnPolicy(String val) {
    selectedReturnPolicy.value = val;
    returnPolicyController.text = val;
  }

  void setWarranty(String val) {
    selectedWarranty.value = val;
    warrantyController.text = val;
  }

  void setProcessingTime(String val) {
    selectedProcessingTime.value = val;
    processingTimeController.text = val;
  }

  void setCancellationPolicy(String val) {
    selectedCancellationPolicy.value = val;
    cancellationPolicyController.text = val;
  }

  void setShippingMethod(String val) {
    selectedShippingMethod.value = val;
    shippingMethodController.text = val;
  }

  void setDeliveryZone(String val) {
    selectedDeliveryZone.value = val;
    deliveryZonesController.text = val;
  }

  String sellerId = '';

  // Step Tracking
  final RxInt currentStep = 0.obs;
  final step1FormKey = GlobalKey<FormState>();
  final step2FormKey = GlobalKey<FormState>();
  final step3FormKey = GlobalKey<FormState>();

  // Images
  final Rx<String?> logoPath = Rx<String?>(null);
  final Rx<String?> storeBannerPath = Rx<String?>(null);

  final RxBool isLoading = false.obs;
  final ImagePicker _picker = ImagePicker();
  late final SellerRepository _repository;

  void nextStep() {
    if (currentStep.value == 0) {
      if (!step1FormKey.currentState!.validate()) return;
      if (logoPath.value == null || logoPath.value!.isEmpty) {
        CustomPopup.showError('Required', 'Please upload a Store Logo');
        return;
      }
      if (storeBannerPath.value == null || storeBannerPath.value!.isEmpty) {
        CustomPopup.showError('Required', 'Please upload a Store Banner');
        return;
      }
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

  // Selection Options
  final List<String> languages = ['Urdu', 'English'];
  final List<String> returnPolicies = ['7 days', '14 days', '30 days', 'No return'];
  final List<String> warranties = ['None', '6 months', '1 year', '2 years'];
  final List<String> processingTimes = ['1-2 working days', '3-4 working days', '5-6 working days', '7+ working days'];
  final List<String> cancellationPolicies = ['No', 'Yes', 'Within 24 hours'];
  final List<String> shippingMethods = ['Ecomme  service ', 'Standard Delivery', 'Express Courier'];
  final List<String> deliveryZonesList = ['All over Pakistan', 'Major Cities Only', 'Within Province'];

  @override
  void onInit() {
    super.onInit();
    final apiClient = ApiClient();
    final remoteDataSource = SellerRemoteDataSourceImpl(apiClient);
    _repository = SellerRepositoryImpl(remoteDataSource);

    // Auto-fill from signup data passed from previous step
    final args = Get.arguments;
    if (args is Map) {
      sellerId = args['sellerId']?.toString() ?? '';
      
      final signupStoreName = args['storeName']?.toString();
      if (signupStoreName != null && signupStoreName.isNotEmpty) {
        storeNameController.text = signupStoreName;
      }

      final signupEmail = args['email']?.toString();
      if (signupEmail != null && signupEmail.isNotEmpty) {
        storeContactEmailController.text = signupEmail;
      }

      final signupPhone = args['phone']?.toString();
      if (signupPhone != null && signupPhone.isNotEmpty) {
        storeWhatsappController.text = signupPhone;
      }

      final signupCity = args['city']?.toString();
      if (signupCity != null && signupCity.isNotEmpty) {
        primaryCityController.text = signupCity;
      }

      final signupAddress = args['businessAddress']?.toString();
      if (signupAddress != null && signupAddress.isNotEmpty) {
        warehouseAddressController.text = signupAddress;
      }
    }
  }

  @override
  void onClose() {
    storeNameController.dispose();
    storeTaglineController.dispose();
    descriptionController.dispose();
    languageController.dispose();
    storeContactEmailController.dispose();
    storeWhatsappController.dispose();
    primaryCityController.dispose();
    warehouseAddressController.dispose();
    socialLinksController.dispose();
    returnPolicyController.dispose();
    warrantyController.dispose();
    processingTimeController.dispose();
    cancellationPolicyController.dispose();
    shippingMethodController.dispose();
    deliveryZonesController.dispose();
    shippingChargesController.dispose();
    super.onClose();
  }

  Future<void> pickImage({required bool isLogo, required ImageSource source}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        if (isLogo) {
          logoPath.value = pickedFile.path;
        } else {
          storeBannerPath.value = pickedFile.path;
        }
      }
    } catch (e) {
      CustomPopup.showError('Image Error', 'Failed to pick image: $e');
    }
  }

  void removeImage({required bool isLogo}) {
    if (isLogo) {
      logoPath.value = null;
    } else {
      storeBannerPath.value = null;
    }
  }

  Future<void> createStore() async {
    if (step3FormKey.currentState != null && !step3FormKey.currentState!.validate()) return;

    if (logoPath.value == null || logoPath.value!.isEmpty) {
      CustomPopup.showError('Required', 'Please upload a Store Logo');
      currentStep.value = 0;
      return;
    }

    if (storeBannerPath.value == null || storeBannerPath.value!.isEmpty) {
      CustomPopup.showError('Required', 'Please upload a Store Banner');
      currentStep.value = 0;
      return;
    }

    try {
      isLoading.value = true;
      CustomPopup.showLoading('Creating your store...');

      final model = CreateStoreRequestModel(
        storeName: storeNameController.text.trim(),
        storeTagline: storeTaglineController.text.trim(),
        description: descriptionController.text.trim(),
        language: languageController.text.trim(),
        storeContactEmail: storeContactEmailController.text.trim(),
        storeWhatsapp: storeWhatsappController.text.trim(),
        primaryCity: primaryCityController.text.trim(),
        warehouseAddress: warehouseAddressController.text.trim(),
        socialLinks: socialLinksController.text.trim(),
        returnPolicy: returnPolicyController.text.trim(),
        warranty: warrantyController.text.trim(),
        processingTime: processingTimeController.text.trim(),
        cancellationPolicy: cancellationPolicyController.text.trim(),
        shippingMethod: shippingMethodController.text.trim(),
        deliveryZones: deliveryZonesController.text.trim(),
        shippingCharges: shippingChargesController.text.trim(),
        createdBy: sellerId,
        logoPath: logoPath.value,
        storeBannerPath: storeBannerPath.value,
      );

      final response = await _repository.createStore(model);
      CustomPopup.hideLoading();

      // Extract and save storeId
      String? newStoreId;
      if (response is Map) {
        newStoreId = response['storeId']?.toString() ??
            response['_id']?.toString() ??
            response['id']?.toString();
        if (newStoreId == null && response['store'] is Map) {
          final sMap = response['store'] as Map;
          newStoreId = sMap['_id']?.toString() ?? sMap['id']?.toString();
        }
        if (newStoreId == null && response['data'] is Map) {
          final dMap = response['data'] as Map;
          newStoreId = dMap['_id']?.toString() ?? dMap['id']?.toString() ?? dMap['storeId']?.toString();
        }
      }

      if (newStoreId != null && newStoreId.isNotEmpty) {
        await SessionManager.saveSellerStoreId(newStoreId);
      }

      final message = (response is Map && response['message'] != null)
          ? response['message'].toString()
          : 'Store created successfully!';

      CustomPopup.showSuccess('Store Created!', message);

      // Navigate directly to Seller Dashboard
      Get.offAllNamed(AppRoutes.sellerDashboard);
    } catch (e) {
      CustomPopup.hideLoading();
      final error = ExceptionHandler.handle(e);
      CustomPopup.showError('Store Creation Failed', error.message);
    } finally {
      isLoading.value = false;
    }
  }
}
