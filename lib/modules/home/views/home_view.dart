import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/modules/apify/controllers/apify_controller.dart';

// widgets
import '../../../shared/widgets/kecap_app_bar.dart';
import '../../../shared/widgets/welcome_card.dart';
import '../../product/widgets/dashboard_stats.dart';
import '../../../shared/widgets/quick_actions.dart';
import '../../product/widgets/recent_activity.dart';

class HomeView extends StatelessWidget {
  final ApifyController controller = Get.find<ApifyController>();

  HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          KecapAppBar(controller: controller),

          // CONTENT
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // WELCOME
                WelcomeCard(),
                const SizedBox(height: 16),

                // INVENTORY OVERVIEW
                _SectionTitle('Inventory Overview'),
                const SizedBox(height: 12),
                DashboardStats(controller: controller),

                const SizedBox(height: 24),

                // QUICK ACTIONS
                _SectionTitle('Quick Actions'),
                const SizedBox(height: 12),
                QuickActions(controller: controller),

                const SizedBox(height: 24),

                // RECENT ACTIVITY
                _SectionTitle('Recent Activity'),
                const SizedBox(height: 12),
                RecentActivitySection(controller: controller),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}
