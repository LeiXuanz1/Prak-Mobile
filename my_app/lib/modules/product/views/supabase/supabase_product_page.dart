import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/supabase_product_controller.dart';
import '../../../../data/cloud/supabase_service.dart';
import 'supabase_add_view.dart';

class SupabaseProductPage extends StatelessWidget {
  // Controller di-init sekali
  final controller = Get.find<SupabaseProductController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Supabase Products")),

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

                leading: Builder(
                  builder: (ctx) {
                    final thumbRaw = item["thumbnail"];

                    String? imageUrl;

                    // sanitize stored path: trim and remove any leading slashes/spaces
                    String? sanitizePath(Object? p) {
                      if (p == null) return null;
                      var s = p.toString().trim();
                      if (s.isEmpty) return null;
                      s = s.replaceAll(RegExp(r"^/+"), '');
                      return s;
                    }

                    // If the stored thumbnail is already a full URL, use it.
                    if (thumbRaw != null &&
                        thumbRaw.toString().trim().toLowerCase().startsWith(
                          'http',
                        )) {
                      imageUrl = thumbRaw.toString().trim();
                    }

                    final tp = sanitizePath(thumbRaw);

                    if (tp != null && (imageUrl == null || imageUrl.isEmpty)) {
                      // The DB contains an object path (e.g. "soy_sauces/..jpg").
                      // Encode segments and ask Supabase Storage for the public URL.
                      final segments = tp
                          .split('/')
                          .map((s) => Uri.encodeComponent(s))
                          .toList();
                      final encoded = segments.join('/');

                      try {
                        final res = SupabaseService.client.storage
                            .from('product-image')
                            .getPublicUrl(encoded);
                        final publicUrl = res.toString();
                        if (publicUrl.isNotEmpty) {
                          imageUrl = publicUrl;
                        }
                      } catch (_) {
                        // ignore and fallthrough; imageUrl may remain null
                      }
                    }

                    if (imageUrl != null && imageUrl.isNotEmpty) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          width: 55,
                          height: 55,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 55,
                                height: 55,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 30,
                                ),
                              ),
                        ),
                      );
                    }

                    return const Icon(Icons.image_not_supported, size: 40);
                  },
                ),

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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Open add form
          Get.to(() => SupabaseAddView());
        },
        backgroundColor: const Color(0xFFFF6B00),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }
}
