import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/apify_controller.dart';

class ApifyView extends StatelessWidget {
  const ApifyView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ApifyController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Uji Performansi Apify API'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          if (controller.loading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton.icon(
                onPressed: controller.runComparison,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Jalankan Uji'),
              ),
              const SizedBox(height: 20),
              if (controller.lastStatus.isNotEmpty)
                Text('🔹 Status terakhir: ${controller.lastStatus.value}',
                    style: const TextStyle(fontSize: 16)),
              const Divider(),
              const Text('📊 Hasil Pengujian:', style: TextStyle(fontSize: 18)),
              Expanded(
                child: ListView.builder(
                  itemCount: controller.logs.length,
                  itemBuilder: (context, index) {
                    final log = controller.logs[index];
                    return Card(
                      child: ListTile(
                        title: Text('${log['library']} — ${log['duration']}'),
                        subtitle: Text(
                            'Status: ${log['status']} | Bytes: ${log['bytes']}'),
                        trailing: log['error'] != null
                            ? const Icon(Icons.error, color: Colors.red)
                            : const Icon(Icons.check, color: Colors.green),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
