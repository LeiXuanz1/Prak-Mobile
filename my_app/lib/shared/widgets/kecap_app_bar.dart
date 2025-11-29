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
      expandedHeight: 120,
      floating: false,
      pinned: true,

      // Warna mengikuti theme
      backgroundColor: theme.colorScheme.surface,

      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withValues(alpha: 0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        title: Text(
          'Kecap Store',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      actions: [
        Obx(() {
          return IconButton(
            icon: Icon(
              themeCtrl.isDark ? Icons.dark_mode : Icons.light_mode,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: themeCtrl.toggleTheme,
            tooltip: 'Toggle theme',
          );
        }),
        IconButton(
          icon: Icon(Icons.refresh, color: theme.colorScheme.onSurface),
          tooltip: 'Go to hive',
          onPressed: () => Get.toNamed('/hive-products'),
        ),
        IconButton(
          icon: Icon(Icons.storage_rounded, color: theme.colorScheme.onSurface),
          tooltip: 'Go to supabase',
          onPressed: () => Get.toNamed('/supabase-products'),
        ),
        IconButton(
          icon: Icon(Icons.location_on, color: theme.colorScheme.onSurface,),
          onPressed: () => Get.toNamed('/location'),
        ),
      ],
    );
  }
}