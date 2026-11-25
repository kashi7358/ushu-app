import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uhsu_buy/app/theme/app_colors.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/errors/exception_handler.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/custom_popup.dart';
import '../../../../core/utils/session_manager.dart';
import '../../data/datasources/seller_remote_data_source.dart';
import '../../data/models/seller_product_model.dart';
import '../../data/repositories/seller_repository_impl.dart';
import '../../domain/repositories/seller_repository.dart';

class ManageProductsController extends GetxController {
  final RxList<SellerProductModel> products = <SellerProductModel>[].obs;
  final RxList<SellerProductModel> filteredProducts = <SellerProductModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isDeleting = false.obs;
  final RxBool isBulkUploading = false.obs;
  bool _isPickerActive = false;
  final RxString selectedCsvPath = ''.obs;
  final RxString selectedCsvName = ''.obs;
  final RxList<String> selectedImagePaths = <String>[].obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();

  late final SellerRepository _repository;
  String currentStoreId = '';

  @override
  void onInit() {
    super.onInit();
    final apiClient = ApiClient();
    final remoteDataSource = SellerRemoteDataSourceImpl(apiClient);
    _repository = SellerRepositoryImpl(remoteDataSource);

    // Get storeId from arguments or SessionManager
    final args = Get.arguments;
    if (args is Map && args['storeId'] != null && args['storeId'].toString().isNotEmpty) {
      currentStoreId = args['storeId'].toString();
    } else {
      currentStoreId = SessionManager.sellerStoreId ?? '';
    }

    fetchProducts();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchProducts() async {
    if (currentStoreId.isEmpty) {
      currentStoreId = SessionManager.sellerStoreId ?? '';
    }

    if (currentStoreId.isEmpty) {
      try {
        final statsResponse = await _repository.getDashboardStats();
        if (statsResponse is Map) {
          final dynamic storeObj = statsResponse['store'];
          final foundId = statsResponse['storeId'] ??
              (storeObj is Map ? (storeObj['_id'] ?? storeObj['id']) : null) ??
              statsResponse['data']?['storeId'] ??
              statsResponse['stats']?['storeId'];
          if (foundId != null && foundId.toString().isNotEmpty) {
            currentStoreId = foundId.toString();
            await SessionManager.saveSellerStoreId(currentStoreId);
          }
        }
      } catch (_) {
        // Fall through to error check if rehydration fails
      }
    }

    if (currentStoreId.isEmpty) {
      errorMessage.value = 'Store reference not found. Please setup your store first.';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _repository.getProductsByStore(currentStoreId);

      final List<SellerProductModel> loaded = [];

      dynamic rawList;
      if (response is Map) {
        rawList = response['products'] ??
            response['data'] ??
            response['allProducts'] ??
            response['items'];
      } else if (response is List) {
        rawList = response;
      }

      if (rawList is List) {
        for (var item in rawList) {
          if (item is Map<String, dynamic>) {
            loaded.add(SellerProductModel.fromJson(item));
          } else if (item is Map) {
            loaded.add(SellerProductModel.fromJson(Map<String, dynamic>.from(item)));
          }
        }
      }

      products.assignAll(loaded);
      applyFilter(searchQuery.value);
    } catch (e) {
      final error = ExceptionHandler.handle(e);
      errorMessage.value = error.message;
    } finally {
      isLoading.value = false;
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    applyFilter(query);
  }

  final RxString selectedTab = 'All'.obs; // 'All', 'Active', 'Inactive', 'Draft'

  void onTabChanged(String tab) {
    selectedTab.value = tab;
    applyFilter(searchQuery.value);
  }

  int get allCount => products.length;
  int get activeCount => products.where((p) => p.isActive).length;
  int get inactiveCount => products.where((p) => p.isInactive).length;
  int get draftCount => products.where((p) => p.isDraft).length;

  void applyFilter(String query) {
    List<SellerProductModel> list = products;

    // Filter by tab
    if (selectedTab.value == 'Active') {
      list = list.where((p) => p.isActive).toList();
    } else if (selectedTab.value == 'Inactive') {
      list = list.where((p) => p.isInactive).toList();
    } else if (selectedTab.value == 'Draft') {
      list = list.where((p) => p.isDraft).toList();
    }

    // Filter by search query
    if (query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      list = list.where((p) {
        return p.name.toLowerCase().contains(q) ||
            p.sku.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q) ||
            p.brand.toLowerCase().contains(q);
      }).toList();
    }

    filteredProducts.assignAll(list);
  }

  Future<void> confirmDeleteProduct(SellerProductModel product) async {
    final bool? confirm = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.delete_forever_rounded, color: Colors.red, size: 26),
            SizedBox(width: 8),
            Text('Delete Product', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${product.name}"? This action cannot be undone.',
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await deleteProduct(product.id, product.name);
    }
  }

