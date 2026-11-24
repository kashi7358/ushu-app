import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
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

    final rawErrors = res['errors'] ?? res['error'] ?? res['details'] ?? res['data']?['errors'] ?? res['failed'];
    if (rawErrors is List && rawErrors.isNotEmpty) {
      for (final item in rawErrors) {
        if (item is Map) {
          final row = item['row'] ?? item['line'] ?? item['index'];
          final field = item['field'] ?? item['column'] ?? item['key'];
          final msg = item['error'] ?? item['message'] ?? item['msg'] ?? item.toString();
          final rowStr = row != null ? 'Row $row: ' : '';
          final fieldStr = field != null ? '[$field] ' : '';
          details.add('$rowStr$fieldStr$msg');
        } else if (item != null && item.toString().trim().isNotEmpty) {
          details.add(item.toString().trim());
        }
      }
    } else if (rawErrors is Map && rawErrors.isNotEmpty) {
      rawErrors.forEach((key, val) {
        details.add('$key: $val');
      });
    } else if (rawErrors is String && rawErrors.trim().isNotEmpty && rawErrors != baseMsg) {
      details.add(rawErrors.trim());
    }

    if (details.isNotEmpty) {
      final shown = details.take(6).map((d) => '• $d').join('\n');
      final more = details.length > 6 ? '\n...and ${details.length - 6} more issues' : '';
      return '$baseMsg\n\nSpecific Errors:\n$shown$more\n\nHint: Verify CSV columns: name, description, price, category, subCategory, brand, stock, sku.';
    }

    return '$baseMsg\n\nPlease ensure your CSV file contains required columns:\n• name, description, price, category, subCategory, brand, stock, sku';
  }

  Future<bool> uploadBulkProducts() async {
    if (selectedCsvPath.value.isEmpty) {
      CustomPopup.showError('CSV Required', 'Please select a CSV or Excel file containing products');
      return false;
    }

    if (currentStoreId.isEmpty) {
      currentStoreId = SessionManager.sellerStoreId ?? '';
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
      final csvFileName = selectedCsvName.value.isNotEmpty
          ? selectedCsvName.value
          : selectedCsvPath.value.split(RegExp(r'[/\\]')).last;

      formData.files.add(MapEntry(
        'file',
        await MultipartFile.fromFile(
          selectedCsvPath.value,
          filename: csvFileName,
        ),
      ));

      // 2. Add Images / ZIP archive
      if (selectedImagePaths.isNotEmpty) {
        final zipCandidates = selectedImagePaths.where((p) => p.toLowerCase().endsWith('.zip')).toList();
        if (zipCandidates.isNotEmpty) {
          final zipPath = zipCandidates.first;
          final zipName = zipPath.split(RegExp(r'[/\\]')).last;
          formData.files.add(MapEntry(
            'images',
            await MultipartFile.fromFile(zipPath, filename: zipName),
          ));
          formData.files.add(MapEntry(
            'zip',
            await MultipartFile.fromFile(zipPath, filename: zipName),
          ));
        } else {
          for (final imgPath in selectedImagePaths) {
            final imgName = imgPath.split(RegExp(r'[/\\]')).last;
            formData.files.add(MapEntry(
              'images',
              await MultipartFile.fromFile(imgPath, filename: imgName),
            ));
          }

          try {
            final archive = Archive();
            for (final imgPath in selectedImagePaths) {
              final file = File(imgPath);
              if (await file.exists()) {
                final bytes = await file.readAsBytes();
                final fileName = imgPath.split(RegExp(r'[/\\]')).last;
                archive.addFile(ArchiveFile(fileName, bytes.length, bytes));
                archive.addFile(ArchiveFile('Camera Roll/$fileName', bytes.length, bytes));
              }
            }
            final zipBytes = ZipEncoder().encode(archive);
            if (zipBytes != null && zipBytes.isNotEmpty) {
              formData.files.add(MapEntry(
                'zip',
                MultipartFile.fromBytes(zipBytes, filename: 'images.zip'),
              ));
            }
          } catch (zipErr) {
            debugPrint('ZIP creation fallback: $zipErr');
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
        } else if (response['createdCount'] != null &&
            (response['createdCount'] == 0 || response['createdCount'] == '0')) {
          isFailed = true;
        } else if (response['productsCreated'] != null &&
            (response['productsCreated'] == 0 || response['productsCreated'] == '0')) {
          isFailed = true;
        }
      }

      if (isFailed) {
        final err = _extractBulkErrorMessage(response);
        CustomPopup.showError('Upload Failed', err);
        return false;
      }

      final successMsg = (response is Map && response['message'] != null)
          ? response['message'].toString()
          : 'Bulk products uploaded successfully';

      CustomPopup.showSuccess('Bulk Upload Complete', successMsg);
      clearBulkUploadData();
      await fetchProducts();
      return true;
    } catch (e) {
      CustomPopup.hideLoading();
      debugPrint('Bulk upload error: $e');
      if (e is DioException && e.response?.data != null) {
        final err = _extractBulkErrorMessage(e.response!.data);
        CustomPopup.showError('Upload Failed', err);
      } else {
        final error = ExceptionHandler.handle(e);
        CustomPopup.showError('Upload Failed', error.message);
      }
      return false;
    } finally {
      isBulkUploading.value = false;
    }
  }
}
