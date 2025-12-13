import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/apify_controller.dart';

// widgets
import '../../../shared/widgets/kecap_app_bar.dart';
import '../../../shared/widgets/welcome_card.dart';
import '../../product/widgets/dashboard_stats.dart';
import '../../../shared/widgets/quick_actions.dart';
import '../../product/widgets/recent_activity.dart';
import '../../../shared/widgets/api_testing.dart';
import '../../product/views/product_catalog.dart';

class ApifyView extends StatelessWidget {
  final VoidCallback? onThemeChange;
  final ApifyController controller = Get.put(
    ApifyController(),
    permanent: true,
  );

  ApifyView({super.key, this.onThemeChange});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: null, // we use SliverAppBar inside body
      body: CustomScrollView(
        slivers: [
          KecapAppBar(controller: controller),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WelcomeCard(),
                  const SizedBox(height: 16),
                  Text(
                    'Inventory Overview',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DashboardStats(controller: controller),
                  const SizedBox(height: 20),
                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  QuickActions(controller: controller),
                  const SizedBox(height: 20),
                  RecentActivitySection(controller: controller),
                  const SizedBox(height: 20),
                  APITestingSection(controller: controller),
                  const SizedBox(height: 20),
                  ProductCatalogSection(controller: controller),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
