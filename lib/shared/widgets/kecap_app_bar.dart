import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/modules/auth/controllers/auth_controller.dart';
import '../../modules/apify/controllers/apify_controller.dart';
import '../../core/services/theme_controller.dart';

class KecapAppBar extends StatelessWidget {
  final ApifyController controller;
  const KecapAppBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeCtrl = Get.find<ThemeController>();
    final authCtrl = Get.find<AuthController>();

    return SliverAppBar(
      pinned: true,
      floating: false,
      expandedHeight: 72,
      backgroundColor: theme.colorScheme.surface,
      surfaceTintColor: theme.colorScheme.surfaceTint,
      elevation: 0,

      title: const Text('Manajemen Stok Kecap'),

      actions: [
        // THEME TOGGLE
        Obx(
          () => IconButton(
            tooltip: 'Ganti tema',
            icon: Icon(
              themeCtrl.isDark
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
            ),
            onPressed: themeCtrl.toggleTheme,
          ),
        ),

        // OVERFLOW MENU
        PopupMenuButton<int>(
          tooltip: 'Menu',
          onSelected: (value) async {
            switch (value) {
              case 1:
                Get.toNamed('/hive-products');
                break;
              case 2:
                Get.toNamed('/supabase-products');
                break;
              case 3:
                Get.toNamed('/apify');
                break;
              case 4:
                controller.runComparisonAsync();
                break;
              case 5:
                if (authCtrl.isLoggedIn.value) {
                  await authCtrl.logout();
                  Get.offAllNamed('/login');
                } else {
                  Get.toNamed('/login');
                }
                break;
            }
          },
          itemBuilder: (context) {
            return <PopupMenuEntry<int>>[
              const PopupMenuItem(value: 1, child: Text('Hive Products')),
              const PopupMenuItem(value: 2, child: Text('Supabase Products')),
              const PopupMenuItem(value: 3, child: Text('API')),
              const PopupMenuItem(value: 4, child: Text('Refresh')),
              const PopupMenuDivider(),
              PopupMenuItem<int>(
                value: 5,
                child: Obx(
                  () => authCtrl.isLoggedIn.value
                      ? const Text(
                          'Logout',
                          style: TextStyle(color: Colors.red),
                        )
                      : const Text('Login'),
                ),
              ),
            ];
          },
        ),
      ],
    );
  }
}
