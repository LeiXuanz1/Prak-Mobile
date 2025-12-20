import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../data/local/hive_models/stock_in_transaction.dart';
import '../../../data/local/hive_models/stock_out_transaction.dart';
import '../models/period_filter.dart';

class InventoryOverviewController extends GetxController {
  final selectedPeriod = Rx<PeriodFilter>(PeriodFilter.today);

  // Reactive variables untuk stats
  final Rx<int> totalStockIn = Rx<int>(0);
  final Rx<int> totalStockOut = Rx<int>(0);
  final Rx<double> totalOmset = Rx<double>(0);
  final Rx<double> totalProfit = Rx<double>(0);

  late Box<StockInTransaction> stockInBox;
  late Box<StockOutTransaction> stockOutBox;

  @override
  void onInit() {
    super.onInit();
    _initializeBoxes();
    _calculateStats();
    // Listen untuk perubahan period filter
    ever(selectedPeriod, (_) => _calculateStats());
  }

  void _initializeBoxes() {
    stockInBox = Hive.box<StockInTransaction>('stock_in_transactions');
    stockOutBox = Hive.box<StockOutTransaction>('stock_out_transactions');
  }

  void _calculateStats() {
    final now = DateTime.now();
    final startDate = _getStartDate(now);
    // Set endDate to tomorrow at 00:00:00 for proper inclusive date range
    final endDate = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 1));

    // Filter transaksi berdasarkan periode
    final filteredStockIn = stockInBox.values
        .where(
          (item) => item.date.isAfter(startDate) && item.date.isBefore(endDate),
        )
        .toList();

    final filteredStockOut = stockOutBox.values
        .where(
          (item) => item.date.isAfter(startDate) && item.date.isBefore(endDate),
        )
        .toList();

    // Hitung total stok masuk
    int inTotal = 0;
    for (var item in filteredStockIn) {
      inTotal += item.quantity;
    }

    // Hitung total stok keluar
    int outTotal = 0;
    double omsetTotal = 0;
    double profitTotal = 0;

    for (var item in filteredStockOut) {
      outTotal += item.quantity;
      omsetTotal += item.omset;
      profitTotal += item.profit;
    }

    totalStockIn.value = inTotal;
    totalStockOut.value = outTotal;
    totalOmset.value = omsetTotal;
    totalProfit.value = profitTotal;
  }

  DateTime _getStartDate(DateTime now) {
    switch (selectedPeriod.value) {
      case PeriodFilter.today:
        return DateTime(now.year, now.month, now.day);
      case PeriodFilter.sevenDays:
        return now.subtract(const Duration(days: 7));
      case PeriodFilter.monthly:
        return DateTime(now.year, now.month, 1);
    }
  }

  void changePeriod(PeriodFilter period) {
    selectedPeriod.value = period;
  }
}
