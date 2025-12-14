import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../modules/apify/controllers/apify_controller.dart';
import '../../modules/product/views/add_stock_view.dart';

class QuickActions extends StatelessWidget {
  final ApifyController controller;
  const QuickActions({super.key, required this.controller});

  Widget _actionCard(IconData icon, String label, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 24)),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87), textAlign: TextAlign.center),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _actionCard(Icons.add_circle, 'Add Product', const Color(0xFFFF6B00), () => Get.to(() => const AddStockView())),
        _actionCard(Icons.search, 'Search', const Color(0xFF2196F3), () {}),
        _actionCard(Icons.bar_chart, 'Reports', const Color(0xFF9C27B0), () {}),
        _actionCard(Icons.analytics, 'Analytics', const Color(0xFF4CAF50), () {}),
      ],
    );
  }
}
