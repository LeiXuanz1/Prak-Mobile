import 'package:hive/hive.dart';
import 'hive_models/product_hive_model.dart';

class HiveBoxes {
  static const String productBox = 'product_box';

  static Future<void> init() async {
    Hive.registerAdapter(ProductHiveModelAdapter());
    await Hive.openBox<ProductHiveModel>(productBox);
  }

  static Box<ProductHiveModel> get products =>
      Hive.box<ProductHiveModel>(productBox);
}
