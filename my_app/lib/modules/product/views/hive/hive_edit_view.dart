import 'package:flutter/material.dart';
import 'package:my_app/data/local/hive_models/product_hive_model.dart';
import 'package:my_app/modules/product/views/add_stock_view.dart';


class HiveEditView extends StatelessWidget {
  final ProductHiveModel product;
  const HiveEditView({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return AddStockView(productToEdit: product);
  }
}
