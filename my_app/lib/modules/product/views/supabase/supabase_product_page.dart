import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/supabase_product_controller.dart';

class SupabaseProductPage extends StatelessWidget {
  // Controller di-init sekali
  final controller = Get.find<SupabaseProductController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Supabase Products"),
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.products.isEmpty) {
          return const Center(child: Text("Tidak ada data Supabase"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: controller.products.length,
          itemBuilder: (context, index) {
            final item = controller.products[index];
            print(item);

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),

                leading: item["thumbnail"] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item["thumbnail"],
                          width: 55,
                          height: 55,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(Icons.image_not_supported, size: 40),

                title: Text(
                  item["display_name"] ?? "Tanpa nama",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text("Kategori: ${item["category"] ?? "-"}"),
                    Text("Kemasan: ${item["packaging"] ?? "-"}"),
                    Text("Harga: ${item["price"] ?? "-"}"),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
