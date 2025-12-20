import 'package:get/get.dart';
import '../../../../data/local/hive_boxes.dart';

class StockReportData {
  final String productId;
  final String productName;
  final int totalStockIn;
  final int totalStockOut;
  final int finalStock;
  final double totalOmset;
  final double totalProfit;

  StockReportData({
    required this.productId,
    required this.productName,
    required this.totalStockIn,
    required this.totalStockOut,
    required this.finalStock,
    required this.totalOmset,
    required this.totalProfit,
  });
}

class StockReportController extends GetxController {
  final selectedStartDate = Rx<DateTime?>(null);
  final selectedEndDate = Rx<DateTime?>(null);
  final reportData = <StockReportData>[].obs;
  final isLoading = false.obs;

  // Summary data
  final Rx<int> totalStockInAll = Rx<int>(0);
  final Rx<int> totalStockOutAll = Rx<int>(0);
  final Rx<double> totalOmsetAll = Rx<double>(0);
  final Rx<double> totalProfitAll = Rx<double>(0);

  @override
  void onInit() {
    super.onInit();
    // Set default date range (current month)
    final now = DateTime.now();
    selectedStartDate.value = DateTime(now.year, now.month, 1);
    selectedEndDate.value = now;
    _generateReport();
  }

  void setStartDate(DateTime date) {
    selectedStartDate.value = date;
    _generateReport();
  }

  void setEndDate(DateTime date) {
    selectedEndDate.value = date;
    _generateReport();
  }

  void _generateReport() {
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

      // Generate report for each product
      List<StockReportData> report = [];
      int totalInAll = 0;
      int totalOutAll = 0;
      double totalOmsetAllValue = 0;
      double totalProfitAllValue = 0;

      for (var product in products) {
        // Calculate stock in for this product
        int totalIn = stockInList
            .where((t) => t.productId == product.id)
            .fold(0, (sum, t) => sum + t.quantity);

        // Calculate stock out for this product
        int totalOut = stockOutList
            .where((t) => t.productId == product.id)
            .fold(0, (sum, t) => sum + t.quantity);

        // Calculate omset and profit for this product
        double omset = stockOutList
            .where((t) => t.productId == product.id)
            .fold(0, (sum, t) => sum + t.omset);

        double profit = stockOutList
            .where((t) => t.productId == product.id)
            .fold(0, (sum, t) => sum + t.profit);

        // Final stock = current stock (already reflects all transactions)
        int finalStock = product.stock;

        if (totalIn > 0 || totalOut > 0) {
          report.add(
            StockReportData(
              productId: product.id,
              productName: product.title,
              totalStockIn: totalIn,
              totalStockOut: totalOut,
              finalStock: finalStock,
              totalOmset: omset,
              totalProfit: profit,
            ),
          );

          totalInAll += totalIn;
          totalOutAll += totalOut;
          totalOmsetAllValue += omset;
          totalProfitAllValue += profit;
        }
      }

      reportData.value = report;
      totalStockInAll.value = totalInAll;
      totalStockOutAll.value = totalOutAll;
      totalOmsetAll.value = totalOmsetAllValue;
      totalProfitAll.value = totalProfitAllValue;

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Gagal generate report: $e');
    }
  }
}
