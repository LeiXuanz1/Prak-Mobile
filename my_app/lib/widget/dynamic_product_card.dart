import 'package:flutter/material.dart';

/// Dynamic Product Card yang bisa handle berbagai struktur JSON API
/// Otomatis detect field gambar dan data produk
class DynamicProductCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onTap;

  const DynamicProductCard({
    super.key,
    required this.data,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = _extractImageUrl();
    final title = _extractTitle();
    final subtitle = _extractSubtitle();
    final price = _extractPrice();
    final stock = _extractStock();

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

            // Content Section
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
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8B0000),
                          ),
                        ),
                      if (stock != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStockColor(stock).withOpacity(0.1),
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
            const Color(0xFF8B0000).withOpacity(0.7),
            const Color(0xFFD2691E).withOpacity(0.7),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_drink,
            size: 64,
            color: Colors.white.withOpacity(0.8),
          ),
          const SizedBox(height: 8),
          Text(
            'Kecap Product',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // DYNAMIC DATA EXTRACTION
  // Auto-detect berbagai kemungkinan field names

  String? _extractImageUrl() {
    // Cek berbagai kemungkinan field untuk image
    final possibleKeys = [
      'image',
      'imageUrl',
      'image_url',
      'thumbnail',
      'thumb',
      'photo',
      'picture',
      'img',
      'strMealThumb', // TheMealDB
      'strDrinkThumb', // TheCocktailDB
      'artworkUrl100', // iTunes API
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
      'strMeal', // TheMealDB
      'strDrink', // TheCocktailDB
      'trackName', // iTunes
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
      'strCategory', // TheMealDB
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
    final possibleKeys = [
      'price',
      'cost',
      'amount',
      'value',
      'harga',
    ];

    for (var key in possibleKeys) {
      if (data.containsKey(key) && data[key] != null) {
        final value = data[key];
        if (value is num) {
          return 'Rp ${value.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          )}';
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

// EXAMPLE USAGE IN YOUR VIEW

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
            print('Product tapped: ${products[index]}');
          },
        );
      },
    );
  }
}