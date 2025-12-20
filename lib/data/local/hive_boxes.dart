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

    await Hive.openBox<ProductHiveModel>(productBox);
    await Hive.openBox(apiProductsBox);
    await Hive.openBox(recentActivitiesBox);
    await Hive.openBox<StockInTransaction>(stockInTransactionsBox);
    await Hive.openBox<StockOutTransaction>(stockOutTransactionsBox);
    await Hive.openBox<ContactHiveModel>(contactBox);
  }

  static Box<ProductHiveModel> get products =>
      Hive.box<ProductHiveModel>(productBox);
  static Box get apiProducts => Hive.box(apiProductsBox);
  static Box get recentActivities => Hive.box(recentActivitiesBox);
  static Box<StockInTransaction> get stockInTransactions =>
      Hive.box<StockInTransaction>(stockInTransactionsBox);
  static Box<StockOutTransaction> get stockOutTransactions =>
      Hive.box<StockOutTransaction>(stockOutTransactionsBox);
  static Box<ContactHiveModel> get contacts =>
      Hive.box<ContactHiveModel>(contactBox);
}
