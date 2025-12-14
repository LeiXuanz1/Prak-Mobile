import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/data/local/controllers/hive_product_controller.dart';
import 'package:my_app/modules/product/widgets/dynamic_product_card.dart';
import 'package:my_app/modules/apify/controllers/apify_controller.dart';
import 'package:my_app/modules/product/views/add_stock_view.dart';

class ProductCatalogSection extends StatelessWidget {
  final HiveProductController controller;
  const ProductCatalogSection({super.key, required this.controller});

  void _showProductDetail(BuildContext context, Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B00).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.info_outline, color: Color(0xFFFF6B00)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  product['title'] ?? product['name'] ?? 'Product Detail',
                  style: const TextStyle(fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow('Category', product['category'] ?? '-'),
                _detailRow('Price', product['price']?.toString() ?? '-'),
                _detailRow('Stock', product['stock']?.toString() ?? '-'),
                _detailRow('Status', product['status'] ?? '-'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Find the actual ProductHiveModel from the controller to pass to edit view
                try {
                  final allProducts = controller.products;
                  final prod = allProducts.firstWhere(
                    (p) => p.id == product['id'],
                    orElse: () => allProducts.isNotEmpty
                        ? allProducts.first
                        : throw Exception('Product not found'),
                  );
                  Get.to(() => AddStockView(productToEdit: prod));
                } catch (e) {
                  Get.snackbar('Error', 'Could not load product for editing');
                }
              },
              child: const Text(
                'Edit',
                style: TextStyle(color: Color(0xFFFF6B00)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Close',
                style: TextStyle(color: Color(0xFFFF6B00)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final query = controller.searchQuery.value;
      final all = controller.apiProducts;

      final products = query.isEmpty
          ? all
          : all.where((p) {
              final title = p['title']?.toString().toLowerCase() ?? '';
              return title.contains(query.toLowerCase());
            }).toList();

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF8B0000), Color(0xFFD2691E)],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.inventory_2, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Product Catalog',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // CONTENT AREA
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      onChanged: (v) => controller.searchQuery.value = v,
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(
                            color: Color(0xFFFF6B00),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: controller.loading.value
                          ? const Center(child: CircularProgressIndicator())
                          : products.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.inbox,
                                    size: 64,
                                    color: Colors.grey.shade300,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No products found',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 0.75,
                                  ),
                              itemCount: products.length,
                              itemBuilder: (context, index) {
                                final map = products[index];
                                return Stack(
                                  children: [
                                    GestureDetector(
                                      onTap: () =>
                                          _showProductDetail(context, map),
                                      child: DynamicProductCard(
                                        data: map,
                                        compact: false,
                                        onTap: () =>
                                            _showProductDetail(context, map),
                                      ),
                                    ),
                                    // Delete button (red trash icon) - top right corner
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap: () {
                                          // Show confirmation dialog before delete
                                          showDialog(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: const Text(
                                                'Delete Product?',
                                              ),
                                              content: Text(
                                                'Are you sure you want to delete "${map['title'] ?? 'this product'}"?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(ctx),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    controller.deleteProduct(
                                                      map['id'] ?? '',
                                                    );
                                                    try {
                                                      final apify =
                                                          Get.find<
                                                            ApifyController
                                                          >();
                                                      apify.addRecentActivity({
                                                        'type': 'deleted',
                                                        'title':
                                                            map['title'] ??
                                                            'Product',
                                                        'description':
                                                            'Deleted from local storage',
                                                        'timeAgo': 'just now',
                                                        'timestamp': DateTime.now()
                                                            .toIso8601String(),
                                                      });
                                                    } catch (_) {}
                                                    Navigator.pop(ctx);
                                                    Get.snackbar(
                                                      'Deleted',
                                                      'Product deleted successfully',
                                                      snackPosition:
                                                          SnackPosition.BOTTOM,
                                                      backgroundColor:
                                                          Colors.red,
                                                      colorText: Colors.white,
                                                    );
                                                  },
                                                  child: const Text(
                                                    'Delete',
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.red.withValues(
                                                  alpha: 0.4,
                                                ),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          padding: const EdgeInsets.all(8),
                                          child: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
