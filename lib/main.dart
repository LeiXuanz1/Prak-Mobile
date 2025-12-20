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

  ConnectivityService.listen(
    onOnline: () async {
      await ProductSyncService.sync();
    },
    onOffline: () {
      debugPrint('Offline mode');
    },
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<ThemeController>();
    final auth = Get.find<AuthController>();

    return Obx(() {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,

        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF1B5E20), // Material Green 900
          brightness: Brightness.light,
          scaffoldBackgroundColor: const Color(0xFFFAFDF7),

          // Proper M3 Input Decoration
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFFF1F5F2),
            border: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              borderSide: const BorderSide(color: Color(0xFF1B5E20), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),

          // AppBar styling
          appBarTheme: const AppBarTheme(
            elevation: 1,
            scrolledUnderElevation: 4,
            backgroundColor: Color(0xFFFAFDF7),
            foregroundColor: Color(0xFF1B5E20),
            centerTitle: false,
            titleTextStyle: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1B5E20),
            ),
          ),

          // Button styling for better contrast
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // FAB styling
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            elevation: 4,
          ),

          // Bottom Navigation styling
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF2E7D32),
            unselectedItemColor: Colors.grey.shade600,
            elevation: 8,
            type: BottomNavigationBarType.fixed,
          ),

          // Card styling
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
          ),
        ),

        darkTheme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(
            0xFF81C784,
          ), // Material Green 400 for dark
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF121212),

          appBarTheme: AppBarTheme(
            elevation: 1,
            backgroundColor: const Color(0xFF1F1F1F),
            foregroundColor: const Color(0xFF81C784),
          ),

          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
            ),
          ),
        ),

        themeMode: theme.themeMode,

        initialBinding: InitialBindings(),
        // Initial route based on auth status
        initialRoute: auth.isLoggedIn.value ? AppRoutes.home : AppRoutes.home,
        getPages: AppPages.routes,
      );
    });
  }
}
