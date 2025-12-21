import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_app/core/services/app_lifecycle_service.dart';
import 'package:my_app/core/services/connectvity_service.dart';
import 'package:my_app/data/sync/product_sync_service.dart';
import 'package:my_app/modules/auth/controllers/auth_controller.dart';
import 'package:my_app/routes/app_pages.dart';
import 'package:my_app/routes/app_routes.dart';
import 'core/bindings/initial_bindings.dart';
import 'core/services/theme_controller.dart';
import 'data/local/hive_boxes.dart';
import 'data/cloud/supabase_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final lifecycle = AppLifecycleService();
  WidgetsBinding.instance.addObserver(lifecycle);

  await dotenv.load(fileName: ".env");
  await Hive.initFlutter();
  await HiveBoxes.init();
  await SupabaseService.init();
  await NotificationService.init();

  Get.put(AuthController(), permanent: true);
  Get.put(ThemeController(), permanent: true);

  await Future.delayed(const Duration(milliseconds: 300));
  await ProductSyncService.sync();

  ConnectivityService.listen(
    onOnline: () async {
      await ProductSyncService.sync();
    },
    onOffline: () {
      print('Offline mode');
    },
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Get.find<ThemeController>();

    return Obx(() {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,

        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF2E7D32),
          scaffoldBackgroundColor: const Color(0xFFF9FAF9),

          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: Color(0xFFF1F5F2),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF2E7D32),
          brightness: Brightness.dark,
        ),
        themeMode: theme.themeMode,

        initialBinding: InitialBindings(),
        initialRoute: AppRoutes.login,
        getPages: AppPages.routes,
      );
    });
  }
}
