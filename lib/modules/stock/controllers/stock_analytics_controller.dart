import 'package:get/get.dart';
import '../../../data/local/hive_boxes.dart';

class ChartDataPoint {
  final String label;
  final double value;

  ChartDataPoint({required this.label, required this.value});
}

class StockAnalyticsController extends GetxController {
  final selectedStartDate = Rx<DateTime?>(null);
  final selectedEndDate = Rx<DateTime?>(null);
  final isLoading = false.obs;

  // Chart data
  final stockMovementData = <ChartDataPoint>[].obs;
  final inOutComparisonData = <MapEntry<String, int>>[].obs;
  final topProductsData = <MapEntry<String, int>>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Set default date range (current month)
    final now = DateTime.now();
    selectedStartDate.value = DateTime(now.year, now.month, 1);
    selectedEndDate.value = now;
    _generateAnalytics();
  }

  void setStartDate(DateTime date) {
    selectedStartDate.value = date;
    _generateAnalytics();
  }

  void setEndDate(DateTime date) {
    selectedEndDate.value = date;
    _generateAnalytics();
  }

  void _generateAnalytics() {
    if (selectedStartDate.value == null || selectedEndDate.value == null) {
      return;
    }

    isLoading.value = true;

    try {
      final startDate = selectedStartDate.value!;
      final endDate = selectedEndDate.value!;

      // Get all products
      final products = HiveBoxes.products.values.toList();

      // Get all transactions
      final stockInList = HiveBoxes.stockInTransactions.values
          .where(
            (t) =>
                t.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
                t.date.isBefore(endDate.add(const Duration(days: 1))),
          )
          .toList();

      final stockOutList = HiveBoxes.stockOutTransactions.values
          .where(
            (t) =>
                t.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
                t.date.isBefore(endDate.add(const Duration(days: 1))),
          )
          .toList();

      // 1. Stock Movement Chart (line chart data)
      List<ChartDataPoint> movementData = [];
      for (var product in products) {
        int totalIn = stockInList
            .where((t) => t.productId == product.id)
            .fold(0, (sum, t) => sum + t.quantity);

        int totalOut = stockOutList
            .where((t) => t.productId == product.id)
            .fold(0, (sum, t) => sum + t.quantity);

        int netMovement = totalIn - totalOut;
        if (product.stock > 0 || netMovement != 0) {
          movementData.add(
            ChartDataPoint(
              label: product.title.length > 10
                  ? '${product.title.substring(0, 10)}...'
                  : product.title,
              value: product.stock.toDouble(),
            ),
          );
        }
      }
      stockMovementData.value = movementData;

      // 2. In vs Out Comparison Chart (bar chart data)
      List<MapEntry<String, int>> inOutData = [];
      int totalIn = 0;
      int totalOut = 0;

      for (var product in products) {
        int pIn = stockInList
            .where((t) => t.productId == product.id)
            .fold(0, (sum, t) => sum + t.quantity);
        int pOut = stockOutList
            .where((t) => t.productId == product.id)
            .fold(0, (sum, t) => sum + t.quantity);

        totalIn += pIn;
        totalOut += pOut;
      }

      inOutData.add(MapEntry('Masuk', totalIn));
      inOutData.add(MapEntry('Keluar', totalOut));
      inOutComparisonData.value = inOutData;

      // 3. Top Products by Transaction (bar chart data)
      Map<String, int> productTransactionCount = {};

      for (var stockIn in stockInList) {
        productTransactionCount[stockIn.productName] =
            (productTransactionCount[stockIn.productName] ?? 0) + 1;
      }

      for (var stockOut in stockOutList) {
        productTransactionCount[stockOut.productName] =
            (productTransactionCount[stockOut.productName] ?? 0) + 1;
      }

      // Sort dan ambil top 5
      final sortedProducts = productTransactionCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      topProductsData.value = sortedProducts.take(5).toList();

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Gagal generate analytics: $e');
    }
  }
}
