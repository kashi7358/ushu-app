import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/errors/exception_handler.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/custom_popup.dart';
import '../../data/datasources/seller_remote_data_source.dart';
import '../../data/models/seller_registration_model.dart';
import '../../data/repositories/seller_repository_impl.dart';
import '../../domain/repositories/seller_repository.dart';

class SellerRegisterController extends GetxController {
  // Step indicator (0: Account, 1: Store/Business, 2: Bank & Verification)
  final RxInt currentStep = 0.obs;

  // Form Keys for each step
  final step1FormKey = GlobalKey<FormState>();
  final step2FormKey = GlobalKey<FormState>();
  final step3FormKey = GlobalKey<FormState>();

  // Step 1: Account Controllers
  final fullNameController = TextEditingController();
  final displayNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Step 2: Business & Store Controllers
  final storeNameController = TextEditingController();
  final businessTypeController = TextEditingController(text: 'Sole properietory');
  final cityController = TextEditingController();
  final provinceController = TextEditingController(text: 'KPK');
  final businessAddressController = TextEditingController();
  final monthlySalesEstimateController = TextEditingController(text: '1 Million');

  final RxString selectedBusinessType = 'Sole properietory'.obs;
  final RxString selectedProvince = 'KPK'.obs;
  final RxString selectedMonthlySalesEstimate = '1 Million'.obs;

  // Step 3: Bank & Identity Controllers
  final cnicController = TextEditingController();
  final ibanController = TextEditingController();
  final bankNameController = TextEditingController(text: 'BOK');
  final accountHolderController = TextEditingController();

  final RxString selectedBankName = 'BOK'.obs;

  void setBusinessType(String val) {
    selectedBusinessType.value = val;
    businessTypeController.text = val;
  }

  void setProvince(String val) {
    selectedProvince.value = val;
    provinceController.text = val;
  }

  void setMonthlySalesEstimate(String val) {
    selectedMonthlySalesEstimate.value = val;
    monthlySalesEstimateController.text = val;
  }

  void setBankName(String val) {
    selectedBankName.value = val;
    bankNameController.text = val;
  }

  // CNIC Images
  final Rx<String?> cnicFrontPhotoPath = Rx<String?>(null);
  final Rx<String?> cnicBackPhotoPath = Rx<String?>(null);

  // UI state
  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;

  final ImagePicker _picker = ImagePicker();
  late final SellerRepository _repository;

  // Predefined selection lists
  final List<String> businessTypes = [
    'Sole properietory',
    'Partnership',
    'Private Limited',
    'Corporate / Enterprise',
  ];

  final List<String> provinces = [
    'KPK',
    'Punjab',
    'Sindh',
    'Balochistan',
    'Islamabad Capital Territory',
    'Gilgit-Baltistan',
    'Azad Jammu & Kashmir',
  ];

  final List<String> salesEstimates = [
    'Under 100K',
    '100K - 500K',
    '500K - 1 Million',
    '1 Million',
    '2 - 5 Million',
    '5 Million+',
  ];

  final List<String> popularBanks = [
    'BOK',
    'Meezan Bank',
    'Habib Bank Limited (HBL)',
    'United Bank Limited (UBL)',
    'MCB Bank',
    'Allied Bank Limited (ABL)',
    'Bank Alfalah',
    'Faysal Bank',
    'Askari Bank',
    'Bank of Punjab (BOP)',
    'Standard Chartered',
    'Other',
  ];

  @override
  void onInit() {
    super.onInit();
    final apiClient = ApiClient();
    final remoteDataSource = SellerRemoteDataSourceImpl(apiClient);
    _repository = SellerRepositoryImpl(remoteDataSource);
  }

