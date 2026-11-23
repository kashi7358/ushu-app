import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/session_manager.dart';
import '../controllers/profile_controller.dart';

class BuyerProfileScreen extends StatelessWidget {
  const BuyerProfileScreen({super.key});

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

  bool _isValidNetworkUrl(String url) {
    return url.isNotEmpty &&
        (url.startsWith('http://') || url.startsWith('https://'));
  }

  @override
  Widget build(BuildContext context) {
    final profileCtrl = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController(), permanent: true);

    if (SessionManager.isLoggedIn &&
        profileCtrl.buyerProfile.value == null &&
        !profileCtrl.isProfileLoading.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (SessionManager.isLoggedIn &&
            profileCtrl.buyerProfile.value == null &&
            !profileCtrl.isProfileLoading.value) {
          profileCtrl.fetchBuyerProfile(silent: true);
        }
      });
    }

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
          'My Profile',
          style: AppTextStyles.bold.copyWith(
            fontSize: 17,
            color: AppColors.darkText,
          ),
        ),
        actions: [
          Obx(() {
            if (profileCtrl.isProfileLoading.value) {
              return const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryPurple,
                    ),
                  ),
                ),
              );
            }
            return IconButton(
              tooltip: 'Refresh Profile',
              icon: const Icon(
                Icons.refresh_rounded,
                color: AppColors.primaryPurple,
                size: 22,
              ),
              onPressed: () => profileCtrl.fetchBuyerProfile(),
            );
          }),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryPurple,
          onRefresh: () => profileCtrl.fetchBuyerProfile(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Obx(() {
              final profile = profileCtrl.buyerProfile.value;
              final rawName = profileCtrl.userName.value.trim();
              final email = profileCtrl.userEmail.value.trim();
              final phone = profileCtrl.userPhone.value.trim();
              final address = profileCtrl.userAddress.value.trim();
              final avatarUrl = profileCtrl.userAvatar.value.trim();
              final verified = profileCtrl.isVerified.value;
              final role = (profile != null && profile.role.isNotEmpty)
                  ? profile.role
                  : 'Buyer';
              final memberSince = profile?.formattedMemberSince ?? '';

              final String displayName;
              if (rawName.isNotEmpty && rawName != 'Guest User') {
                displayName = rawName;
              } else if (profile != null) {
                displayName = profile.displayName;
              } else if (email.contains('@') &&
                  email.split('@').first.trim().isNotEmpty) {
                displayName = email.split('@').first.trim();
              } else {
                displayName = 'USHU Member';
              }

              final initials = _computeInitials(displayName);
              final hasAvatar = _isValidNetworkUrl(avatarUrl);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hero Profile Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.primaryPurple,
                          AppColors.secondaryViolet,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryPurple.withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.2),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: hasAvatar
                              ? ClipOval(
                                  child: Image.network(
                                    avatarUrl,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Center(
                                      child: Text(
                                        initials,
                                        style: AppTextStyles.extraBold.copyWith(
                                          color: Colors.white,
                                          fontSize: 21,
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
                                      fontSize: 21,
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.extraBold.copyWith(
                                  fontSize: 18.5,
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                email.isNotEmpty &&
                                        email != 'Login to view account details'
                                    ? email
                                    : 'No email linked',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.regular.copyWith(
                                  fontSize: 12.5,
                                  color: Colors.white.withValues(alpha: 0.85),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      role,
                                      style: AppTextStyles.semiBold.copyWith(
                                        fontSize: 11,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  if (verified)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981)
                                            .withValues(alpha: 0.24),
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
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Section Heading
                  Text(
                    'Profile Details',
                    style: AppTextStyles.bold.copyWith(
                      fontSize: 14.5,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Profile Details Card
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
                    child: Column(
                      children: [
                        _buildDetailRow(
                          icon: Icons.person_outline_rounded,
                          label: 'Full Name',
                          value: displayName,
                        ),
                        const Divider(height: 22, color: Color(0xFFE2E8F0)),
                        _buildDetailRow(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: email.isNotEmpty &&
                                  email != 'Login to view account details'
                              ? email
                              : 'Not provided',
                          isMuted: email.isEmpty ||
                              email == 'Login to view account details',
                        ),
                        const Divider(height: 22, color: Color(0xFFE2E8F0)),
                        _buildDetailRow(
                          icon: Icons.phone_outlined,
                          label: 'Phone',
                          value: phone.isNotEmpty ? phone : 'Not provided',
                          isMuted: phone.isEmpty,
                        ),
                        const Divider(height: 22, color: Color(0xFFE2E8F0)),
                        _buildDetailRow(
                          icon: Icons.location_on_outlined,
                          label: 'Address',
                          value: address.isNotEmpty ? address : 'Not added yet',
                          isMuted: address.isEmpty,
                        ),
                        const Divider(height: 22, color: Color(0xFFE2E8F0)),
                        _buildDetailRow(
                          icon: Icons.lock_outline_rounded,
                          label: 'Password',
                          value: '••••••••',
                          trailing: Material(
                            color: AppColors.primaryPurple.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => Get.toNamed(AppRoutes.changePassword),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.primaryPurple
                                        .withValues(alpha: 0.22),
                                  ),
                                ),
                                child: Text(
                                  'Change',
                                  style: AppTextStyles.bold.copyWith(
                                    fontSize: 11.5,
                                    color: AppColors.primaryPurple,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (memberSince.isNotEmpty) ...[
                          const Divider(height: 22, color: Color(0xFFE2E8F0)),
                          _buildDetailRow(
                            icon: Icons.calendar_today_outlined,
                            label: 'Member Since',
                            value: memberSince,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons: Edit Profile & Change Password
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.edit_outlined, size: 19),
                      label: Text(
                        'Edit Profile',
                        style: AppTextStyles.bold.copyWith(
                          fontSize: 14.5,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () => Get.toNamed(AppRoutes.editProfile),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: AppColors.primaryPurple.withValues(alpha: 0.4),
                          width: 1.4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(
                        Icons.lock_reset_rounded,
                        size: 20,
                        color: AppColors.primaryPurple,
                      ),
                      label: Text(
                        'Change Password',
                        style: AppTextStyles.bold.copyWith(
                          fontSize: 14.5,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                      onPressed: () => Get.toNamed(AppRoutes.changePassword),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    bool isMuted = false,
    Widget? trailing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primaryPurple.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.primaryPurple),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.medium.copyWith(
                  fontSize: 11,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.semiBold.copyWith(
                  fontSize: 13.5,
                  color: isMuted ? const Color(0xFF94A3B8) : AppColors.darkText,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing,
        ],
      ],
    );
  }
}
