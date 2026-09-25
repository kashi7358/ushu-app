import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/errors/exception_handler.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';
import '../../domain/usecases/verify_email_usecase.dart';
import '../../domain/usecases/resend_otp_usecase.dart';
import '../../domain/usecases/forget_password_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/custom_popup.dart';
import '../../../../core/utils/session_manager.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';

class AuthController extends GetxController {
  final loginFormKey = GlobalKey<FormState>();
  final signupFormKey = GlobalKey<FormState>();
  final resetPasswordFormKey = GlobalKey<FormState>();

  // Login controllers
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();

  // Signup controllers
  final signupNameController = TextEditingController();
  final signupEmailController = TextEditingController();
  final signupPhoneController = TextEditingController();
  final signupPasswordController = TextEditingController();
  final signupConfirmPasswordController = TextEditingController();
  final signupAddressController = TextEditingController();

  // OTP controller
  final otpController = TextEditingController();

  // Forget Password controller
  final forgetPasswordEmailController = TextEditingController();

  // Reset Password controllers
  final resetTokenController = TextEditingController();
  final resetNewPasswordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;
  final RxBool termsAccepted = false.obs;

  // OTP Timer fields
  final RxInt resendTimer = 60.obs;
  final RxBool isResendEnabled = false.obs;
  Timer? _timer;

  String? currentBuyerId;

