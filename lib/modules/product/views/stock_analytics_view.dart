import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/stock_analytics_controller.dart';

class StockAnalyticsView extends StatelessWidget {
  const StockAnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StockAnalyticsController());
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Analitik Stok'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Range Selection
            Text(
              'Periode Analitik',
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

            // Stock Movement Chart
            Text(
              'Kondisi Stok per Produk',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.stockMovementData.isEmpty) {
                return _EmptyStateCard();
              }

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 250,
                      child: _StockMovementChart(
                        data: controller.stockMovementData,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ChartLegend(
                      title: 'Stok Akhir',
                      items: controller.stockMovementData
                          .take(5)
                          .map((d) => MapEntry(d.label, d.value.toInt()))
                          .toList(),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),

            // In vs Out Comparison
            Text(
              'Perbandingan Barang Masuk vs Keluar',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.inOutComparisonData.isEmpty) {
                return _EmptyStateCard();
              }

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: _InOutComparisonChart(
                        data: controller.inOutComparisonData,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _ComparisonStat(
                          label: 'Masuk',
                          value: controller.inOutComparisonData
                              .firstWhere(
                                (e) => e.key == 'Masuk',
                                orElse: () => MapEntry('Masuk', 0),
                              )
                              .value,
                          color: const Color(0xFF4CAF50),
                        ),
                        _ComparisonStat(
                          label: 'Keluar',
                          value: controller.inOutComparisonData
                              .firstWhere(
                                (e) => e.key == 'Keluar',
                                orElse: () => MapEntry('Keluar', 0),
                              )
                              .value,
                          color: const Color(0xFFF44336),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),

            // Top Products
            Text(
              'Produk Paling Sering Bertransaksi (Top 5)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.topProductsData.isEmpty) {
                return _EmptyStateCard();
              }

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.topProductsData.length,
                  separatorBuilder: (_, __) =>
                      Divider(color: Colors.grey.shade200),
                  itemBuilder: (context, index) {
                    final item = controller.topProductsData[index];
                    return Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: _getProductColor(index),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.key,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${item.value} transaksi',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getProductColor(
                                index,
                              ).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${item.value}x',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _getProductColor(index),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Color _getProductColor(int index) {
    const colors = [
      Color(0xFF2196F3),
      Color(0xFF4CAF50),
      Color(0xFFFF9800),
      Color(0xFFF44336),
      Color(0xFF9C27B0),
    ];
    return colors[index % colors.length];
  }
}

class _DatePickerButton extends StatelessWidget {
  final String label;
  final StockAnalyticsController controller;
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

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.bar_chart, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'Tidak ada data untuk ditampilkan',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _StockMovementChart extends StatelessWidget {
  final List<ChartDataPoint> data;

  const _StockMovementChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox();
    }

    final maxValue = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);
    final chartHeight = 200.0;

    return CustomPaint(
      painter: _LineChartPainter(data, maxValue, chartHeight),
      size: const Size(double.infinity, 200),
    );
  }
}

class _InOutComparisonChart extends StatelessWidget {
  final List<MapEntry<String, int>> data;

  const _InOutComparisonChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox();
    }

    final maxValue = data
        .map((d) => d.value)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    return CustomPaint(
      painter: _BarChartPainter(data, maxValue),
      size: const Size(double.infinity, 180),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  final String title;
  final List<MapEntry<String, int>> items;

  const _ChartLegend({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items
              .map(
                (item) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${item.key}: ${item.value}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _ComparisonStat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _ComparisonStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              value.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

// Custom Painters untuk Chart

class _LineChartPainter extends CustomPainter {
  final List<ChartDataPoint> data;
  final double maxValue;
  final double chartHeight;

  _LineChartPainter(this.data, this.maxValue, this.chartHeight);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = const Color(0xFF2196F3)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final width = size.width;
    final height = size.height;
    final padding = 20.0;
    final chartWidth = width - (padding * 2);
    final chartHeightValue = height - (padding * 2);

    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.1)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = padding + (chartHeightValue / 4) * i;
      canvas.drawLine(
        Offset(padding, y),
        Offset(width - padding, y),
        gridPaint,
      );
    }

    // Draw data points and lines
    final spacing =
        chartWidth / (data.length - 1).clamp(1, data.length).toDouble();

    for (int i = 0; i < data.length - 1; i++) {
      final current = data[i];
      final next = data[i + 1];

      final x1 = padding + (i * spacing);
      final y1 =
          height -
          padding -
          ((current.value / maxValue) * chartHeightValue).clamp(
            0,
            chartHeightValue,
          );

      final x2 = padding + ((i + 1) * spacing);
      final y2 =
          height -
          padding -
          ((next.value / maxValue) * chartHeightValue).clamp(
            0,
            chartHeightValue,
          );

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);

      // Draw point
      canvas.drawCircle(Offset(x1, y1), 4, paint);
    }

    // Draw last point
    final lastData = data.last;
    final lastX = padding + ((data.length - 1) * spacing);
    final lastY =
        height -
        padding -
        ((lastData.value / maxValue) * chartHeightValue).clamp(
          0,
          chartHeightValue,
        );
    canvas.drawCircle(Offset(lastX, lastY), 4, paint);
  }

  @override
  bool shouldRepaint(_LineChartPainter oldDelegate) => false;
}

class _BarChartPainter extends CustomPainter {
  final List<MapEntry<String, int>> data;
  final double maxValue;

  _BarChartPainter(this.data, this.maxValue);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final width = size.width;
    final height = size.height;
    final padding = 20.0;
    final chartWidth = width - (padding * 2);
    final chartHeight = height - (padding * 2);
    final barWidth = chartWidth / (data.length * 2);

    final colors = [const Color(0xFF4CAF50), const Color(0xFFF44336)];

    for (int i = 0; i < data.length; i++) {
      final value = data[i].value.toDouble();
      final barHeight = (value / maxValue) * chartHeight;

      final x = padding + (i * barWidth * 2) + barWidth / 2;
      final y = height - padding - barHeight;

      final paint = Paint()..color = colors[i % colors.length];

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          const Radius.circular(4),
        ),
        paint,
      );

      // Draw value text
      final textPainter = TextPainter(
        text: TextSpan(
          text: value.toInt().toString(),
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x + (barWidth - textPainter.width) / 2, y - 20),
      );
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter oldDelegate) => false;
}
