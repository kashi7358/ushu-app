import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:image_picker/image_picker.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../utils/custom_popup.dart';
import '../utils/session_manager.dart';

class ReportModalBottomSheet extends StatefulWidget {
  /// Target type: 'Buyer', 'Product', 'Store', 'Seller'
  final String targetType;
  final String targetId;
  final String? targetTitle;
  final String? initialReason;
  final bool isSeller;

  const ReportModalBottomSheet({
    super.key,
    required this.targetType,
    required this.targetId,
    this.targetTitle,
    this.initialReason,
    this.isSeller = false,
  });

  static Future<void> show({
    required BuildContext context,
    required String targetType,
    required String targetId,
    String? targetTitle,
    String? initialReason,
    bool isSeller = false,
  }) {
    // Check authentication
    final token = isSeller ? SessionManager.sellerToken : SessionManager.token;
    final isLoggedIn = isSeller ? SessionManager.isSellerLoggedIn : SessionManager.isLoggedIn;

    if (!isLoggedIn || token == null || token.trim().isEmpty) {
      CustomPopup.showError(
        'Login Required',
        isSeller
            ? 'Please log in to your Seller account to submit a report.'
            : 'Please log in to your account to submit a report.',
      );
      return Future.value();
    }

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ReportModalBottomSheet(
        targetType: targetType,
        targetId: targetId,
        targetTitle: targetTitle,
        initialReason: initialReason,
        isSeller: isSeller,
      ),
    );
  }

  @override
  State<ReportModalBottomSheet> createState() => _ReportModalBottomSheetState();
}

