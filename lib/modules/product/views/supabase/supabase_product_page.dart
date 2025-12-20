import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/supabase_product_controller.dart';
import '../../../../data/cloud/supabase_service.dart';
import 'supabase_add_view.dart';
import 'dart:io';

class SupabaseProductPage extends StatelessWidget {
  SupabaseProductPage({super.key});

  final controller = Get.find<SupabaseProductController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Produk Supabase'), centerTitle: true),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        if (controller.products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 72,
                  color: cs.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text('Belum ada produk', style: theme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Tambahkan produk pertama ke Supabase',
                  style: theme.bodySmall,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.products.length,
          itemBuilder: (context, index) {
            final item = controller.products[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 0,
              color: cs.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),

                leading: _ProductThumbnail(item: item),

                title: Text(
                  item['display_name'] ?? 'Tanpa nama',
                  style: theme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoRow('Kategori', item['category']),
                      _infoRow('Kemasan', item['packaging']),
                      _infoRow('Harga', item['price']),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => SupabaseAddView()),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Produk'),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
      ),
    );
  }

  Widget _infoRow(String label, Object? value) {
    return Text(
      '$label: ${value ?? '-'}',
      style: const TextStyle(fontSize: 12),
    );
  }
}

class _ProductThumbnail extends StatelessWidget {
  final Map<String, dynamic> item;
  const _ProductThumbnail({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final raw = item['thumbnail']?.toString().trim();

    if (raw == null || raw.isEmpty) {
      return _placeholder(theme);
    }

    // 1️⃣ LOCAL FILE
    if (raw.startsWith('/')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(raw),
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(theme),
        ),
      );
    }

    // 2️⃣ FULL URL
    if (raw.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          raw,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(theme),
        ),
      );
    }

    // 3️⃣ SUPABASE STORAGE PATH
    final encoded = raw
        .replaceAll(RegExp(r'^/+'), '')
        .split('/')
        .map(Uri.encodeComponent)
        .join('/');

    final url = SupabaseService.client.storage
        .from('kecap-images')
        .getPublicUrl(encoded);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        url,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(theme),
      ),
    );
  }

  Widget _placeholder(ThemeData theme) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.image_not_supported_outlined,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