  Future<void> deleteProduct(String productId, String productName) async {
    try {
      isDeleting.value = true;
      CustomPopup.showLoading('Deleting product...');

      final response = await _repository.deleteProduct(productId);
      CustomPopup.hideLoading();

      products.removeWhere((p) => p.id == productId);
      filteredProducts.removeWhere((p) => p.id == productId);

      final msg = (response is Map && response['message'] != null)
          ? response['message'].toString()
          : '$productName deleted successfully';

      CustomPopup.showToast('Success', msg);
    } catch (e) {
      CustomPopup.hideLoading();
      final error = ExceptionHandler.handle(e);
      CustomPopup.showToast('Delete Failed', error.message, isError: true);
    } finally {
      isDeleting.value = false;
    }
  }

  void navigateToAddProduct() {
    Get.toNamed(
      AppRoutes.sellerCreateProduct,
      arguments: {
        'storeId': currentStoreId,
      },
    )?.then((value) {
      // Refresh list when returning from Add Product screen
      fetchProducts();
    });
  }

  void navigateToEditProduct(SellerProductModel product) {
    Get.toNamed(
      AppRoutes.sellerCreateProduct,
      arguments: {
        'storeId': currentStoreId,
        'product': product,
        'isEdit': true,
      },
    )?.then((value) {
      // Refresh list when returning from Edit Product screen
      if (value == true || value == null) {
        fetchProducts();
      }
    });
  }

  // --- Bulk CSV & Images Upload ---
  Future<void> pickCsvFile() async {
    if (_isPickerActive) return;
    _isPickerActive = true;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xlsx', 'xls'],
      );

