import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/local/controllers/hive_product_controller.dart';
import 'hive_product_catalog.dart';

class HiveProductPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HiveProductController>();

    return Scaffold(
      appBar: AppBar(title: const Text("Hive Product Catalog")),
      body: ProductCatalogSection(controller: controller),
    );
  }
}
