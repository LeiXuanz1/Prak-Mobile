import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../modules/apify/controllers/apify_controller.dart';
import '../../core/services/theme_controller.dart';

class KecapAppBar extends StatelessWidget {
  final ApifyController controller;
  const KecapAppBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeCtrl = Get.find<ThemeController>();

    return SliverAppBar(
      expandedHeight: 90,
      floating: false,
      pinned: true,
      elevation: 2,

      // Use a compact, contrasting background
      backgroundColor: theme.colorScheme.primary,

      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withOpacity(0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const SizedBox(width: 4),
                Text(
                  'Kecap Store',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),

            // Right side: theme toggle + overflow menu to avoid crowding
            Row(
              children: [
                Obx(() {
                  return IconButton(
                    icon: Icon(
                      themeCtrl.isDark ? Icons.dark_mode : Icons.light_mode,
                      color: theme.colorScheme.onPrimary,
                    ),
                    onPressed: themeCtrl.toggleTheme,
                    tooltip: 'Toggle theme',
                  );
                }),

                PopupMenuButton<int>(
                  color: theme.colorScheme.surface,
                  icon: Icon(
                    Icons.more_vert,
                    color: theme.colorScheme.onPrimary,
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case 1:
                        Get.toNamed('/hive-products');
                        break;
                      case 2:
                        Get.toNamed('/supabase-products');
                        break;
                      case 3:
                        Get.toNamed('/location');
                        break;
                      case 4:
                        // refresh current page by calling controller
                        controller.runComparisonAsync();
                        break;
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 1, child: Text('Hive Products')),
                    const PopupMenuItem(
                      value: 2,
                      child: Text('Supabase Products'),
                    ),
                    const PopupMenuItem(value: 3, child: Text('Location')),
                    const PopupMenuItem(value: 4, child: Text('Refresh')),
                  ],
                ),
              ],
            ),
          ],
        ),
        centerTitle: false,
      ),
    );
  }
}
