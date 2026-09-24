import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/browsing_history.dart';
import '../../../home/data/models/product_model.dart';
import '../../../home/presentation/screens/product_detail_screen.dart';

class BrowsingHistoryScreen extends StatefulWidget {
  const BrowsingHistoryScreen({super.key});

  @override
  State<BrowsingHistoryScreen> createState() => _BrowsingHistoryScreenState();
}

class _BrowsingHistoryScreenState extends State<BrowsingHistoryScreen> {
  List<ProductModel> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await BrowsingHistory.getHistory();
    setState(() {
      _history = history;
      _isLoading = false;
    });
  }

  Future<void> _removeItem(String productId) async {
    await BrowsingHistory.removeProduct(productId);
    _loadHistory();
  }

  Future<void> _confirmClearAll() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Clear History', style: AppTextStyles.bold.copyWith(color: AppColors.darkText, fontSize: 18)),
        content: Text('Are you sure you want to clear all browsing history?', style: AppTextStyles.medium.copyWith(color: AppColors.hintText, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel', style: AppTextStyles.bold.copyWith(color: AppColors.hintText)),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Clear All', style: AppTextStyles.bold.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm ?? false) {
      await BrowsingHistory.clearHistory();
      _loadHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          'Browsing History',
          style: AppTextStyles.bold.copyWith(color: AppColors.darkText, fontSize: 18),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.darkText, size: 18),
          onPressed: () => Get.back(),
        ),
        actions: [
          if (_history.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 22),
                tooltip: 'Clear All',
                onPressed: _confirmClearAll,
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryPurple))
          : _history.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    // Top Status Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: 12),
                      color: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.history_toggle_off_rounded, size: 18, color: AppColors.primaryPurple),
                              const SizedBox(width: 8),
                              Text(
                                'Recently Viewed',
                                style: AppTextStyles.semiBold.copyWith(fontSize: 13, color: AppColors.darkText),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryPurple.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_history.length} items',
                              style: AppTextStyles.bold.copyWith(fontSize: 11, color: AppColors.primaryPurple),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Colors.black12),
                    
                    // Compact Horizontal Item Cards
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(AppDimensions.md),
                        physics: const BouncingScrollPhysics(),
                        itemCount: _history.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final product = _history[index];
                          return _buildHistoryCard(product);
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildHistoryCard(ProductModel product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Get.to(() => const ProductDetailScreen(), arguments: product.id);
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Product Thumbnail
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      product.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(Icons.image_not_supported, color: Colors.grey.shade400, size: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                
                // Product Information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (product.brand.isNotEmpty)
                        Text(
                          product.brand.toUpperCase(),
                          style: AppTextStyles.bold.copyWith(fontSize: 10, color: AppColors.primaryPurple, letterSpacing: 0.5),
                        ),
                      const SizedBox(height: 2),
                      Text(
                        product.name,
                        style: AppTextStyles.bold.copyWith(fontSize: 14, color: AppColors.darkText, height: 1.2),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '${product.priceCurrency} ${product.price.toStringAsFixed(0)}',
                            style: AppTextStyles.extraBold.copyWith(fontSize: 14, color: AppColors.primaryPurple),
                          ),
                          if (product.discountPriceOrg != null && product.discountPriceOrg! > product.price) ...[
                            const SizedBox(width: 8),
                            Text(
                              '${product.priceCurrency} ${product.discountPriceOrg!.toStringAsFixed(0)}',
                              style: AppTextStyles.medium.copyWith(
                                fontSize: 11,
                                color: AppColors.hintText,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Remove item action button
                IconButton(
                  icon: Icon(Icons.close_rounded, size: 18, color: Colors.grey.shade400),
                  tooltip: 'Remove',
                  onPressed: () => _removeItem(product.id),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.history_rounded, size: 50, color: AppColors.primaryPurple.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 20),
          Text(
            'No Browsing History',
            style: AppTextStyles.bold.copyWith(fontSize: 18, color: AppColors.darkText),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Products you explore while browsing Ushu Buy will be shown here for quick access.',
              style: AppTextStyles.medium.copyWith(fontSize: 13, color: AppColors.hintText, height: 1.4),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
