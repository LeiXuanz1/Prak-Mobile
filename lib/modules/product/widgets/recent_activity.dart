import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../apify/controllers/apify_controller.dart';

class RecentActivitySection extends StatelessWidget {
  final ApifyController controller;
  const RecentActivitySection({super.key, required this.controller});

  Color _badgeColor(String type) {
    switch (type) {
      case 'added':
        return const Color(0xFF4CAF50);
      case 'alert':
        return const Color(0xFFFF9800);
      case 'reduced':
        return const Color(0xFFF44336);
      case 'updated':
        return const Color(0xFF2196F3);
      default:
        return Colors.grey;
    }
  }

  Widget _activityItem(Map<String, dynamic> activity) {
    final type = activity['type'] ?? 'updated';
    final title = activity['title'] ?? '';
    final description = activity['description'] ?? '';
    final badge = activity['badge'];
    final timeAgo = activity['timeAgo'] ?? '';
    IconData icon;
    Color iconColor;
    Color bgColor;

    switch (type) {
      case 'added':
        icon = Icons.add_circle;
        iconColor = const Color(0xFF4CAF50);
        bgColor = iconColor.withValues(alpha: 0.1);
        break;
      case 'alert':
        icon = Icons.warning_amber_rounded;
        iconColor = const Color(0xFFFF9800);
        bgColor = iconColor.withValues(alpha: 0.1);
        break;
      case 'reduced':
        icon = Icons.remove_circle;
        iconColor = const Color(0xFFF44336);
        bgColor = iconColor.withValues(alpha: 0.1);
        break;
      default:
        icon = Icons.edit;
        iconColor = const Color(0xFF2196F3);
        bgColor = iconColor.withValues(alpha: 0.1);
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: iconColor, size: 20)),
      title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const SizedBox(height: 4), Text(description, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)), const SizedBox(height: 4), Text(timeAgo, style: TextStyle(fontSize: 10, color: Colors.grey.shade500))]),
      trailing: badge != null ? Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: _badgeColor(type), borderRadius: BorderRadius.circular(12)), child: Text(badge, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white))) : null,
    );
  }

  void _showAllActivities(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, sc) => Column(
          children: [
            Container(margin: const EdgeInsets.symmetric(vertical: 12), width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('All Activities', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ])),
            const Divider(),
            Expanded(
              child: Obx(() {
                final all = controller.recentActivities;
                return ListView.separated(
                  controller: sc,
                  padding: const EdgeInsets.all(16),
                  itemCount: all.length,
                  separatorBuilder: (_, __) => Divider(color: Colors.grey.shade200),
                  itemBuilder: (context, index) => _activityItem(all[index]),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final activities = controller.recentActivities.take(5).toList();
      return Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))]),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Recent Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              TextButton(onPressed: () => _showAllActivities(context), child: const Text('View All', style: TextStyle(color: Color(0xFFFF6B00), fontSize: 12, fontWeight: FontWeight.w600))),
            ]),
          ),
          if (activities.isEmpty)
            Padding(padding: const EdgeInsets.symmetric(vertical: 40), child: Column(children: [Icon(Icons.history, size: 48, color: Colors.grey.shade300), const SizedBox(height: 12), Text('No recent activity', style: TextStyle(color: Colors.grey.shade500, fontSize: 13))]))
          else
            ListView.separated(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: activities.length, separatorBuilder: (_, __) => Divider(color: Colors.grey.shade200), itemBuilder: (context, i) => _activityItem(activities[i])),
          if (activities.length >= 5)
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextButton(
                onPressed: () => _showAllActivities(context),
                style: TextButton.styleFrom(minimumSize: const Size(double.infinity, 40)),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [Text('Load More Activities', style: TextStyle(color: Color(0xFFFF6B00), fontWeight: FontWeight.w600)), SizedBox(width: 4), Icon(Icons.arrow_forward, size: 16, color: Color(0xFFFF6B00))]),
              ),
            )
        ]),
      );
    });
  }
}
