import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/modules/product/views/hive/hive_add_view.dart';
import 'package:my_app/data/local/controllers/hive_product_controller.dart';
import 'hive_product_catalog.dart';

class HiveProductPage extends StatelessWidget {
  const HiveProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HiveProductController>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hive Product Catalog'),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ProductCatalogSection(controller: controller),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const HiveAddView()),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Produk'),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
      ),
    );
  }
}
