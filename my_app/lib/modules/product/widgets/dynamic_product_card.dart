import 'package:flutter/material.dart';
import 'dart:developer';

class DynamicProductCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onTap;
  final bool compact;

  const DynamicProductCard({
    super.key,
    required this.data,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = _extractImageUrl();
    final title = _extractTitle();
    final subtitle = _extractSubtitle();
    final price = _extractPrice();
    final stock = _extractStock();

    if (compact) {
      return Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: imageUrl != null && imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            semanticLabel: title,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildSmallPlaceholder(),
                          )
                        : _buildSmallPlaceholder(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              subtitle.isNotEmpty
                                  ? subtitle
                                  : (data['category'] ?? ''),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (price != null)
                            Text(
                              price,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (stock != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStockColor(
                              stock,
                            ).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Stock: $stock',
                            style: TextStyle(
                              fontSize: 11,
                              color: _getStockColor(stock),
                            ),
                          ),
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

    // Default (original) layout
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            _buildImageSection(imageUrl),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Subtitle
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 8),

                  // Price & Stock Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (price != null)
                        Text(
                          price,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      if (stock != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStockColor(stock).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Stock: $stock',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _getStockColor(stock),
                            ),
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
    );
  }

  Widget _buildImageSection(String? imageUrl) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: imageUrl != null && imageUrl.isNotEmpty
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholder();
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
            )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          const Color(0xFF8B0000).withValues(alpha: 0.7),
          const Color(0xFFD2691E).withValues(alpha: 0.7),
        ],
      ),
    ),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_drink,
            size: 40,
            color: Colors.white.withValues(alpha: 0.8),
          ),
          const SizedBox(height: 4),
          Text(
            'Kecap Product',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildSmallPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Icon(Icons.local_drink, color: Colors.grey.shade400, size: 28),
      ),
    );
  }

  String? _extractImageUrl() {
    final possibleKeys = [
      'image',
      'imageUrl',
      'image_url',
      'thumbnail',
      'thumb',
      'photo',
      'picture',
      'img',
      'strMealThumb',
      'strDrinkThumb',
      'artworkUrl100',
      'cover_image',
      'featured_image',
      'product_image',
    ];

    for (var key in possibleKeys) {
      if (data.containsKey(key) && data[key] != null) {
        final value = data[key].toString();
        if (value.isNotEmpty &&
            (value.startsWith('http://') || value.startsWith('https://'))) {
          return value;
        }
      }
    }

    // Cek nested objects
    if (data.containsKey('data') && data['data'] is Map) {
      final nested = data['data'] as Map<String, dynamic>;
      return DynamicProductCard(data: nested, onTap: null)._extractImageUrl();
    }

    return null;
  }

  String _extractTitle() {
    final possibleKeys = [
      'title',
      'name',
      'product_name',
      'productName',
      'strMeal',
      'strDrink',
      'trackName',
      'label',
      'description',
      'id',
    ];

    for (var key in possibleKeys) {
      if (data.containsKey(key) && data[key] != null) {
        final value = data[key].toString();
        if (value.isNotEmpty) {
          return value;
        }
      }
    }

    return 'Product ${data.hashCode.abs() % 1000}';
  }

  String _extractSubtitle() {
    final possibleKeys = [
      'subtitle',
      'category',
      'brand',
      'manufacturer',
      'strCategory',
      'type',
      'variant',
      'description',
      'actId',
      'status',
    ];

    for (var key in possibleKeys) {
      if (data.containsKey(key) && data[key] != null) {
        final value = data[key].toString();
        if (value.isNotEmpty && value != _extractTitle()) {
          return value;
        }
      }
    }

    return '';
  }

  String? _extractPrice() {
    final possibleKeys = ['price', 'cost', 'amount', 'value', 'harga'];

    for (var key in possibleKeys) {
      if (data.containsKey(key) && data[key] != null) {
        final value = data[key];
        if (value is num) {
          return 'Rp ${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
        } else if (value is String && value.isNotEmpty) {
          return value;
        }
      }
    }

    return null;
  }

  int? _extractStock() {
    final possibleKeys = [
      'stock',
      'quantity',
      'qty',
      'available',
      'inventory',
      'count',
    ];

    for (var key in possibleKeys) {
      if (data.containsKey(key) && data[key] != null) {
        final value = data[key];
        if (value is int) {
          return value;
        } else if (value is String) {
          return int.tryParse(value);
        }
      }
    }

    return null;
  }

  Color _getStockColor(int stock) {
    if (stock > 50) return Colors.green;
    if (stock > 20) return Colors.orange;
    return Colors.red;
  }
}

class ProductCatalogExample extends StatelessWidget {
  const ProductCatalogExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Example: Data dari berbagai API akan tetap work
    final products = [
      {
        'image': 'https://example.com/kecap1.jpg',
        'title': 'Kecap Manis ABC',
        'category': 'Kecap Manis',
        'price': 15000,
        'stock': 120,
      },
      {
        'imageUrl': 'https://example.com/kecap2.jpg',
        'name': 'Kecap Asin Bango',
        'brand': 'Bango',
        'harga': 12000,
        'quantity': 45,
      },
      {
        // Tanpa gambar - akan show placeholder
        'title': 'Kecap Special',
        'subtitle': 'Premium Quality',
        'price': 25000,
        'stock': 5,
      },
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return DynamicProductCard(
          data: products[index],
          onTap: () {
            // Handle tap
            log("Product tapped: , ${products[index]}");
          },
        );
      },
    );
  }
}
