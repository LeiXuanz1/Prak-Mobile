import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/widget/dynamic_product_card.dart';
import '../controllers/apify_controller.dart';

class ApifyView extends StatelessWidget {
  const ApifyView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ApifyController());

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8B0000), Color(0xFF6B0000), Color(0xFFD2691E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.shade600,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.local_drink, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Management Kecap API',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'HTTP vs Dio Performance',
                    style: TextStyle(fontSize: 11, color: Colors.amber),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.resetStats,
            tooltip: 'Reset Statistics',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;
          final isDesktop = constraints.maxWidth > 1024;

          return SingleChildScrollView(
            padding: EdgeInsets.all(
              isDesktop
                  ? 24
                  : isTablet
                  ? 16
                  : 12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Control Panel
                _buildControlPanel(controller, isTablet),
                const SizedBox(height: 16),

                // Stats Cards
                _buildStatsCards(controller, isTablet, isDesktop),
                const SizedBox(height: 16),

                // Product Catalog Section
                _buildProductCatalog(controller, isTablet, isDesktop),
                const SizedBox(height: 16),

                // Results Table
                _buildResultsTable(controller, isTablet),
                const SizedBox(height: 16),

                // Info Footer
                _buildInfoFooter(isTablet),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildControlPanel(ApifyController controller, bool isTablet) {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: const Border(
            left: BorderSide(color: Color(0xFF8B0000), width: 4),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.science, color: Colors.red.shade800),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Control Panel',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                      Text(
                        'Jalankan pengujian performa API',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildTestButton(
                  label: 'Run Test (Async-Await)',
                  icon: Icons.play_arrow,
                  color: const Color(0xFF8B0000),
                  isLoading:
                      controller.loading.value &&
                      controller.testMode.value == 'async',
                  onPressed: controller.runComparisonAsync,
                  isTablet: isTablet,
                ),
                _buildTestButton(
                  label: 'Run Test (Callback)',
                  icon: Icons.play_arrow,
                  color: const Color(0xFFD2691E),
                  isLoading:
                      controller.loading.value &&
                      controller.testMode.value == 'callback',
                  onPressed: controller.runComparisonCallback,
                  isTablet: isTablet,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool isLoading,
    required VoidCallback onPressed,
    required bool isTablet,
  }) {
    return SizedBox(
      width: isTablet ? null : double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(icon),
        label: Text(isLoading ? 'Testing...' : label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildStatsCards(
    ApifyController controller,
    bool isTablet,
    bool isDesktop,
  ) {
    return Obx(() {
      final stats = [
        _StatData(
          'Avg HTTP',
          '${controller.avgHttpTime.value.toStringAsFixed(0)} ms',
          Icons.http,
          Colors.blue,
        ),
        _StatData(
          'Avg Dio',
          '${controller.avgDioTime.value.toStringAsFixed(0)} ms',
          Icons.flash_on,
          Colors.green,
        ),
        _StatData(
          'Success Rate',
          controller.getSuccessRate(),
          Icons.check_circle,
          Colors.purple,
        ),
        _StatData(
          'Total Tests',
          '${controller.totalTests.value}',
          Icons.analytics,
          Colors.amber.shade700,
        ),
      ];

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isDesktop
              ? 4
              : isTablet
              ? 2
              : 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: isDesktop
              ? 2.5
              : isTablet
              ? 2.2
              : 1.8,
        ),
        itemCount: stats.length,
        itemBuilder: (context, index) {
          final stat = stats[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border(top: BorderSide(color: stat.color, width: 3)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        stat.label,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      stat.icon,
                      color: stat.color.withOpacity(0.3),
                      size: 28,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  stat.value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  // PRODUCT CATALOG SECTION
  Widget _buildProductCatalog(
    ApifyController controller,
    bool isTablet,
    bool isDesktop,
  ) {
    return Obx(() {
      final products = controller.apiProducts;

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF8B0000), Color(0xFFD2691E)],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.inventory_2, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '\ud83c\udf76 Product Catalog & Stock Management',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Product Grid (use API products)
            Padding(
              padding: const EdgeInsets.all(16),
              child: controller.loading.value
                  ? SizedBox(
                      height: 160,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : products.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        children: [
                          Icon(
                            Icons.inbox,
                            size: 48,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'No products yet. Run the test to fetch data.',
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isDesktop
                            ? 4
                            : isTablet
                            ? 3
                            : 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final item = products[index];
                        return DynamicProductCard(
                          data: (item is Map<String, dynamic>)
                              ? item
                              : Map<String, dynamic>.from(item as Map),
                          onTap: () {
                            _showProductDetail(
                              Get.context!,
                              (item is Map<String, dynamic>)
                                  ? item
                                  : Map<String, dynamic>.from(item as Map),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    });
  }

  // Sample products removed - UI now uses `controller.apiProducts` populated from API

  void _showProductDetail(BuildContext context, Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: Color(0xFF8B0000)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                product['title'] ?? product['name'] ?? 'Product Detail',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('ID', product['id'] ?? '-'),
            _detailRow(
              'Category',
              product['category'] ?? product['subtitle'] ?? '-',
            ),
            _detailRow(
              'Price',
              product['price']?.toString() ??
                  product['harga']?.toString() ??
                  '-',
            ),
            _detailRow(
              'Stock',
              product['stock']?.toString() ??
                  product['quantity']?.toString() ??
                  '-',
            ),
            _detailRow(
              'Status',
              (product['stock'] ?? 0) > 20 ? 'Available' : 'Low Stock',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildResultsTable(ApifyController controller, bool isTablet) {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF8B0000), Color(0xFFD2691E)],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.table_chart, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    '📊 Hasil Pengujian Performa',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            if (controller.logs.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.inbox, size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text(
                      'Belum ada data pengujian',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Klik tombol di atas untuk memulai',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(
                    Colors.grey.shade50,
                  ),
                  columns: const [
                    DataColumn(
                      label: Text(
                        'Library',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Status',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Duration',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Bytes',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Result',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows: controller.logs.map((log) {
                    final isError = log['error'] != null;
                    final statusCode = log['status'];

                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            log['library'].toString(),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusCode == 200
                                  ? Colors.green.shade50
                                  : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              statusCode.toString(),
                              style: TextStyle(
                                color: statusCode == 200
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            log['duration'].toString(),
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                        ),
                        DataCell(
                          Text(
                            '${log['bytes']} bytes',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ),
                        DataCell(
                          Icon(
                            isError ? Icons.error : Icons.check_circle,
                            color: isError ? Colors.red : Colors.green,
                            size: 20,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            if (controller.loading.value)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.red.shade800,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Sedang melakukan pengujian...',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoFooter(bool isTablet) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade100, Colors.red.shade100],
        ),
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: Color(0xFF8B0000), width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: Colors.red.shade800),
              const SizedBox(width: 8),
              const Text(
                'ℹ️ Informasi Pengujian',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '• Menggunakan Apify API untuk testing performa',
            style: TextStyle(fontSize: 13),
          ),
          const Text(
            '• Pengukuran waktu menggunakan Stopwatch (console log)',
            style: TextStyle(fontSize: 13),
          ),
          const Text(
            '• Responsive design untuk semua device (mobile, tablet, desktop)',
            style: TextStyle(fontSize: 13),
          ),
          const Text(
            '• Error handling lengkap untuk HTTP & Dio',
            style: TextStyle(fontSize: 13),
          ),
          const Text(
            '• Dynamic widget untuk handle berbagai struktur API',
            style: TextStyle(fontSize: 13),
          ),
          const Text(
            '• Product catalog otomatis muncul setelah data berhasil diambil',
            style: TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _StatData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  _StatData(this.label, this.value, this.icon, this.color);
}
