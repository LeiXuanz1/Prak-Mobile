import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../apify/controllers/apify_controller.dart';

class DashboardStats extends StatelessWidget {
  final ApifyController controller;
  const DashboardStats({super.key, required this.controller});

  Widget _statCard(BuildContext context, {required IconData icon, required String title, required String value, required String subtitle, required List<Color> gradient}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(gradient: LinearGradient(colors: gradient), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: Colors.white)),
        const SizedBox(height: 12),
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 4),
        Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final totalProducts = controller.apiProducts.length;
      final lowStockItems = controller.apiProducts.where((p) => (p['stock'] ?? 0) <= 20).length;

      double totalValue = 0;
      for (var product in controller.apiProducts) {
        final stock = int.tryParse(product['stock']?.toString() ?? '0') ?? 0;
        final price = double.tryParse(product['price']?.toString() ?? '0') ?? 0.0;
        totalValue += stock * price;
      }

      final ordersToday = controller.successCount.value;

      return Column(children: [
        Row(children: [
          Expanded(child: _statCard(context, icon: Icons.inventory_2, title: 'Total Products', value: totalProducts.toString(), subtitle: '+12 this week', gradient: const [Color(0xFF66BB6A), Color(0xFF4CAF50)])),
          const SizedBox(width: 12),
          Expanded(child: _statCard(context, icon: Icons.warning_amber_rounded, title: 'Low Stock Items', value: lowStockItems.toString(), subtitle: '$lowStockItems critical', gradient: const [Color(0xFFFFB74D), Color(0xFFFF9800)])),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _statCard(context, icon: Icons.attach_money, title: 'Total Value', value: '\$${totalValue.toStringAsFixed(1)}K', subtitle: '+8.2% to last month', gradient: const [Color(0xFF42A5F5), Color(0xFF2196F3)])),
          const SizedBox(width: 12),
          Expanded(child: _statCard(context, icon: Icons.shopping_cart, title: 'Orders Today', value: ordersToday.toString(), subtitle: '12 completed', gradient: const [Color(0xFFBA68C8), Color(0xFF9C27B0)])),
        ]),
      ]);
    });
  }
}
