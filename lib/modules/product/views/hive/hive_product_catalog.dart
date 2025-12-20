import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/data/local/controllers/hive_product_controller.dart';
import 'package:my_app/modules/product/widgets/dynamic_product_card.dart';
import 'package:my_app/modules/apify/controllers/apify_controller.dart';
import 'package:my_app/modules/product/views/stok/add_stock_view.dart';
import 'package:my_app/utils/helpers.dart';

class ProductCatalogSection extends StatelessWidget {
  final HiveProductController controller;
  const ProductCatalogSection({super.key, required this.controller});

  void _showProductDetail(BuildContext context, Map<String, dynamic> product) {
    final cs = Theme.of(context).colorScheme;

    // Format price as Rupiah
    final priceValue = product['price'];
    final formattedPrice = priceValue != null
        ? Helpers.formatCurrency(priceValue)
        : '-';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        icon: Icon(Icons.info_outline, color: cs.primary),
        title: Text(
          product['title'] ?? product['name'] ?? 'Product Detail',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow(context, 'Category', product['category'] ?? '-'),
              _detailRow(context, 'Price', formattedPrice),
              _detailRow(context, 'Stock', product['stock']?.toString() ?? '-'),
              _detailRow(context, 'Status', product['status'] ?? '-'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              try {
                final allProducts = controller.products;
                final prod = allProducts.firstWhere(
                  (p) => p.id == product['id'],
                  orElse: () => allProducts.isNotEmpty
                      ? allProducts.first
                      : throw Exception(),
                );
                Get.to(() => AddStockView(productToEdit: prod));
              } catch (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to load product')),
                );
              }
            },
            child: const Text('Edit'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(fontWeight: FontWeight.w600, color: cs.onSurface),
          ),
          Text(value, style: TextStyle(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Obx(() {
      final query = controller.searchQuery.value;
      final all = controller.apiProducts;

      final products = query.isEmpty
          ? all
          : all.where((p) {
              final title = p['title']?.toString().toLowerCase() ?? '';
              return title.contains(query.toLowerCase());
            }).toList();

      return Column(
        children: [
          // SEARCH BAR - OUTSIDE CARD
          TextField(
            onChanged: (v) => controller.searchQuery.value = v,
            decoration: InputDecoration(
              hintText: 'Search products',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: cs.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // CARD
          Expanded(
            child: Card(
              elevation: 0,
              color: cs.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  // HEADER
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.inventory_2, color: cs.onPrimary),
                        const SizedBox(width: 8),
                        Text(
                          'Product Catalog',
                          style: TextStyle(
                            color: cs.onPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // CONTENT
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: controller.loading.value
                          ? const Center(child: CircularProgressIndicator())
                          : products.isEmpty
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inbox,
                                  size: 64,
                                  color: cs.outlineVariant,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No products found',
                                  style: TextStyle(color: cs.onSurfaceVariant),
                                ),
                              ],
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
                                    DynamicProductCard(
                                      data: map,
                                      compact: false,
                                      onTap: () =>
                                          _showProductDetail(context, map),
                                    ),

                                    // DELETE BUTTON
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: IconButton.filledTonal(
                                        icon: const Icon(Icons.delete_outline),
                                        onPressed: () {
                                          _confirmDelete(context, map);
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  void _confirmDelete(BuildContext context, Map<String, dynamic> map) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text(
          'Are you sure you want to delete "${map['title'] ?? 'this product'}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.deleteProduct(map['id'] ?? '');

              try {
                final apify = Get.find<ApifyController>();
                apify.addRecentActivity({
                  'type': 'deleted',
                  'title': map['title'] ?? 'Product',
                  'description': 'Deleted from local storage',
                  'timeAgo': 'just now',
                  'timestamp': DateTime.now().toIso8601String(),
                });
              } catch (_) {}

              Navigator.pop(context);

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Product deleted')));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
