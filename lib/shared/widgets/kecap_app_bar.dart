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
                Get.toNamed('/location');
                break;
              case 5:
                controller.runComparisonAsync();
                break;
              case 6:
                await authCtrl.logout();
                Get.offAllNamed('/login');
                break;
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 1, child: Text('Hive Products')),
            PopupMenuItem(value: 2, child: Text('Supabase Products')),
            PopupMenuItem(value: 3, child: Text('API')),
            PopupMenuItem(value: 4, child: Text('Location')),
            PopupMenuItem(value: 5, child: Text('Refresh')),
            PopupMenuDivider(),
            PopupMenuItem(
              value: 6,
              child: Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ],
    );
  }
}
