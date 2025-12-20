
import 'package:flutter/material.dart';
import 'dart:io';

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

  Widget _resolveImage(String? path,
      {BoxFit fit = BoxFit.cover, bool small = false}) {
    if (path == null || path.isEmpty) {
      return small ? _buildSmallPlaceholder() : _buildPlaceholder();
    }

    // Network image
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: fit,
        errorBuilder: (_, __, ___) =>
            small ? _buildSmallPlaceholder() : _buildPlaceholder(),
      );
    }

    // Local file (absolute / relative)
    final file = File(path);
    if (file.existsSync()) {
      return Image.file(
        file,
        fit: fit,
        errorBuilder: (_, __, ___) =>
            small ? _buildSmallPlaceholder() : _buildPlaceholder(),
      );
    }

    return small ? _buildSmallPlaceholder() : _buildPlaceholder();
  }


  @override
  Widget build(BuildContext context) {
    final imagePath = _extractImageUrl();
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
                    child: _resolveImage(
                      imagePath,
                      small: true,
                    ),          
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

    // Default layout
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: _resolveImage(imagePath),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 4),

                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),

                      const Spacer(),

                      Row(
                        children: [
                          if (price != null)
                          Expanded(
                            child: Text(
                              price,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          if (stock != null) ... [
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStockColor(stock)
                                    .withValues(alpha: 0.1),
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
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
        if (value.isNotEmpty) {
          // Accept HTTP URLs or local file paths
          if (value.isNotEmpty) {
            return value;
          }
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