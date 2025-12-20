import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../../data/local/hive_boxes.dart';
import '../../../../data/local/hive_models/stock_out_transaction.dart';
import '../../../../data/local/hive_models/product_hive_model.dart';
import '../../../../data/local/hive_models/contact_hive_model.dart';

class StockOutController extends GetxController {
  // Form state
  final selectedProduct = Rx<ProductHiveModel?>(null);
  final selectedContact = Rx<ContactHiveModel?>(null);
  final quantityController = TextEditingController();
  final sellPriceController = TextEditingController();
  final selectedDate = Rx<DateTime?>(null);

  // Loading state
  final isLoading = false.obs;
  final errorMessage = Rx<String?>(null);
  final successMessage = Rx<String?>(null);

  // Calculation state
  final omset = Rx<double>(0.0);
  final profit = Rx<double>(0.0);

  // Product list from Hive
  final productList = <ProductHiveModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadProducts();
    quantityController.addListener(_calculateOmsetAndProfit);
    sellPriceController.addListener(_calculateOmsetAndProfit);
  }

  @override
  void onClose() {
    quantityController.dispose();
    sellPriceController.dispose();
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

  void _calculateOmsetAndProfit() {
    if (selectedProduct.value == null) return;

    int quantity = int.tryParse(quantityController.text) ?? 0;
    double sellPrice = double.tryParse(sellPriceController.text) ?? 0.0;

    if (quantity > 0 && sellPrice > 0) {
      final buyPrice = selectedProduct.value!.price;
      final omsetValue = quantity * sellPrice;
      final profitValue = omsetValue - (quantity * buyPrice);

      omset.value = omsetValue;
      profit.value = profitValue;
    } else {
      omset.value = 0.0;
      profit.value = 0.0;
    }
  }

  Future<void> saveStockOut() async {
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

      if (sellPriceController.text.isEmpty) {
        errorMessage.value = 'Masukkan harga jual per unit';
        return;
      }

      if (selectedDate.value == null) {
        errorMessage.value = 'Pilih tanggal transaksi';
        return;
      }

      int quantity = int.tryParse(quantityController.text) ?? 0;
      double sellPrice = double.tryParse(sellPriceController.text) ?? 0.0;

      if (quantity <= 0) {
        errorMessage.value = 'Jumlah barang harus lebih dari 0';
        return;
      }

      if (sellPrice <= 0) {
        errorMessage.value = 'Harga jual harus lebih dari 0';
        return;
      }

      final product = selectedProduct.value!;

      // Validasi stok
      if (product.stock < quantity) {
        errorMessage.value =
            'Stok tidak cukup! Stok tersedia: ${product.stock}';
        return;
      }

      isLoading.value = true;
      errorMessage.value = null;

      final stockBefore = product.stock;
      final stockAfter = stockBefore - quantity;
      final buyPrice = product.price;
      final omsetValue = quantity * sellPrice;
      final profitValue = omsetValue - (quantity * buyPrice);

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

      final transaction = StockOutTransaction(
        id: const Uuid().v4(),
        productId: product.id,
        productName: product.title,
        quantity: quantity,
        sellPrice: sellPrice,
        buyPrice: buyPrice,
        omset: omsetValue,
        profit: profitValue,
        date: dateWithTime,
        stockBefore: stockBefore,
        stockAfter: stockAfter,
        category: product.category,
        contactName: selectedContact.value?.name,
      );

      // Save transaction to Hive
      await HiveBoxes.stockOutTransactions.add(transaction);

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
          'Stok keluar berhasil disimpan!\n${product.title} (-$quantity)';

      // Clear message after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        successMessage.value = null;
      });

      isLoading.value = false;
    } catch (e) {
      errorMessage.value = 'Error: $e';
      isLoading.value = false;
    }
  }

  void _resetForm() {
    selectedProduct.value = null;
    selectedContact.value = null;
    quantityController.clear();
    sellPriceController.clear();
    selectedDate.value = null;
    omset.value = 0.0;
    profit.value = 0.0;
  }

  void setSelectedDate(DateTime date) {
    selectedDate.value = date;
  }

  void selectProduct(ProductHiveModel product) {
    selectedProduct.value = product;
    _calculateOmsetAndProfit();
  }

  void selectContact(ContactHiveModel? contact) {
    selectedContact.value = contact;
  }
}
