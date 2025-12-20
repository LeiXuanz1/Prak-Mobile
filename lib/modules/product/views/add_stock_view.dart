

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:my_app/modules/product/models/product_form_data.dart';
import 'package:my_app/modules/product/mappers/product_hive_mapper.dart';
import 'package:my_app/modules/product/widgets/product_form.dart';
import 'package:my_app/data/local/controllers/hive_product_controller.dart';
import 'package:my_app/data/local/hive_models/product_hive_model.dart';

class AddStockView extends StatelessWidget {
  final ProductHiveModel? productToEdit;

  AddStockView({super.key, this.productToEdit});

  final HiveProductController controller =
      Get.find<HiveProductController>();

  @override
  Widget build(BuildContext context) {
    final edit = productToEdit;

    return Scaffold(
      appBar: AppBar(
        title: Text(edit == null ? 'Add Product' : 'Edit Product'),
        centerTitle: true,
      ),
      body: ProductForm(
        initial: edit == null
            ? null
            : ProductFormData(
                title: edit.title,
                category: edit.category,
                stock: edit.stock,
                unit: edit.unit,
                price: edit.price,
                packaging: edit.packaging,
                description: edit.description ?? '',
                imagePath: edit.thumbnail,
              ),
        submitLabel: 'Save Product',
        onSubmit: (data) {
          final product = mapFormToHive(data, edit);

          if (edit == null) {
            controller.addProduct(product);
          } else {
            controller.updateProduct(product.id, product);
          }

          Get.back();
        },
      ),
    );
  }
}