import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/edit_profile_controller.dart';
import '../controllers/profile_controller.dart';

class EditProfileScreen extends StatefulWidget {
  final int initialTab;

  const EditProfileScreen({super.key, this.initialTab = 0});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final String _controllerTag;
  late final EditProfileController controller;
  late final ProfileController profileController;

  @override
  void initState() {
    super.initState();
    int resolvedTab = widget.initialTab == 1 ? 1 : 0;
    final args = Get.arguments;
    if (args is Map && args['tab'] is int) {
      resolvedTab = (args['tab'] as int) == 1 ? 1 : 0;
    }
    _controllerTag = 'edit_profile_${identityHashCode(this)}';
    controller = Get.put(
      EditProfileController(initialTab: resolvedTab),
      tag: _controllerTag,
    );
    profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController(), permanent: true);
  }

  @override
  void dispose() {
    if (Get.isRegistered<EditProfileController>(tag: _controllerTag)) {
      Get.delete<EditProfileController>(tag: _controllerTag, force: true);
    }
    super.dispose();
  }

  String _computeInitials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts.length == 1 && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'U';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.darkText,
            size: 18,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Account Settings',
          style: AppTextStyles.bold.copyWith(
            fontSize: 17,
            color: AppColors.darkText,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Live Profile Summary Banner
              Obx(() {
                final rawName = profileController.userName.value.trim();
                final displayName = rawName.isNotEmpty && rawName != 'Guest User'
                    ? rawName
                    : (profileController.buyerProfile.value?.displayName ??
                        'USHU Member');
                final email = profileController.userEmail.value.trim();
                final avatarUrl = profileController.userAvatar.value.trim();
                final hasAvatar = avatarUrl.isNotEmpty &&
                    (avatarUrl.startsWith('http://') ||
                        avatarUrl.startsWith('https://'));
                final initials = _computeInitials(displayName);
                final verified = profileController.isVerified.value;

                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryPurple, AppColors.secondaryViolet],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryPurple.withValues(alpha: 0.22),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.2),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: hasAvatar
                            ? ClipOval(
                                child: Image.network(
                                  avatarUrl,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Center(
                                    child: Text(
                                      initials,
                                      style: AppTextStyles.extraBold.copyWith(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Center(
                                child: Text(
                                  initials,
                                  style: AppTextStyles.extraBold.copyWith(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.extraBold.copyWith(
                                fontSize: 17,
                                color: Colors.white,
                              ),
                            ),
                            if (email.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                email,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.regular.copyWith(
                                  fontSize: 12.5,
                                  color: Colors.white.withValues(alpha: 0.85),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (verified) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.24),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF6EE7B7),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.verified_rounded,
                                size: 13,
                                color: Color(0xFF6EE7B7),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Verified',
                                style: AppTextStyles.semiBold.copyWith(
                                  fontSize: 11,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),

              // Pill Segmented Toggle
              Obx(() {
                final activeTab = controller.selectedTab.value;
                return Container(
                  height: 48,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0).withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      _buildTabButton(
                        icon: Icons.person_outline_rounded,
                        label: 'Edit Profile',
                        isSelected: activeTab == 0,
                        onTap: () => controller.switchTab(0),
                      ),
                      _buildTabButton(
                        icon: Icons.lock_outline_rounded,
                        label: 'Change Password',
                        isSelected: activeTab == 1,
                        onTap: () => controller.switchTab(1),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),

              // Active Form Section
              Obx(() {
                if (controller.selectedTab.value == 0) {
                  return _buildEditProfileTab();
                }
                return _buildChangePasswordTab();
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 17,
                  color: isSelected
                      ? AppColors.primaryPurple
                      : const Color(0xFF64748B),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primaryPurple
                          : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditProfileTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Form(
            key: controller.profileFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFieldLabel('Full Name'),
                AppTextField(
                  controller: controller.fullNameController,
                  hintText: 'Enter your full name',
                  validator: Validators.validateName,
                  prefixIcon: const Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.primaryPurple,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 14),
                _buildFieldLabel('Email Address'),
                AppTextField(
                  controller: controller.emailController,
                  hintText: 'Email address',
                  readOnly: true,
                  enabled: false,
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: AppColors.hintText,
                    size: 20,
                  ),
                  suffixIcon: const Icon(
                    Icons.lock_outline_rounded,
                    color: AppColors.hintText,
                    size: 17,
                  ),
                ),
                const SizedBox(height: 14),
                _buildFieldLabel('Phone Number'),
                AppTextField(
                  controller: controller.phoneController,
                  hintText: '03001234567 (11 digits)',
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                  validator: (val) => (val == null || val.trim().isEmpty)
                      ? null
                      : Validators.validatePhone(val),
                  prefixIcon: const Icon(
                    Icons.phone_outlined,
                    color: AppColors.primaryPurple,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 14),
                _buildFieldLabel('Address'),
                AppTextField(
                  controller: controller.addressController,
                  hintText: 'Enter your delivery address',
                  maxLines: 2,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 18),
                    child: Icon(
                      Icons.location_on_outlined,
                      color: AppColors.primaryPurple,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        AppButton(
          text: 'Save Changes',
          isLoading: controller.isUpdatingProfile.value,
          onPressed: controller.updateProfile,
        ),
      ],
    );
  }

  Widget _buildChangePasswordTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primaryPurple.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.primaryPurple.withValues(alpha: 0.18),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.shield_outlined,
                color: AppColors.primaryPurple,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Use at least 8 characters with letters and numbers for a strong password.',
                  style: AppTextStyles.medium.copyWith(
                    fontSize: 12,
                    color: AppColors.darkText,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Form(
            key: controller.passwordFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFieldLabel('Current Password'),
                AppTextField(
                  controller: controller.currentPasswordController,
                  hintText: 'Enter current password',
                  isPassword: !controller.showCurrentPassword.value,
                  validator: Validators.validateLoginPassword,
                  prefixIcon: const Icon(
                    Icons.lock_open_rounded,
                    color: AppColors.primaryPurple,
                    size: 20,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.showCurrentPassword.value
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.hintText,
                      size: 20,
                    ),
                    onPressed: () => controller.showCurrentPassword.toggle(),
                  ),
                ),
                const SizedBox(height: 14),
                _buildFieldLabel('New Password'),
                AppTextField(
                  controller: controller.newPasswordController,
                  hintText: 'Enter new password',
                  isPassword: !controller.showNewPassword.value,
                  validator: (val) {
                    final baseErr = Validators.validatePassword(val);
                    if (baseErr != null) return baseErr;
                    if (val == controller.currentPasswordController.text) {
                      return 'New password must be different from current password';
                    }
                    return null;
                  },
                  prefixIcon: const Icon(
                    Icons.lock_outline_rounded,
                    color: AppColors.primaryPurple,
                    size: 20,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.showNewPassword.value
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.hintText,
                      size: 20,
                    ),
                    onPressed: () => controller.showNewPassword.toggle(),
                  ),
                ),
                const SizedBox(height: 14),
                _buildFieldLabel('Confirm New Password'),
                AppTextField(
                  controller: controller.confirmPasswordController,
                  hintText: 'Re-enter new password',
                  isPassword: !controller.showConfirmPassword.value,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Please confirm your new password';
                    }
                    if (val != controller.newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  prefixIcon: const Icon(
                    Icons.verified_user_outlined,
                    color: AppColors.primaryPurple,
                    size: 20,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.showConfirmPassword.value
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.hintText,
                      size: 20,
                    ),
                    onPressed: () => controller.showConfirmPassword.toggle(),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        AppButton(
          text: 'Update Password',
          isLoading: controller.isChangingPassword.value,
          onPressed: controller.changePassword,
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: AppTextStyles.semiBold.copyWith(
          fontSize: 12.5,
          color: AppColors.darkText,
        ),
      ),
    );
  }
}
