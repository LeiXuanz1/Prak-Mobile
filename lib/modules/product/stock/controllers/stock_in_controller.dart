import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../../data/local/hive_boxes.dart';
import '../../../../data/local/hive_models/stock_in_transaction.dart';
import '../../../../data/local/hive_models/product_hive_model.dart';
import '../../controllers/recent_activity_controller.dart';

class StockInController extends GetxController {
  // Form state
  final selectedProduct = Rx<ProductHiveModel?>(null);
  final quantityController = TextEditingController();
  final selectedDate = Rx<DateTime?>(null);

  // Loading state
  final isLoading = false.obs;
  final errorMessage = Rx<String?>(null);
  final successMessage = Rx<String?>(null);

  // Product list from Hive
  final productList = <ProductHiveModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadProducts();
  }

  @override
  void onClose() {
    quantityController.dispose();
    super.onClose();
  }

  void _loadProducts() {
    try {
      final products = HiveBoxes.products.values.toList();
      productList.value = products;
    } catch (e) {
      errorMessage.value = 'Gagal memuat produk: $e';
    }
  }

  Future<void> saveStockIn() async {
    try {
      // Validasi
      if (selectedProduct.value == null) {
        errorMessage.value = 'Pilih produk terlebih dahulu';
        return;
      }

      if (quantityController.text.isEmpty) {
        errorMessage.value = 'Masukkan jumlah barang';
        return;
      }

      if (selectedDate.value == null) {
        errorMessage.value = 'Pilih tanggal transaksi';
        return;
      }

      int quantity = int.tryParse(quantityController.text) ?? 0;
      if (quantity <= 0) {
        errorMessage.value = 'Jumlah barang harus lebih dari 0';
        return;
      }

      isLoading.value = true;
      errorMessage.value = null;

      final product = selectedProduct.value!;
      final stockBefore = product.stock;
      final stockAfter = stockBefore + quantity;

      // Create transaction
      // Combine selected date with current time
      final now = DateTime.now();
      final dateWithTime = DateTime(
        selectedDate.value!.year,
        selectedDate.value!.month,
        selectedDate.value!.day,
        now.hour,
        now.minute,
        now.second,
      );

      final transaction = StockInTransaction(
        id: const Uuid().v4(),
        productId: product.id,
        productName: product.title,
        quantity: quantity,
        date: dateWithTime,
        stockBefore: stockBefore,
        stockAfter: stockAfter,
        category: product.category,
      );

      // Save transaction to Hive
      await HiveBoxes.stockInTransactions.add(transaction);

      // Update product stock
      final updatedProduct = ProductHiveModel(
        id: product.id,
        title: product.title,
        category: product.category,
        stock: stockAfter,
        unit: product.unit,
        price: product.price,
        description: product.description,
        thumbnail: product.thumbnail,
        packaging: product.packaging,
        source: product.source,
        status: product.status,
        updatedAt: DateTime.now(),
        isSynced: false,
        isDeleted: false,
      );

      final productIndex = HiveBoxes.products.values.toList().indexWhere(
        (p) => p.id == product.id,
      );
      if (productIndex != -1) {
        await HiveBoxes.products.putAt(productIndex, updatedProduct);
      }

      // Reset form
      _resetForm();
      successMessage.value =
          'Stok masuk berhasil disimpan!\n${product.title} (+$quantity)';

      isLoading.value = false;

      // Refresh recent activity
      try {
        final recentActivityController = Get.find<RecentActivityController>();
        recentActivityController.refreshTransactions();
      } catch (_) {}

      // Pop after showing success message
      Future.delayed(const Duration(milliseconds: 500), () {
        Get.back();
      });
    } catch (e) {
      errorMessage.value = 'Error: $e';
      isLoading.value = false;
    }
  }

  void _resetForm() {
    selectedProduct.value = null;
    quantityController.clear();
    selectedDate.value = null;
  }

  void setSelectedDate(DateTime date) {
    selectedDate.value = date;
  }

  void selectProduct(ProductHiveModel product) {
    selectedProduct.value = product;
  }
}
