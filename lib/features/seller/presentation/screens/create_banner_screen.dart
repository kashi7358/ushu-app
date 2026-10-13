import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/create_banner_controller.dart';

class CreateBannerScreen extends StatelessWidget {
  const CreateBannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreateBannerController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: const Color(0xFF0F172A),
            size: 18.sp,
          ),
          onPressed: () => Get.back(),
        ),
        title: Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.isEditMode.value
                  ? 'Update Seller Banner'
                  : 'Create Promotional Banner',
              style: TextStyle(
                color: const Color(0xFF0F172A),
                fontSize: 17.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              controller.isEditMode.value
                  ? 'Edit and update your live banner campaign'
                  : 'Design & schedule your store campaign banner',
              style: TextStyle(
                color: const Color(0xFF64748B),
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        )),
      ),
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 110.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBannerImageSection(context, controller),
              SizedBox(height: 18.h),
              _buildCampaignDetailsCard(context, controller),
              SizedBox(height: 18.h),
              _buildScheduleCard(context, controller),
              SizedBox(height: 18.h),
              _buildSellerContactCard(controller),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomSubmitBar(controller),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accentColor,
  }) {
    return Row(
      children: [
        Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: accentColor, size: 19.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11.5.sp,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBannerImageSection(
    BuildContext context,
    CreateBannerController controller,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.panorama_outlined,
            title: 'Banner Artwork',
            subtitle: 'Upload high-resolution wide promotional image',
            accentColor: const Color(0xFF6366F1),
          ),
          SizedBox(height: 14.h),
          Obx(() {
            final file = controller.selectedBannerImage.value;
            final existingUrl = controller.existingImageUrl.value;

            if (file != null || existingUrl.isNotEmpty) {
              return Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: file != null
                              ? Image.file(
                                  file,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  existingUrl,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: const Color(0xFFF1F5F9),
                                    child: const Center(
                                      child: Icon(Icons.broken_image_rounded, size: 36, color: Color(0xFF94A3B8)),
                                    ),
                                  ),
                                ),
                        ),
                        Positioned(
                          top: 10.h,
                          right: 10.w,
                          child: Row(
                            children: [
                              _buildImageOverlayAction(
                                icon: Icons.edit_rounded,
                                label: 'Change',
                                onTap: () => _showImageSourceSheet(context, controller),
                              ),
                              SizedBox(width: 8.w),
                              _buildImageOverlayAction(
                                icon: Icons.delete_outline_rounded,
                                label: 'Remove',
                                isDanger: true,
                                onTap: controller.removeBannerImage,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return InkWell(
              onTap: () => _showImageSourceSheet(context, controller),
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                width: double.infinity,
                height: 165.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: const Color(0xFFCBD5E1),
                    width: 1.4,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.cloud_upload_outlined,
                        size: 28.sp,
                        color: const Color(0xFF6366F1),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Tap to Upload Banner Image',
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Supports JPG, PNG or WEBP (16:9 recommended)',
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildImageOverlayAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return Material(
      color: isDanger
          ? const Color(0xFFEF4444).withValues(alpha: 0.9)
          : const Color(0xFF0F172A).withValues(alpha: 0.78),
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 14.sp),
              SizedBox(width: 4.w),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageSourceSheet(
    BuildContext context,
    CreateBannerController controller,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Banner Image',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 14.h),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: const Icon(
                      Icons.photo_library_outlined,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                  title: Text(
                    'Choose from Gallery',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  subtitle: Text(
                    'Pick a banner design from your device',
                    style: TextStyle(fontSize: 12.sp, color: const Color(0xFF64748B)),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    controller.pickBannerImage(source: ImageSource.gallery);
                  },
                ),
                Divider(color: const Color(0xFFF1F5F9), height: 12.h),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0EA5E9).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: Color(0xFF0EA5E9),
                    ),
                  ),
                  title: Text(
                    'Take a Photo',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  subtitle: Text(
                    'Capture a new image using camera',
                    style: TextStyle(fontSize: 12.sp, color: const Color(0xFF64748B)),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    controller.pickBannerImage(source: ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCampaignDetailsCard(
    BuildContext context,
    CreateBannerController controller,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.campaign_outlined,
            title: 'Campaign Details',
            subtitle: 'Set your banner headline and promotion description',
            accentColor: const Color(0xFFEC4899),
          ),
          SizedBox(height: 16.h),
          _buildFieldLabel('Banner Title *'),
          SizedBox(height: 6.h),
          TextFormField(
            controller: controller.titleController,
            textInputAction: TextInputAction.next,
            style: TextStyle(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
            decoration: _inputDecoration(
              hintText: 'e.g. Store Promotion',
              prefixIcon: Icons.title_rounded,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a banner title';
              }
              return null;
            },
          ),
          SizedBox(height: 14.h),
          _buildFieldLabel('Banner Description *'),
          SizedBox(height: 6.h),
          TextFormField(
            controller: controller.descriptionController,
            maxLines: 3,
            style: TextStyle(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF0F172A),
            ),
            decoration: _inputDecoration(
              hintText: 'e.g. Products Promotion',
              prefixIcon: Icons.notes_rounded,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a banner description';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(
    BuildContext context,
    CreateBannerController controller,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.date_range_outlined,
            title: 'Campaign Schedule',
            subtitle: 'Select start and end dates for your banner visibility',
            accentColor: const Color(0xFF10B981),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: Obx(() {
                  final dt = controller.startDate.value;
                  final formatted = dt != null
                      ? controller.formatDateForApi(dt)
                      : 'Select Date';
                  return _buildDatePickerTile(
                    label: 'Start Date',
                    value: formatted,
                    icon: Icons.calendar_today_rounded,
                    onTap: () => controller.pickDate(context, isStart: true),
                  );
                }),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Obx(() {
                  final dt = controller.endDate.value;
                  final formatted = dt != null
                      ? controller.formatDateForApi(dt)
                      : 'Select Date';
                  return _buildDatePickerTile(
                    label: 'End Date',
                    value: formatted,
                    icon: Icons.event_available_rounded,
                    onTap: () => controller.pickDate(context, isStart: false),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerTile({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
            SizedBox(height: 6.h),
            Row(
              children: [
                Icon(icon, size: 15.sp, color: const Color(0xFF0F172A)),
                SizedBox(width: 7.w),
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSellerContactCard(CreateBannerController controller) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.person_outline_rounded,
            title: 'Seller Information',
            subtitle: 'Contact details associated with this banner request',
            accentColor: const Color(0xFF0EA5E9),
          ),
          SizedBox(height: 16.h),
          _buildFieldLabel('Seller Name *'),
          SizedBox(height: 6.h),
          TextFormField(
            controller: controller.nameController,
            textInputAction: TextInputAction.next,
            style: TextStyle(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
            decoration: _inputDecoration(
              hintText: 'e.g. Hareem',
              prefixIcon: Icons.badge_outlined,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter seller name';
              }
              return null;
            },
          ),
          SizedBox(height: 14.h),
          _buildFieldLabel('Email Address *'),
          SizedBox(height: 6.h),
          TextFormField(
            controller: controller.emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            style: TextStyle(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
            decoration: _inputDecoration(
              hintText: 'e.g. hareemsh94@gmail.com',
              prefixIcon: Icons.email_outlined,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter email address';
              }
              if (!GetUtils.isEmail(value.trim())) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          SizedBox(height: 14.h),
          _buildFieldLabel('Phone Number *'),
          SizedBox(height: 6.h),
          TextFormField(
            controller: controller.phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            style: TextStyle(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
            decoration: _inputDecoration(
              hintText: 'e.g. 03145686394',
              prefixIcon: Icons.phone_outlined,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter phone number';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF334155),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        fontSize: 12.5.sp,
        color: const Color(0xFF94A3B8),
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: Icon(
        prefixIcon,
        size: 18.sp,
        color: const Color(0xFF64748B),
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFF0F172A), width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
    );
  }

  Widget _buildBottomSubmitBar(CreateBannerController controller) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 22.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Obx(() {
        final submitting = controller.isSubmitting.value;
        return SizedBox(
          width: double.infinity,
          height: 48.h,
          child: ElevatedButton(
            onPressed: submitting ? null : controller.submitBanner,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              disabledBackgroundColor: const Color(0xFF94A3B8),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: submitting
                ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        controller.isEditMode.value ? Icons.save_rounded : Icons.publish_rounded,
                        size: 18.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        controller.isEditMode.value ? 'Update Banner' : 'Publish Banner',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      }),
    );
  }
}
