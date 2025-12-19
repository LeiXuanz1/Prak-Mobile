import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/stock_report_controller.dart';

class StockReportView extends StatelessWidget {
  const StockReportView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StockReportController());
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Laporan Stok'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Range Selection
            Text(
              'Periode Laporan',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DatePickerButton(
                    label: 'Dari',
                    controller: controller,
                    isStart: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DatePickerButton(
                    label: 'Sampai',
                    controller: controller,
                    isStart: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Summary Cards
            Text(
              'Ringkasan',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Obx(
              () => Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          title: 'Total Stok Masuk',
                          value: controller.totalStockInAll.value.toString(),
                          icon: Icons.arrow_downward,
                          gradient: const [
                            Color(0xFF66BB6A),
                            Color(0xFF4CAF50),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          title: 'Total Stok Keluar',
                          value: controller.totalStockOutAll.value.toString(),
                          icon: Icons.arrow_upward,
                          gradient: const [
                            Color(0xFFF44336),
                            Color(0xFFE53935),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          title: 'Total Omset',
                          value:
                              'Rp${_formatCurrency(controller.totalOmsetAll.value)}',
                          icon: Icons.trending_up,
                          gradient: const [
                            Color(0xFF42A5F5),
                            Color(0xFF2196F3),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          title: 'Total Keuntungan',
                          value:
                              'Rp${_formatCurrency(controller.totalProfitAll.value)}',
                          icon: Icons.attach_money,
                          gradient: const [
                            Color(0xFFBA68C8),
                            Color(0xFF9C27B0),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Report Details
            Text(
              'Detail per Produk',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.reportData.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.inbox,
                          size: 48,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tidak ada data transaksi',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.reportData.length,
                separatorBuilder: (_, __) =>
                    Divider(color: Colors.grey.shade200),
                itemBuilder: (context, index) {
                  final item = controller.reportData[index];
                  return _ReportDetailCard(
                    productName: item.productName,
                    totalStockIn: item.totalStockIn,
                    totalStockOut: item.totalStockOut,
                    finalStock: item.finalStock,
                    totalOmset: item.totalOmset,
                    totalProfit: item.totalProfit,
                  );
                },
              );
            }),
          ],
        ),
      ),
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

class _DatePickerButton extends StatelessWidget {
  final String label;
  final StockReportController controller;
  final bool isStart;

  const _DatePickerButton({
    required this.label,
    required this.controller,
    required this.isStart,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final date = isStart
          ? controller.selectedStartDate.value
          : controller.selectedEndDate.value;

      return GestureDetector(
        onTap: () async {
          final pickedDate = await showDatePicker(
            context: context,
            initialDate: date ?? DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
          );
          if (pickedDate != null) {
            if (isStart) {
              controller.setStartDate(pickedDate);
            } else {
              controller.setEndDate(pickedDate);
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date != null
                    ? '${date.day}/${date.month}/${date.year}'
                    : 'Pilih tanggal',
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> gradient;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportDetailCard extends StatelessWidget {
  final String productName;
  final int totalStockIn;
  final int totalStockOut;
  final int finalStock;
  final double totalOmset;
  final double totalProfit;

  const _ReportDetailCard({
    required this.productName,
    required this.totalStockIn,
    required this.totalStockOut,
    required this.finalStock,
    required this.totalOmset,
    required this.totalProfit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            productName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _DetailItem(
                label: 'Masuk',
                value: totalStockIn.toString(),
                color: const Color(0xFF4CAF50),
              ),
              _DetailItem(
                label: 'Keluar',
                value: totalStockOut.toString(),
                color: const Color(0xFFF44336),
              ),
              _DetailItem(
                label: 'Akhir',
                value: finalStock.toString(),
                color: Colors.blue,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _DetailItem(
                label: 'Omset',
                value: 'Rp${_formatCurrency(totalOmset)}',
                isSmall: true,
                color: Colors.orange,
              ),
              _DetailItem(
                label: 'Untung',
                value: 'Rp${_formatCurrency(totalProfit)}',
                isSmall: true,
                color: totalProfit > 0 ? Colors.green : Colors.red,
              ),
            ],
          ),
        ],
      ),
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

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isSmall;

  const _DetailItem({
    required this.label,
    required this.value,
    required this.color,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isSmall ? 10 : 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: isSmall ? 12 : 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