class _ReportModalBottomSheetState extends State<ReportModalBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _targetIdController;
  late final TextEditingController _reasonController;
  late final TextEditingController _descriptionController;

  String? _selectedReasonPreset;
  File? _evidenceFile;
  bool _isSubmitting = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _targetIdController = TextEditingController(text: widget.targetId);
    _reasonController = TextEditingController(text: widget.initialReason ?? '');
    _descriptionController = TextEditingController();

    final presets = _getReasonPresets();
    if (widget.initialReason != null && presets.contains(widget.initialReason)) {
      _selectedReasonPreset = widget.initialReason;
    } else if (presets.isNotEmpty) {
      _selectedReasonPreset = presets.first;
      _reasonController.text = presets.first;
    }
  }

  @override
  void dispose() {
    _targetIdController.dispose();
    _reasonController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  List<String> _getReasonPresets() {
    switch (widget.targetType.toLowerCase()) {
      case 'buyer':
        return [
          'Unfair Review',
          'abusive_language',
          'fraudulent_order',
          'false_return_claim',
          'harassment',
          'other',
        ];
      case 'product':
        return [
          'counterfeit',
          'misleading_description',
          'damaged_or_defective',
          'prohibited_item',
          'wrong_product',
          'other',
        ];
      case 'store':
        return [
          'fake_store',
          'scam_or_fraud',
          'brand_infringement',
          'inappropriate_content',
          'other',
        ];
      case 'seller':
        return [
          'item not delivered',
          'seller unresponsive',
          'wrong item sent',
          'counterfeit',
          'harassment',
          'other',
        ];
      default:
        return [
          'fraud',
          'inappropriate_content',
          'harassment',
          'other',
        ];
    }
  }

  String _formatReasonLabel(String reason) {
    switch (reason) {
      case 'counterfeit':
        return 'Counterfeit / Replica';
      case 'fake_store':
        return 'Fake / Fraudulent Store';
      case 'item not delivered':
        return 'Item Not Delivered';
      case 'Unfair Review':
        return 'Unfair / Fake Review';
      case 'abusive_language':
        return 'Abusive Language';
      case 'misleading_description':
        return 'Misleading Description';
      case 'damaged_or_defective':
        return 'Damaged or Defective';
      case 'prohibited_item':
        return 'Prohibited Item';
      case 'wrong_product':
      case 'wrong item sent':
        return 'Wrong Item Sent';
      case 'scam_or_fraud':
        return 'Scam / Fraud';
      case 'brand_infringement':
        return 'Brand / Copyright Infringement';
      case 'inappropriate_content':
        return 'Inappropriate Content';
      case 'seller unresponsive':
        return 'Seller Unresponsive';
      case 'fraudulent_order':
        return 'Fraudulent Order';
      case 'false_return_claim':
        return 'False Return Claim';
      case 'harassment':
        return 'Harassment';
      case 'other':
        return 'Other Reason';
      default:
        return reason.replaceAll('_', ' ').capitalizeFirst ?? reason;
    }
  }

  Future<void> _pickEvidence(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 80,
      );
      if (picked != null) {
        setState(() {
          _evidenceFile = File(picked.path);
        });
      }
    } catch (e) {
      CustomPopup.showToast('Error', 'Failed to pick image: $e', isError: true);
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final reason = _reasonController.text.trim();
    final description = _descriptionController.text.trim();
    final targetId = _targetIdController.text.trim().isNotEmpty
        ? _targetIdController.text.trim()
        : widget.targetId;

    if (targetId.isEmpty) {
      CustomPopup.showError('Required Field', 'Please provide target ID or order reference.');
      return;
    }

    if (reason.isEmpty) {
      CustomPopup.showError('Required Field', 'Please select or provide a reason for this report.');
      return;
    }

    if (description.isEmpty) {
      CustomPopup.showError('Required Field', 'Please provide a description explaining the issue.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final token = widget.isSeller ? SessionManager.sellerToken : SessionManager.token;
      final Map<String, dynamic> formMap = {
        'targetType': widget.targetType,
        'targetId': targetId,
        'reason': reason,
        'description': description,
      };

      if (_evidenceFile != null && await _evidenceFile!.exists()) {
        final filename = _evidenceFile!.path.split(Platform.pathSeparator).last;
        formMap['evidence'] = await MultipartFile.fromFile(
          _evidenceFile!.path,
          filename: filename,
        );
      }

      final formData = FormData.fromMap(formMap);

      final Map<String, dynamic> headers = {
        'Content-Type': 'multipart/form-data',
      };
      if (token != null && token.isNotEmpty) {
        String clean = token.trim();
        if (clean.toLowerCase().startsWith('bearer ')) {
          clean = clean.substring(7).trim();
        }
        headers['Authorization'] = 'Bearer $clean';
        headers['auth-token'] = clean;
        headers['token'] = clean;
      }

      final response = await ApiClient().dio.post(
        ApiEndpoints.createReport,
        data: formData,
        options: Options(
          headers: headers,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final data = response.data;
      final isSuccess = response.statusCode == 200 ||
          response.statusCode == 201 ||
          (data is Map && data['success'] == true);

      if (isSuccess) {
        if (mounted) {
          Navigator.of(context).pop();
        }
        final message = (data is Map && data['message'] != null)
            ? data['message'].toString()
            : 'Your report has been submitted successfully and will be investigated by our moderation team.';
        CustomPopup.showSuccess('Report Submitted', message);
      } else {
        final errorMsg = (data is Map && data['message'] != null)
            ? data['message'].toString()
            : 'Failed to submit report. Please try again.';
        CustomPopup.showError('Submission Error', errorMsg);
      }
    } catch (e) {
      CustomPopup.showError(
        'Submission Error',
        'Could not submit report. Please check your internet connection and try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final presets = _getReasonPresets();

    return Container(
      padding: EdgeInsets.fromLTRB(20, 14, 20, 20 + bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 42,
                  height: 4.5,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Title Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.flag_rounded,
                      color: Color(0xFFEF4444),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Report ${widget.targetType}',
                          style: AppTextStyles.bold.copyWith(
                            fontSize: 18,
                            color: AppColors.darkText,
                          ),
                        ),
                        if (widget.targetTitle != null && widget.targetTitle!.isNotEmpty)
                          Text(
                            widget.targetTitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded, size: 18, color: Colors.black87),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 16),

              if (widget.targetId.isEmpty) ...[
                Text(
                  '${widget.targetType} ID or Reference *',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _targetIdController,
                  decoration: InputDecoration(
                    hintText: 'Enter ID or order number...',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Please enter ID' : null,
                ),
                const SizedBox(height: 16),
              ],

              // Reason Category Selection
              const Text(
                'Reason for Report *',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: presets.map((reason) {
                  final isSelected = _selectedReasonPreset == reason;
                  return ChoiceChip(
                    label: Text(_formatReasonLabel(reason)),
                    selected: isSelected,
                    selectedColor: AppColors.primaryPurple,
                    backgroundColor: const Color(0xFFF1F5F9),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF334155),
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isSelected ? AppColors.primaryPurple : Colors.transparent,
                      ),
                    ),
                    onSelected: (val) {
                      setState(() {
                        _selectedReasonPreset = reason;
                        _reasonController.text = reason;
                      });
                    },
                  );
                }).toList(),
              ),

              if (_selectedReasonPreset == 'other') ...[
                const SizedBox(height: 10),
                TextFormField(
                  controller: _reasonController,
                  decoration: InputDecoration(
                    hintText: 'Enter custom reason...',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Please specify reason' : null,
                ),
              ],

              const SizedBox(height: 16),

              // Description
              const Text(
                'Details / Description *',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Provide detailed information about this violation...',
                  hintStyle: TextStyle(fontSize: 12.5, color: Colors.grey.shade400),
                  contentPadding: const EdgeInsets.all(12),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Please provide detailed description' : null,
              ),

              const SizedBox(height: 16),

              // Evidence Attachment
              const Text(
                'Evidence / Proof (Image)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 6),

              if (_evidenceFile == null)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        onPressed: () => _pickEvidence(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_outlined, size: 18, color: AppColors.primaryPurple),
                        label: const Text(
                          'Upload Gallery',
                          style: TextStyle(fontSize: 12.5, color: AppColors.darkText, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        onPressed: () => _pickEvidence(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt_outlined, size: 18, color: AppColors.primaryPurple),
                        label: const Text(
                          'Take Photo',
                          style: TextStyle(fontSize: 12.5, color: AppColors.darkText, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                )
              else
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _evidenceFile!,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Evidence attached',
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                            ),
                            Text(
                              _evidenceFile!.path.split(Platform.pathSeparator).last,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                        onPressed: () {
                          setState(() {
                            _evidenceFile = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 22),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: _isSubmitting ? null : _submitReport,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.send_rounded, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'Submit Report',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
}
