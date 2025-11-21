import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../modules/apify/controllers/apify_controller.dart';

class APITestingSection extends StatelessWidget {
  final ApifyController controller;
  const APITestingSection({super.key, required this.controller});

  Widget _apiButton(String label, IconData icon, Color color, bool isLoading, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isLoading ? color.withValues(alpha: 0.3) : color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (isLoading) SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(color))) else Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(isLoading ? 'Loading...' : label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 11)),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('API Testing', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          _apiButton('HTTP Request', Icons.api, Colors.blue, controller.loading.value && controller.testMode.value == 'async', () => controller.runComparisonAsync()),
          _apiButton('Dio Request', Icons.cloud_queue, Colors.green, controller.loading.value && controller.testMode.value == 'callback', () => controller.runComparisonCallback()),
          _apiButton('Clear Logs', Icons.delete_outline, Colors.red, false, () { controller.logs.clear(); Get.snackbar('Success', 'Logs cleared'); }),
        ]),
      ]),
    ));
  }
}
