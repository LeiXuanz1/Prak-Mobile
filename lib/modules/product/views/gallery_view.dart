import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/barang_controller.dart';

class GalleryView extends StatelessWidget {
  final controller = Get.put(BarangController());

  GalleryView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Galeri Barang'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.productList.value.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Tidak ada barang',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: controller.productList.value.length,
          itemBuilder: (context, index) {
            final product = controller.productList.value[index];

            return GestureDetector(
              onTap: () {
                _showProductDetail(context, product);
              },
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          color: Colors.grey[100],
                        ),
                        child: _buildProductImage(product.thumbnail),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.title,
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Rp${product.price.toStringAsFixed(0)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildProductImage(dynamic thumbnail, {double? height}) {
    String? imagePath;
    if (thumbnail != null) {
      final str = thumbnail.toString().trim();
      if (str.isNotEmpty && !str.startsWith('[') && !str.startsWith('{')) {
        imagePath = str;
      }
    }

    if (imagePath != null && imagePath.isNotEmpty) {
      final file = File(imagePath);
      debugPrint('Checking image: $imagePath, exists: ${file.existsSync()}');
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          height: height,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Image load error: $error');
            return _buildPlaceholder(height);
          },
        );
      } else {
        debugPrint('File does not exist: $imagePath');
      }
    } else {
      debugPrint('No valid image path. Thumbnail: $thumbnail');
    }

    return _buildPlaceholder(height);
  }

  Widget _buildPlaceholder(double? height) {
    return Container(
      height: height ?? 200,
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.grey[400],
          size: 48,
        ),
      ),
    );
  }

  void _showProductDetail(BuildContext context, dynamic product) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildProductImage(product.thumbnail, height: 200),
              ),
              const SizedBox(height: 16),
              Text(
                product.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Rp${product.price.toStringAsFixed(0)}',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: product.stock > 0
                      ? Colors.green.withAlpha((0.1 * 255).round())
                      : Colors.red.withAlpha((0.1 * 255).round()),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Stok: ${product.stock} ${product.unit ?? ''}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: product.stock > 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
