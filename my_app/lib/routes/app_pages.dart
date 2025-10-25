import 'package:get/get.dart';
import '/app/bindings/apify_binding.dart';
import '/modules/kecap/views/apify_view.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.apify,
      page: () => const ApifyView(),
      binding: ApifyBinding(),
    ),
  ];
}