  @override
  void onClose() {
    fullNameController.dispose();
    displayNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    storeNameController.dispose();
    businessTypeController.dispose();
    cityController.dispose();
    provinceController.dispose();
    businessAddressController.dispose();
    monthlySalesEstimateController.dispose();

    cnicController.dispose();
    ibanController.dispose();
    bankNameController.dispose();
    accountHolderController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  // Step Navigation
  void nextStep() {
    if (currentStep.value == 0) {
      if (!step1FormKey.currentState!.validate()) return;
      if (passwordController.text != confirmPasswordController.text) {
        CustomPopup.showError('Error', 'Passwords do not match');
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

  // Image Picking
  Future<void> pickCnicImage({required bool isFront, required ImageSource source}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        if (isFront) {
          cnicFrontPhotoPath.value = pickedFile.path;
        } else {
          cnicBackPhotoPath.value = pickedFile.path;
        }
      }
    } catch (e) {
      CustomPopup.showError('Image Error', 'Failed to pick image: $e');
    }
  }

  void removeCnicImage({required bool isFront}) {
    if (isFront) {
      cnicFrontPhotoPath.value = null;
    } else {
      cnicBackPhotoPath.value = null;
    }
  }

  // Submit Registration
  Future<void> submitRegistration() async {
    if (!step3FormKey.currentState!.validate()) return;

    if (cnicFrontPhotoPath.value == null || cnicFrontPhotoPath.value!.isEmpty) {
      CustomPopup.showError('Verification Required', 'Please upload your CNIC Front Photo');
      return;
    }

    if (cnicBackPhotoPath.value == null || cnicBackPhotoPath.value!.isEmpty) {
      CustomPopup.showError('Verification Required', 'Please upload your CNIC Back Photo');
      return;
    }

    try {
      isLoading.value = true;
      CustomPopup.showLoading('Submitting seller application...');

      final model = SellerRegistrationModel(
        fullName: fullNameController.text.trim(),
        displayName: displayNameController.text.trim(),
        email: emailController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        password: passwordController.text,
        confirmPassword: confirmPasswordController.text,
        role: 'Seller',
        storeName: storeNameController.text.trim(),
        businessType: businessTypeController.text.trim(),
        city: cityController.text.trim(),
        province: provinceController.text.trim(),
        businessAddress: businessAddressController.text.trim(),
        monthlySalesEstimate: monthlySalesEstimateController.text.trim(),
        cnic: cnicController.text.trim(),
        ibanNumber: ibanController.text.trim(),
        bankName: bankNameController.text.trim(),
        accountHolder: accountHolderController.text.trim(),
        cnicFrontPhotoPath: cnicFrontPhotoPath.value,
        cnicBackPhotoPath: cnicBackPhotoPath.value,
      );

      final response = await _repository.registerSeller(model);
      CustomPopup.hideLoading();

      String? sellerId;
      String message = 'Application submitted. Please verify OTP sent to your email.';

      if (response is Map) {
        if (response['sellerId'] != null) {
          sellerId = response['sellerId'].toString();
        } else if (response['data'] is Map && response['data']['sellerId'] != null) {
          sellerId = response['data']['sellerId'].toString();
        }
        if (response['message'] != null) {
          message = response['message'].toString();
        }
      }

      final signupData = {
        'sellerId': sellerId ?? '',
        'email': emailController.text.trim(),
        'fullName': fullNameController.text.trim(),
        'displayName': displayNameController.text.trim(),
        'phone': phoneController.text.trim(),
        'storeName': storeNameController.text.trim(),
        'city': cityController.text.trim(),
        'province': provinceController.text.trim(),
        'businessAddress': businessAddressController.text.trim(),
      };

      CustomPopup.showSuccess(
        'Application Submitted!',
        message,
        buttonText: 'Verify Email',
        onConfirm: () {
          if (sellerId != null && sellerId.isNotEmpty) {
            Get.toNamed(
              AppRoutes.sellerOtp,
              arguments: signupData,
            );
          } else {
            Get.offNamed(
              AppRoutes.sellerCreateStore,
              arguments: signupData,
            );
          }
        },
      );
    } catch (e) {
      CustomPopup.hideLoading();
      final error = ExceptionHandler.handle(e);
      CustomPopup.showError('Registration Failed', error.message);
    } finally {
      isLoading.value = false;
    }
  }
}
