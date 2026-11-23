import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/session_manager.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../../../wishlist/presentation/controllers/wishlist_controller.dart';

class HomeBuyerHeader extends StatelessWidget {
  const HomeBuyerHeader({super.key});

  ({String text, IconData icon}) _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return (text: 'Good Morning,', icon: Icons.wb_sunny_rounded);
    } else if (hour >= 12 && hour < 17) {
      return (text: 'Good Afternoon,', icon: Icons.wb_sunny_rounded);
    } else if (hour >= 17 && hour < 21) {
      return (text: 'Good Evening,', icon: Icons.wb_twilight_rounded);
    } else {
      return (text: 'Good Night,', icon: Icons.nightlight_round);
    }
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

  bool _isValidNetworkUrl(String url) {
    return url.isNotEmpty &&
        (url.startsWith('http://') || url.startsWith('https://'));
  }

  @override
  Widget build(BuildContext context) {
    final profileCtrl = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController(), permanent: true);
    final wishlistCtrl = Get.isRegistered<WishlistController>()
        ? Get.find<WishlistController>()
        : Get.put(WishlistController(), permanent: true);
    final greeting = _getGreeting();

    return Container(
      padding: const EdgeInsets.fromLTRB(AppDimensions.md, 14, AppDimensions.md, 8),
      color: AppColors.lightBackground,
      child: Row(
        children: [
          Expanded(
            child: Obx(() {
              final isLoggedIn = SessionManager.isUserLoggedInRx.value;
              final isLoading = profileCtrl.isProfileLoading.value;
              final rawName = profileCtrl.userName.value.trim();
              final rawEmail = profileCtrl.userEmail.value.trim();
              final avatarUrl = profileCtrl.userAvatar.value.trim();
              final address = profileCtrl.userAddress.value.trim();
              final verified = profileCtrl.isVerified.value;
              final profile = profileCtrl.buyerProfile.value;

              if (isLoggedIn &&
                  isLoading &&
                  rawName.isEmpty &&
                  profile == null) {
                return _buildLoadingSkeleton();
              }

              if (!isLoggedIn) {
                return _buildGuestLeft(greeting);
              }

              final String displayName;
              if (rawName.isNotEmpty) {
                displayName = rawName;
              } else if (profile != null) {
                displayName = profile.displayName;
              } else if (rawEmail.contains('@') &&
                  rawEmail.split('@').first.trim().isNotEmpty) {
                displayName = rawEmail.split('@').first.trim();
              } else {
                displayName = 'USHU Member';
              }

              final initials = _computeInitials(displayName);
              final hasAvatar = _isValidNetworkUrl(avatarUrl);

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Get.toNamed(AppRoutes.buyerProfile),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                    child: Row(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.primaryPurple,
                                    AppColors.secondaryViolet,
                                    AppColors.accentOrange,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryPurple.withValues(alpha: 0.18),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: hasAvatar
                                    ? ClipOval(
                                        child: Image.network(
                                          avatarUrl,
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              _buildInitialsCircle(initials),
                                        ),
                                      )
                                    : _buildInitialsCircle(initials),
                              ),
                            ),
                            Positioned(
                              right: -1,
                              bottom: -1,
                              child: verified
                                  ? Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 1.8),
                                      ),
                                      child: const Icon(
                                        Icons.check_rounded,
                                        size: 10,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Container(
                                      width: 11,
                                      height: 11,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 1.8),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    greeting.icon,
                                    size: 13,
                                    color: AppColors.accentOrange,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      greeting.text,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.medium.copyWith(
                                        fontSize: 11.5,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 1),
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      displayName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.extraBold.copyWith(
                                        fontSize: 16.5,
                                        color: AppColors.darkText,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (address.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_rounded,
                                      size: 12,
                                      color: AppColors.primaryPurple.withValues(alpha: 0.75),
                                    ),
                                    const SizedBox(width: 3),
                                    Expanded(
                                      child: Text(
                                        address,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.regular.copyWith(
                                          fontSize: 11,
                                          color: const Color(0xFF64748B),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ] else if (rawEmail.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  rawEmail,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.regular.copyWith(
                                    fontSize: 11,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(width: 12),
          Obx(() {
            final isLoggedIn = SessionManager.isUserLoggedInRx.value;
            final wishCount = wishlistCtrl.wishlistedProductIds.length;

            if (isLoggedIn) {
              return Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => Get.toNamed(AppRoutes.wishlist),
                    child: Center(
                      child: Badge(
                        isLabelVisible: wishCount > 0,
                        label: Text(
                          wishCount > 99 ? '99+' : wishCount.toString(),
                          style: const TextStyle(
                            fontSize: 9.5,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: AppColors.error,
                        child: const Icon(
                          Icons.favorite_outline_rounded,
                          size: 21,
                          color: AppColors.darkText,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }

            return Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryPurple, AppColors.secondaryViolet],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPurple.withValues(alpha: 0.24),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => Get.toNamed(AppRoutes.login),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.login_rounded, size: 14, color: Colors.white),
                        const SizedBox(width: 5),
                        Text(
                          'Sign In',
                          style: AppTextStyles.bold.copyWith(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInitialsCircle(String initials, {double fontSize = 15}) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.primaryPurple, AppColors.secondaryViolet],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: AppTextStyles.bold.copyWith(
          color: Colors.white,
          fontSize: fontSize,
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 90,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 145,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGuestLeft(({String text, IconData icon}) greeting) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Get.toNamed(AppRoutes.login),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryPurple.withValues(alpha: 0.14),
                      AppColors.secondaryViolet.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: AppColors.primaryPurple.withValues(alpha: 0.22),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppColors.primaryPurple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          greeting.icon,
                          size: 13,
                          color: AppColors.accentOrange,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            greeting.text,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.medium.copyWith(
                              fontSize: 11.5,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Welcome to USHU',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.extraBold.copyWith(
                        fontSize: 16,
                        color: AppColors.darkText,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Sign in to view your profile',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.semiBold.copyWith(
                              fontSize: 11.5,
                              color: AppColors.primaryPurple,
                            ),
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 13,
                          color: AppColors.primaryPurple,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
