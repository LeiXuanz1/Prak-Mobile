import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/apify_controller.dart';

// widgets
import '../../../shared/widgets/kecap_app_bar.dart';
import '../../../shared/widgets/api_testing.dart';
import '../../product/views/product_catalog.dart';

class ApifyPage extends StatelessWidget {
  final ApifyController controller = Get.find<ApifyController>();

  ApifyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          KecapAppBar(controller: controller),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  _SectionTitle(
                    title: 'API Testing',
                    textTheme: textTheme,
                  ),
                  const SizedBox(height: 12),
                  APITestingSection(controller: controller),

                  const SizedBox(height: 24),
                  const SizedBox(height: 12),
                  ProductCatalogSection(controller: controller),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final TextTheme textTheme;

  const _SectionTitle({
    required this.title,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
