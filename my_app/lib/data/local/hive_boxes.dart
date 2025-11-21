import 'package:hive_flutter/hive_flutter.dart';
import 'hive_models/product_hive_model.dart';

class HiveBoxes {
  static const String productBox = 'product_box';
  static const String apiProductsBox = 'api_products';
  static const String recentActivitiesBox = 'recent_activities';

  static Future<void> init() async {
    Hive.registerAdapter(ProductHiveModelAdapter());

    await Hive.openBox<ProductHiveModel>(productBox);
    await Hive.openBox(apiProductsBox);
    await Hive.openBox(recentActivitiesBox);
  }

  static Box<ProductHiveModel> get products => Hive.box<ProductHiveModel>(productBox);
  static Box get apiProducts => Hive.box(apiProductsBox);
  static Box get recentActivities => Hive.box(recentActivitiesBox);
}
