import 'package:get/get.dart';
import '../../../data/local/hive_boxes.dart';
import '../../../data/local/models/stock_in_transaction.dart';
import '../../../data/local/models/stock_out_transaction.dart';

class RecentActivityController extends GetxController {
  final selectedTab = Rx<int>(0); // 0: All, 1: Stok Masuk, 2: Stok Keluar

  final allTransactions = Rx<List<dynamic>>([]);
  final stockInTransactions = Rx<List<StockInTransaction>>([]);
  final stockOutTransactions = Rx<List<StockOutTransaction>>([]);

  @override
  void onInit() {
    super.onInit();
    _loadTransactions();
    ever(selectedTab, (_) {});
  }

  void _loadTransactions() {
    try {
      // Load from Hive boxes
      final stockInList = HiveBoxes.stockInTransactions.values.toList();
      final stockOutList = HiveBoxes.stockOutTransactions.values.toList();

      stockInTransactions.value = stockInList;
      stockOutTransactions.value = stockOutList;

      // Combine and sort by date (newest first)
      final combined = <dynamic>[];
      combined.addAll(stockInList);
      combined.addAll(stockOutList);
      combined.sort((a, b) => b.date.compareTo(a.date));

      allTransactions.value = combined;
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat aktivitas: $e');
    }
  }

  List<dynamic> getDisplayedTransactions() {
    switch (selectedTab.value) {
      case 1:
        return stockInTransactions.value;
      case 2:
        return stockOutTransactions.value;
      default:
        return allTransactions.value;
    }
  }

  void refreshTransactions() {
    _loadTransactions();
  }
}