      if (result != null && result.files.single.path != null) {
        selectedCsvPath.value = result.files.single.path!;
        selectedCsvName.value = result.files.single.name;
      }
    } catch (e) {
      CustomPopup.showError('File Error', 'Failed to pick file: $e');
    } finally {
      _isPickerActive = false;
    }
  }

  Future<void> pickBulkImages() async {
    if (_isPickerActive) return;
    _isPickerActive = true;
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'zip'],
      );
      if (result != null && result.paths.isNotEmpty) {
        for (final path in result.paths) {
          if (path != null && !selectedImagePaths.contains(path)) {
            selectedImagePaths.add(path);
          }
        }
      }
    } catch (e) {
      final str = e.toString().toLowerCase();
      if (!str.contains('already_active') && !str.contains('cancelled')) {
        CustomPopup.showError('Image Error', 'Failed to pick files: $e');
      }
    } finally {
      _isPickerActive = false;
    }
  }

  void removeSelectedImage(int index) {
    if (index >= 0 && index < selectedImagePaths.length) {
      selectedImagePaths.removeAt(index);
    }
  }

  void clearBulkUploadData() {
    selectedCsvPath.value = '';
    selectedCsvName.value = '';
    selectedImagePaths.clear();
  }

  String _extractBulkErrorMessage(dynamic res) {
    if (res is! Map) return 'No products were created. Please verify your CSV format and try again.';

    final baseMsg = (res['message'] ?? res['msg'] ?? 'Bulk upload failed').toString();
    List<String> details = [];
    bool hasImageErrors = false;

    final rawErrors = res['errors'] ?? res['error'] ?? res['details'] ?? res['data']?['errors'] ?? res['failed'];
    if (rawErrors is List && rawErrors.isNotEmpty) {
      for (final item in rawErrors) {
        if (item is Map) {
          final row = item['row'] ?? item['line'] ?? item['index'];
          final sku = item['sku'];
          final field = item['field'] ?? item['column'] ?? item['key'];
          String msg = (item['message'] ?? item['error'] ?? item['msg'] ?? item.toString()).toString();

          final isImgError = msg.toLowerCase().contains('not found in the zip') ||
              msg.toLowerCase().contains('not a url');
          if (isImgError) {
            hasImageErrors = true;
            if (msg.contains('"')) {
              final parts = msg.split('"');
              if (parts.length >= 2 && parts[1].isNotEmpty) {
                msg = 'Image file "${parts[1]}" missing (not in ZIP)';
              }
            }
          }

          final rowStr = row != null ? 'Row $row' : '';
          final skuStr = (sku != null && sku.toString().isNotEmpty) ? ' ($sku)' : '';
          final fieldStr = (field != null && field.toString().isNotEmpty && !isImgError) ? ' [$field]' : '';
          final prefix = (rowStr.isNotEmpty || skuStr.isNotEmpty) ? '$rowStr$skuStr: ' : '';

          details.add('• $prefix$msg');
        } else if (item != null && item.toString().trim().isNotEmpty) {
          final str = item.toString().trim();
          if (str.toLowerCase().contains('not found in the zip') || str.toLowerCase().contains('not a url')) {
            hasImageErrors = true;
          }
          details.add('• $str');
        }
      }
    } else if (rawErrors is Map && rawErrors.isNotEmpty) {
      rawErrors.forEach((key, val) {
        details.add('• $key: $val');
      });
    }

    if (details.isNotEmpty) {
      final shown = details.take(6).join('\n');
      final more = details.length > 6 ? '\n...and ${details.length - 6} more errors' : '';

      if (hasImageErrors) {
        return 'Image names in CSV file do not match the photos in the ZIP file.';
      }

      return 'Required product fields are missing or format is invalid in your CSV file.';
    }

    return 'Required product columns are missing in your CSV file.';
  }

  List<String> _parseCsvLine(String line) {
    final List<String> result = [];
    final StringBuffer sb = StringBuffer();
    bool insideQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        insideQuotes = !insideQuotes;
      } else if (char == ',' && !insideQuotes) {
        result.add(sb.toString().trim());
        sb.clear();
      } else {
        sb.write(char);
      }
    }
    result.add(sb.toString().trim());
    return result;
  }

  String _formatCsvLine(List<String> cols) {
    return cols.map((col) {
      if (col.contains(',') || col.contains('"') || col.contains('\n')) {
        return '"${col.replaceAll('"', '""')}"';
      }
      return col;
    }).join(',');
  }

  Future<String> _prepareCsvFileForUpload(String originalPath, {bool forceStripLocalImages = false}) async {
    // Only sanitize if it is a .csv file
    if (!originalPath.toLowerCase().endsWith('.csv')) {
      return originalPath;
    }

    if (!forceStripLocalImages && selectedImagePaths.isNotEmpty) {
      final hasZip = selectedImagePaths.any((p) => p.toLowerCase().endsWith('.zip'));
      if (hasZip) {
        return originalPath;
      }
    }

    try {
      final file = File(originalPath);
      if (!await file.exists()) return originalPath;

      final content = await file.readAsString();
      final lines = content.split('\n');
      if (lines.isEmpty) return originalPath;

      final headers = _parseCsvLine(lines.first);
      final List<int> imageColIndices = [];
      for (int i = 0; i < headers.length; i++) {
        final h = headers[i].toLowerCase().trim().replaceAll('"', '').replaceAll("'", '');
        if (h.contains('image') || h.contains('img') || h.contains('photo')) {
          imageColIndices.add(i);
        }
      }

      if (imageColIndices.isEmpty) return originalPath;

      bool hasLocalPaths = false;
      for (int i = 1; i < lines.length; i++) {
        if (lines[i].trim().isEmpty) continue;
        final cols = _parseCsvLine(lines[i]);
        for (final colIdx in imageColIndices) {
          if (cols.length > colIdx) {
            final val = cols[colIdx].trim().replaceAll('"', '').replaceAll("'", '');
            if (val.isNotEmpty && !val.startsWith('http://') && !val.startsWith('https://')) {
              hasLocalPaths = true;
              break;
            }
          }
        }
        if (hasLocalPaths) break;
      }

      if (!hasLocalPaths) return originalPath;

      final cleanLines = <String>[];
      cleanLines.add(lines.first);

      for (int i = 1; i < lines.length; i++) {
        if (lines[i].trim().isEmpty) {
          cleanLines.add(lines[i]);
          continue;
        }
        final cols = _parseCsvLine(lines[i]);
        for (final colIdx in imageColIndices) {
          if (cols.length > colIdx) {
            final val = cols[colIdx].trim().replaceAll('"', '').replaceAll("'", '');
            if (val.isNotEmpty && !val.startsWith('http://') && !val.startsWith('https://')) {
              cols[colIdx] = '';
            }
          }
        }
        cleanLines.add(_formatCsvLine(cols));
      }

      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/clean_${DateTime.now().millisecondsSinceEpoch}.csv');
      await tempFile.writeAsString(cleanLines.join('\n'));
      debugPrint('Sanitized CSV created for upload: ${tempFile.path}');
      return tempFile.path;
    } catch (e) {
      debugPrint('CSV sanitization fallback: $e');
      return originalPath;
    }
  }

  void showBulkUploadIssueDialog(dynamic res) {
    dynamic parsed = res;
    if (parsed is String) {
      try {
        parsed = jsonDecode(parsed);
      } catch (_) {}
    }

    bool hasImageIssues = false;
    bool hasDataIssues = false;

    if (parsed is Map) {
      final rawErrors = parsed['errors'] ?? parsed['error'] ?? parsed['details'] ?? parsed['data']?['errors'] ?? parsed['failed'];
      if (rawErrors is List && rawErrors.isNotEmpty) {
        for (final item in rawErrors) {
          final msg = (item is Map ? (item['message'] ?? item['error'] ?? item['msg'] ?? item.toString()) : item.toString()).toLowerCase();
          if (msg.contains('not found in the zip') || msg.contains('not a url') || msg.contains('image')) {
            hasImageIssues = true;
          } else {
            hasDataIssues = true;
          }
        }
      } else if (rawErrors != null) {
        final str = rawErrors.toString().toLowerCase();
        if (str.contains('not found in the zip') || str.contains('not a url') || str.contains('image')) {
          hasImageIssues = true;
        } else {
          hasDataIssues = true;
        }
      }
    } else {
      hasDataIssues = true;
    }

    if (!hasImageIssues && !hasDataIssues) {
      hasDataIssues = true;
    }

    String title = 'Upload Issue';
    String message = 'Please review your uploaded files and try again.';
    IconData icon = Icons.error_outline_rounded;
    Color accentColor = const Color(0xFFEF4444);

    if (hasImageIssues && !hasDataIssues) {
      title = 'Images Not Matched';
      message = 'Image names in CSV file do not match the photos in the ZIP file.';
      icon = Icons.broken_image_rounded;
      accentColor = const Color(0xFFF59E0B);
    } else if (hasDataIssues && !hasImageIssues) {
      title = 'Issue in CSV File';
      message = 'Required product fields are missing or format is invalid in your CSV file.';
      icon = Icons.description_outlined;
      accentColor = const Color(0xFFEF4444);
    } else {
      title = 'Issues in CSV & Images';
      message = 'Required fields are missing in CSV and image names do not match the ZIP file.';
      icon = Icons.warning_amber_rounded;
      accentColor = const Color(0xFFEF4444);
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor, size: 30),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              if (hasImageIssues) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                      uploadBulkProducts(forceStripLocalImages: true);
                    },
                    icon: const Icon(Icons.flash_on_rounded, size: 18),
                    label: const Text(
                      'Upload Without Images',
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Okay', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  Future<bool> uploadBulkProducts({bool forceStripLocalImages = false}) async {
    if (selectedCsvPath.value.isEmpty) {
      CustomPopup.showError('CSV Required', 'Please select a CSV or Excel file containing products');
      return false;
    }

    if (currentStoreId.isEmpty) {
      currentStoreId = SessionManager.sellerStoreId ?? '';
    }

    if (currentStoreId.isEmpty) {
      try {
        final statsResponse = await _repository.getDashboardStats();
        if (statsResponse is Map) {
          final dynamic storeObj = statsResponse['store'];
          final foundId = statsResponse['storeId'] ??
              (storeObj is Map ? (storeObj['_id'] ?? storeObj['id']) : null) ??
              statsResponse['data']?['storeId'];
          if (foundId != null && foundId.toString().isNotEmpty) {
            currentStoreId = foundId.toString();
            await SessionManager.saveSellerStoreId(currentStoreId);
          }
        }
      } catch (_) {}
    }

    if (currentStoreId.isEmpty) {
      CustomPopup.showError('Store Required', 'Store ID is missing. Please select or create your store first.');
      return false;
    }

    try {
      isBulkUploading.value = true;
      CustomPopup.showLoading('Uploading bulk products...');

      final formData = FormData();

      // 1. Add CSV/Excel file (body field: 'file')
      final uploadCsvPath = await _prepareCsvFileForUpload(
        selectedCsvPath.value,
        forceStripLocalImages: forceStripLocalImages,
      );
      final csvFileName = selectedCsvName.value.isNotEmpty
          ? selectedCsvName.value
          : selectedCsvPath.value.split(RegExp(r'[/\\]')).last;

      formData.files.add(MapEntry(
        'file',
        await MultipartFile.fromFile(
          uploadCsvPath,
          filename: csvFileName,
        ),
      ));

      // 2. Add Images (body field: 'images' - strictly matching backend schema: file, images)
      if (!forceStripLocalImages && selectedImagePaths.isNotEmpty) {
        final zipCandidates = selectedImagePaths.where((p) => p.toLowerCase().endsWith('.zip')).toList();
        if (zipCandidates.isNotEmpty) {
          final zipPath = zipCandidates.first;
          final zipName = zipPath.split(RegExp(r'[/\\]')).last;
          formData.files.add(MapEntry(
            'images',
            await MultipartFile.fromFile(zipPath, filename: zipName),
          ));
        } else {
          // Multiple image photos selected: package them into a single images.zip archive
          try {
            final archive = Archive();
            for (final imgPath in selectedImagePaths) {
              final file = File(imgPath);
              if (await file.exists()) {
                final bytes = await file.readAsBytes();
                final fileName = imgPath.split(RegExp(r'[/\\]')).last;
                archive.addFile(ArchiveFile(fileName, bytes.length, bytes));
                // Add with 'Camera Roll/' prefix in case CSV references that folder
                archive.addFile(ArchiveFile('Camera Roll/$fileName', bytes.length, bytes));
              }
            }
            final zipBytes = ZipEncoder().encode(archive);
            if (zipBytes != null && zipBytes.isNotEmpty) {
              formData.files.add(MapEntry(
                'images',
                MultipartFile.fromBytes(zipBytes, filename: 'images.zip'),
              ));
            }
          } catch (zipErr) {
            debugPrint('ZIP creation fallback: $zipErr');
            if (selectedImagePaths.length == 1) {
              final imgPath = selectedImagePaths.first;
              final imgName = imgPath.split(RegExp(r'[/\\]')).last;
              formData.files.add(MapEntry(
                'images',
                await MultipartFile.fromFile(imgPath, filename: imgName),
              ));
            }
          }
        }
      }

      final response = await _repository.bulkUploadProducts(
        storeId: currentStoreId,
        formData: formData,
        token: SessionManager.sellerToken,
      );

      debugPrint('=== BULK UPLOAD RESPONSE ===\n$response');
      CustomPopup.hideLoading();

      bool isFailed = false;
      if (response is Map) {
        if (response['success'] == false) {
          isFailed = true;
        } else if (response['summary'] != null && response['summary'] is Map) {
          final s = response['summary'] as Map;
          final created = s['created'];
          final failed = s['failed'];
          if (created != null && (created == 0 || created == '0') && failed != null && failed > 0) {
            isFailed = true;
          }
        } else if (response['createdCount'] != null &&
            (response['createdCount'] == 0 || response['createdCount'] == '0')) {
          isFailed = true;
        } else if (response['productsCreated'] != null &&
            (response['productsCreated'] == 0 || response['productsCreated'] == '0')) {
          isFailed = true;
        }
      }

      if (isFailed) {
        showBulkUploadIssueDialog(response);
        return false;
      }

      String successMsg = 'Bulk products uploaded successfully';
      if (response is Map) {
        if (response['message'] != null && response['message'].toString().trim().isNotEmpty) {
          successMsg = response['message'].toString();
        }
        if (response['summary'] != null && response['summary'] is Map) {
          final s = response['summary'] as Map;
          final created = s['created'] ?? 0;
          final total = s['totalProducts'] ?? s['totalRows'] ?? created;
          final failed = s['failed'] ?? 0;
          successMsg = '$created of $total products created successfully!';
          if (failed > 0) {
            successMsg += '\n($failed failed due to errors)';
          }
        }
      }

      CustomPopup.showSuccess('Bulk Upload Complete', successMsg);
      clearBulkUploadData();
      await fetchProducts();
      return true;
    } catch (e) {
      CustomPopup.hideLoading();
      debugPrint('Bulk upload error: $e');
      if (e is DioException && e.response?.data != null) {
        showBulkUploadIssueDialog(e.response!.data);
      } else {
        final error = ExceptionHandler.handle(e);
        CustomPopup.showError('Upload Failed', error.message);
      }
      return false;
    } finally {
      isBulkUploading.value = false;
    }
  }

  Future<void> downloadSampleCsvTemplate() async {
    try {
      const sampleCsv = 'name,description,sku,price,category,subCategory,brand,stock,condition,tags\n'
          '"Wireless Bluetooth Earbuds","High bass noise cancelling earbuds with fast charging",EAR-WL-01,2499,Electronics,Audio,Sony,50,new,"audio,wireless,earbuds"\n'
          '"Mechanical Gaming Keyboard","RGB backlit mechanical keyboard with blue switches",KB-RGB-01,5999,Electronics,Accessories,Redragon,30,new,"gaming,keyboard,rgb"\n'
          '"Men Cotton Casual T-Shirt","100% breathable premium cotton slim fit casual polo shirt",TS-POLO-01,1499,Fashion,Men Clothing,Polo,100,new,"fashion,clothing,men"\n';

      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/sample_products_template.csv');
      await file.writeAsString(sampleCsv);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: 'Sample Products Template CSV',
          text: 'Use this template to prepare products for bulk upload on Ushu.',
        ),
      );
    } catch (e) {
      debugPrint('Error sharing sample template: $e');
      CustomPopup.showError('Export Failed', 'Could not export sample template: $e');
    }
  }
}
