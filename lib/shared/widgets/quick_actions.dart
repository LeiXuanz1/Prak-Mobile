import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../modules/apify/controllers/apify_controller.dart';
import '../../modules/product/views/stok/add_stock_view.dart';

class QuickActions extends StatelessWidget {
  final ApifyController controller;
  const QuickActions({super.key, required this.controller});

  Widget _actionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min, // 🔑 penting
            children: [
              Container(
                height: 48, // M3 min touch target
                width: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: GridView.extent(
        maxCrossAxisExtent: 120,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _actionCard(
            context,
            icon: Icons.add_circle_outline,
            label: 'Add Product',
            onTap: () => Get.to(() => const AddStockView()),
          ),
          _actionCard(
            context,
            icon: Icons.bar_chart_outlined,
            label: 'Reports',
            onTap: () {},
          ),
          _actionCard(
            context,
            icon: Icons.analytics_outlined,
            label: 'Analytics',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
