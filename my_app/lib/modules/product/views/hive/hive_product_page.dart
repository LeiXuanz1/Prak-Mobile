import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/modules/product/views/hive/hive_add_view.dart';
import '../../../../data/local/controllers/hive_product_controller.dart';
import 'hive_product_catalog.dart';

class HiveProductPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HiveProductController>();

    return Scaffold(
      appBar: AppBar(title: const Text("Hive Product Catalog")),
      body: ProductCatalogSection(controller: controller),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const HiveAddView()),
        backgroundColor: const Color(0xFFFF6B00),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Produk'),
        ),
    );
  }
}
