import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/bindings/initial_bindings.dart';
import 'core/services/theme_controller.dart';
import '/routes/app_pages.dart';
import '/routes/app_routes.dart';
import 'data/local/hive_boxes.dart';
import 'data/cloud/supabase_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await dotenv.load(fileName: ".env");
  await Hive.initFlutter();
  await HiveBoxes.init();
  await SupabaseService.init();
  await NotificationService.init();

  Get.put(ThemeController(), permanent: true);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Get.find<ThemeController>();

    return Obx(() {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,

        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: theme.themeMode,

        initialBinding: InitialBindings(),
        initialRoute: AppRoutes.apify,
        getPages: AppPages.routes,
      );
    });
  }
}
