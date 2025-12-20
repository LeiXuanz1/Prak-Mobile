import 'package:get/get.dart';
import 'package:my_app/core/bindings/location_binding.dart';
import 'package:my_app/modules/home/views/home_view.dart';
import 'package:my_app/modules/location/views/location_view.dart';
import 'package:my_app/routes/auth_middleware.dart';
import '/core/bindings/apify_bindings.dart';
import 'package:my_app/modules/apify/views/apify_page.dart';
import 'app_routes.dart';
import 'package:my_app/modules/product/views/supabase/supabase_product_page.dart';
import 'package:my_app/modules/product/views/hive/hive_product_page.dart';
import 'package:my_app/modules/auth/views/login_view.dart';
import 'package:my_app/modules/auth/views/register_view.dart';

class AppPages {
  static final routes = [
    GetPage(name: AppRoutes.login, page: () => LoginView()),
    GetPage(name: AppRoutes.register, page: () => RegisterView()),
    // Homepage accessible tanpa login
    GetPage(name: AppRoutes.home, page: () => HomeView()),
    GetPage(
      name: AppRoutes.apify,
      page: () => ApifyPage(),
      binding: ApifyBinding(),
      middlewares: [AuthMiddleware()],
    ),
    // Protected routes - require login
    GetPage(
      name: AppRoutes.supabaseProducts,
      page: () => SupabaseProductPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.hiveProducts,
      page: () => HiveProductPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.location,
      page: () => LocationView(),
      binding: LocationBinding(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
