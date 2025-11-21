import 'package:get/get.dart';
import '/core/bindings/apify_bindings.dart';
import '../modules/apify/views/apify_view.dart';
import 'app_routes.dart';
import '../modules/product/views/supabase/supabase_product_page.dart';
import '../modules/product/views/hive/hive_product_page.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.apify,
      page: () => ApifyView(),
      binding: ApifyBinding(),
    ),
    GetPage(
      name: AppRoutes.supabaseProducts,
      page: () => SupabaseProductPage(),
    ),
    GetPage(
      name: AppRoutes.hiveProducts,
      page: () => HiveProductPage(),
    ),
  ];
}