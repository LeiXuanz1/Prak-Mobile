import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'modules/kecap/controllers/theme_controller.dart';
import 'modules/kecap/services/supabase_service.dart';
import '/routes/app_pages.dart';
import '/routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await SupabaseService.init();

  Get.put(ThemeController(), permanent: true);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Get.find<ThemeController>();

    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: theme.isDark.value ? ThemeMode.dark : ThemeMode.light,

        initialRoute: AppRoutes.apify,
        getPages: AppPages.routes,
      ),
    );
  }
}
