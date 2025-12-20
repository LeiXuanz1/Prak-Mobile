import 'package:flutter/material.dart';
import 'package:my_app/modules/product/views/add_stock_view.dart';

class HiveAddView extends StatelessWidget {
  const HiveAddView({super.key});

  @override
  Widget build(BuildContext context) {
    // Use AddStockView as the single combined add/edit view
    return AddStockView();
  }
}