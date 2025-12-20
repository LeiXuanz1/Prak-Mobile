import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../modules/apify/controllers/apify_controller.dart';

class APITestingSection extends StatelessWidget {
  final ApifyController controller;

  const APITestingSection({
    super.key,
    required this.controller,
  });

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
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
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

          /// 🔥 FIX OVERFLOW
          Flexible(
            child: Text(
              isLoading ? 'Loading…' : label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
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
              Row(
                children: [
                  Expanded(
                    child: _apiButton(
                      context: context,
                      label: 'HTTP Request',
                      icon: Icons.api_outlined,
                      isLoading: controller.loading.value &&
                          controller.testMode.value == 'async',
                      onPressed: controller.runComparisonAsync,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _apiButton(
                      context: context,
                      label: 'Dio Request',
                      icon: Icons.cloud_outlined,
                      isLoading: controller.loading.value &&
                          controller.testMode.value == 'callback',
                      onPressed: controller.runComparisonCallback,
                    ),
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
