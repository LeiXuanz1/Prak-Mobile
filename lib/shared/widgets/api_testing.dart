import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../modules/apify/controllers/apify_controller.dart';

class APITestingSection extends StatelessWidget {
  final ApifyController controller;
  const APITestingSection({super.key, required this.controller});

  Widget _apiButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isLoading,
    required VoidCallback onPressed,
    bool destructive = false,
  }) {
    final theme = Theme.of(context);

    return FilledButton.tonal(
      onPressed: isLoading ? null : onPressed,
      style: destructive
          ? FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.errorContainer,
              foregroundColor: theme.colorScheme.onErrorContainer,
            )
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(isLoading ? 'Loading…' : label),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(
      () => Card(
        elevation: 0,
        color: theme.colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'API Testing',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _apiButton(
                    context: context,
                    label: 'HTTP Request',
                    icon: Icons.api_outlined,
                    isLoading: controller.loading.value &&
                        controller.testMode.value == 'async',
                    onPressed: controller.runComparisonAsync,
                  ),
                  _apiButton(
                    context: context,
                    label: 'Dio Request',
                    icon: Icons.cloud_outlined,
                    isLoading: controller.loading.value &&
                        controller.testMode.value == 'callback',
                    onPressed: controller.runComparisonCallback,
                  ),
                  _apiButton(
                    context: context,
                    label: 'Clear Logs',
                    icon: Icons.delete_outline,
                    destructive: true,
                    isLoading: false,
                    onPressed: () {
                      controller.logs.clear();
                      Get.snackbar(
                        'Success',
                        'Logs cleared',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
