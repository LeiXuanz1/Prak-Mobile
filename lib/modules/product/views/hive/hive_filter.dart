import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/data/local/controllers/hive_product_controller.dart';

class HiveFilter extends StatelessWidget {
  final HiveProductController controller;

  const HiveFilter({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Obx(
        () => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Produk',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // STOK
            DropdownButtonFormField<StockFilter>(
              value: controller.stockFilter.value,
              decoration: const InputDecoration(labelText: 'Status Stok'),
              items: const [
                DropdownMenuItem(
                  value: StockFilter.all,
                  child: Text('Semua'),
                ),
                DropdownMenuItem(
                  value: StockFilter.inStock,
                  child: Text('Tersedia'),
                ),
                DropdownMenuItem(
                  value: StockFilter.outOfStock,
                  child: Text('Habis'),
                ),
              ],
              onChanged: (v) {
                if (v != null) controller.setStockFilter(v);
              },
            ),

            const SizedBox(height: 24),

            // ACTIONS
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    controller.setCategory('');
                    controller.setStockFilter(StockFilter.all);
                    Get.back();
                  },
                  child: const Text('Reset'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Get.back(),
                  child: const Text('Terapkan'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
