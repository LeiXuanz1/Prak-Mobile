import 'package:get/get.dart';
import '/app/bindings/apify_binding.dart';
import '/modules/kecap/views/apify_view.dart';
import 'app_routes.dart';
import '/modules/kecap/views/supabase_product_page.dart';

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
      binding: ApifyBinding(),   // gunakan binding yg sama
    ),
  ];
}