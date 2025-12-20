import 'package:hive_flutter/hive_flutter.dart';
import 'hive_models/product_hive_model.dart';
import 'hive_models/stock_in_transaction.dart';
import 'hive_models/stock_out_transaction.dart';
import 'hive_models/contact_hive_model.dart';

class HiveBoxes {
  static const String productBox = 'product_box';
  static const String apiProductsBox = 'api_products';
  static const String recentActivitiesBox = 'recent_activities';
  static const String stockInTransactionsBox = 'stock_in_transactions';
  static const String stockOutTransactionsBox = 'stock_out_transactions';
  static const String contactBox = 'contact_box';

  static Future<void> init() async {
    Hive.registerAdapter(ProductHiveModelAdapter());
    Hive.registerAdapter(StockInTransactionAdapter());
    Hive.registerAdapter(StockOutTransactionAdapter());
    Hive.registerAdapter(ContactHiveModelAdapter());

    try {
      await Hive.deleteBoxFromDisk('product_box');
    } catch (e) {
      // Box doesn't exist yet
    }

    await Hive.openBox<ProductHiveModel>('product_box');
    await Hive.openBox('api_products');
    await Hive.openBox('recent_activities');
    await Hive.openBox<StockInTransaction>('stock_in_transactions');
    await Hive.openBox<StockOutTransaction>('stock_out_transactions');
    await Hive.openBox<ContactHiveModel>('contact_box');
  }

  static Box<ProductHiveModel> get products =>
      Hive.box<ProductHiveModel>('product_box');
  static Box get apiProducts => Hive.box('api_products');
  static Box get recentActivities => Hive.box('recent_activities');
  static Box<StockInTransaction> get stockInTransactions =>
      Hive.box<StockInTransaction>('stock_in_transactions');
  static Box<StockOutTransaction> get stockOutTransactions =>
      Hive.box<StockOutTransaction>('stock_out_transactions');
  static Box<ContactHiveModel> get contacts =>
      Hive.box<ContactHiveModel>('contact_box');
}
