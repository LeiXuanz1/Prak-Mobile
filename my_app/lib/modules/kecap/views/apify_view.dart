import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/apify_controller.dart';
import 'package:url_launcher/url_launcher.dart';

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
                Text(
                  '🔹 Status terakhir: ${controller.lastStatus.value}',
                  style: const TextStyle(fontSize: 16),
                ),

              const Divider(),
              const Text(
                '📊 Hasil Pengujian:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              const Text(
                '🧂 Daftar Produk Soy Sauce:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              // === Daftar produk soy sauce ===
              Flexible(
                flex: 1,
                child: Obx(() {
                  final sauces = controller.soySauces;
                  if (sauces.isEmpty) {
                    return const Center(
                        child: Text('Belum ada data soy sauce'));
                  }
                  return ListView.builder(
                    itemCount: sauces.length,
                    itemBuilder: (context, index) {
                      final sauce = sauces[index];
                      return Card(
                        child: ListTile(
                          leading: Image.network(
                            sauce.imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          title: Text(sauce.name),
                          subtitle: Text('€${sauce.price.toStringAsFixed(2)}'),
                          onTap: () async {
                            final uri = Uri.parse(sauce.link);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri,
                                  mode: LaunchMode.externalApplication);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Tidak bisa membuka link produk')),
                              );
                            }
                          },
                        ),
                      );
                    },
                  );
                }),
              ),

              const SizedBox(height: 12),
              const Text(
                '🧮 Log Pengujian HTTP vs DIO:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              // === Log hasil uji performa ===
              Flexible(
                flex: 1,
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
