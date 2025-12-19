import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/inventory_overview_controller.dart';
import '../../product/models/period_filter.dart';

class InventoryOverviewWidget extends StatelessWidget {
  const InventoryOverviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InventoryOverviewController());
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // PERIOD FILTER
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: PeriodFilter.values.map((period) {
              return Obx(
                () => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(period.label),
                    selected: controller.selectedPeriod.value == period,
                    onSelected: (_) => controller.changePeriod(period),
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    selectedColor: theme.colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color: controller.selectedPeriod.value == period
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),

        // STATS CARDS
        Obx(
          () => Column(
            children: [
              // Row 1: Stok Masuk & Stok Keluar
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Stok Masuk',
                      value: controller.totalStockIn.value.toString(),
                      icon: Icons.arrow_downward,
                      gradient: const [Color(0xFF66BB6A), Color(0xFF4CAF50)],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Stok Keluar',
                      value: controller.totalStockOut.value.toString(),
                      icon: Icons.arrow_upward,
                      gradient: const [Color(0xFFF44336), Color(0xFFE53935)],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Row 2: Omset & Untung
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Omset',
                      value:
                          'Rp${_formatCurrency(controller.totalOmset.value)}',
                      icon: Icons.trending_up,
                      gradient: const [Color(0xFF42A5F5), Color(0xFF2196F3)],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Untung',
                      value:
                          'Rp${_formatCurrency(controller.totalProfit.value)}',
                      icon: Icons.attach_money,
                      gradient: const [Color(0xFFBA68C8), Color(0xFF9C27B0)],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatCurrency(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> gradient;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