  void startResendTimer() {
    _timer?.cancel();
    resendTimer.value = 60;
    isResendEnabled.value = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendTimer.value > 0) {
        resendTimer.value--;
      } else {
        isResendEnabled.value = true;
        _timer?.cancel();
      }
    });
  }

  late final LoginUseCase _loginUseCase;
  late final SignupUseCase _signupUseCase;
  late final VerifyEmailUseCase _verifyEmailUseCase;
  late final ResendOtpUseCase _resendOtpUseCase;
  late final ForgetPasswordUseCase _forgetPasswordUseCase;
  late final ResetPasswordUseCase _resetPasswordUseCase;

  @override
  void onInit() {
    super.onInit();
    final apiClient = ApiClient();
    final remoteDataSource = AuthRemoteDataSourceImpl(apiClient);
    final repository = AuthRepositoryImpl(remoteDataSource);
    
    _loginUseCase = LoginUseCase(repository);
    _signupUseCase = SignupUseCase(repository);
    _verifyEmailUseCase = VerifyEmailUseCase(repository);
    _resendOtpUseCase = ResendOtpUseCase(repository);
    _forgetPasswordUseCase = ForgetPasswordUseCase(repository);
    _resetPasswordUseCase = ResetPasswordUseCase(repository);
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  void toggleTerms() {
    termsAccepted.value = !termsAccepted.value;
  }

  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) return;
    
    try {
      isLoading.value = true;
      final user = await _loginUseCase.execute(
        loginEmailController.text.trim(),
        loginPasswordController.text,
      );
      
      await SessionManager.saveSession(user.id, user.email, user.fullName, token: user.token);
      await SessionManager.fetchUserAddressFromBackend();
      CustomPopup.showSuccess('Success!', 'Welcome back, ${user.fullName}!');
      Get.offAllNamed(AppRoutes.mainLayout);
      
    } catch (e) {
      final error = ExceptionHandler.handle(e);
      CustomPopup.showError('Oops!', error.message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signup() async {
    if (!signupFormKey.currentState!.validate()) return;
    if (!termsAccepted.value) {
      CustomPopup.showError('Oops!', 'Please accept the Terms and Conditions');
      return;
    }
    if (signupPasswordController.text != signupConfirmPasswordController.text) {
      CustomPopup.showError('Oops!', 'Passwords do not match');
      return;
    }

    try {
      isLoading.value = true;
      
      final user = await _signupUseCase.execute(
        fullName: signupNameController.text.trim(),
        email: signupEmailController.text.trim(),
        phone: signupPhoneController.text.trim(),
        password: signupPasswordController.text,
        confirmPassword: signupConfirmPasswordController.text,
        address: signupAddressController.text.trim(),
      );

      currentBuyerId = user.id;
      
      // Save session if signup automatically logs the user in (adjust as per backend flow)
      await SessionManager.saveSession(user.id, user.email, user.fullName, token: user.token);
      
      CustomPopup.showSuccess('Success!', 'Account created successfully. Please verify your email.');
      Get.toNamed(AppRoutes.otp);
    } catch (e) {
      final error = ExceptionHandler.handle(e);
      CustomPopup.showError('Oops!', error.message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyEmail() async {
    final otp = otpController.text.trim();
    if (otp.isEmpty) {
      CustomPopup.showError('Oops!', 'Please enter the OTP code.');
      return;
    }
    if (currentBuyerId == null || currentBuyerId!.isEmpty) {
      currentBuyerId = SessionManager.userId;
    }
    if (currentBuyerId == null || currentBuyerId!.isEmpty) {
      CustomPopup.showError('Oops!', 'Missing buyer reference. Please login or signup again.');
      return;
    }

    try {
      isLoading.value = true;
      
      await _verifyEmailUseCase.execute(currentBuyerId!, otp);

      // Perform direct auto-login using signup credentials
      if (signupEmailController.text.trim().isNotEmpty && signupPasswordController.text.isNotEmpty) {
        try {
          final user = await _loginUseCase.execute(
            signupEmailController.text.trim(),
            signupPasswordController.text,
          );
          await SessionManager.saveSession(user.id, user.email, user.fullName, token: user.token);
        } catch (_) {
          // Keep existing session saved from signup
        }
      }

      CustomPopup.showSuccess('Success!', 'OTP Verified Successfully!');
      otpController.clear();
      
      // Delay milliseconds then navigate to home
      await Future.delayed(const Duration(milliseconds: 600));
      Get.offAllNamed(AppRoutes.mainLayout);
    } catch (e) {
      final error = ExceptionHandler.handle(e);
      CustomPopup.showError('Invalid OTP', error.message.isNotEmpty ? error.message : 'Invalid OTP code. Please check and try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOtp() async {
    if (!isResendEnabled.value && resendTimer.value > 0) return;

    if (currentBuyerId == null || currentBuyerId!.isEmpty) {
      currentBuyerId = SessionManager.userId;
    }
    if (currentBuyerId == null || currentBuyerId!.isEmpty) {
      CustomPopup.showError('Oops!', 'Missing buyer reference.');
      return;
    }

    try {
      isLoading.value = true;
      
      await _resendOtpUseCase.execute(currentBuyerId!);

      CustomPopup.showSuccess('Success!', 'OTP has been resent to your email.');
      startResendTimer();
    } catch (e) {
      final error = ExceptionHandler.handle(e);
      CustomPopup.showError('Error', error.message.isNotEmpty ? error.message : 'Could not resend OTP. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> forgetPassword() async {
    final email = forgetPasswordEmailController.text.trim();
    if (email.isEmpty) {
      CustomPopup.showError('Oops!', 'Please enter your email');
      return;
    }

    try {
      isLoading.value = true;
      
      await _forgetPasswordUseCase.execute(email);

      CustomPopup.showSuccess('Success!', 'A password reset token has been sent to your email.');
      
      forgetPasswordEmailController.clear();
      // Navigate to Reset Password Screen so they can enter the token
      Get.toNamed(AppRoutes.resetPassword);
    } catch (e) {
      final error = ExceptionHandler.handle(e);
      CustomPopup.showError('Oops!', error.message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword() async {
    if (!resetPasswordFormKey.currentState!.validate()) return;
    
    try {
      isLoading.value = true;
      
      await _resetPasswordUseCase.execute(
        resetTokenController.text.trim(),
        resetNewPasswordController.text,
      );

      CustomPopup.showSuccess('Success!', 'Password has been reset successfully. Please login.');
      
      resetTokenController.clear();
      resetNewPasswordController.clear();
      
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      final error = ExceptionHandler.handle(e);
      CustomPopup.showError('Oops!', error.message);
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToSignup() {
    Get.toNamed(AppRoutes.signup);
  }

  void navigateToLogin() {
    Get.back();
  }
  
  void navigateToForgetPassword() {
    Get.toNamed(AppRoutes.forgetPassword);
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
