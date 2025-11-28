import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/supabase_add_controller.dart';

class SupabaseAddView extends StatelessWidget {
  SupabaseAddView({super.key});

  final SupabaseAddController controller = Get.put(SupabaseAddController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Produk (Supabase)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Image Picker Section
              Obx(
                () => Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade50,
                  ),
                  child: controller.selectedImageFile.value != null
                      ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                controller.selectedImageFile.value!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 200,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () =>
                                    controller.selectedImageFile.value = null,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : InkWell(
                          onTap: () => controller.pickImage(),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_outlined,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Pilih Gambar (Opsional)',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'JPG, PNG (Max 5 MB)',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: const InputDecoration(labelText: 'Nama Produk'),
                onChanged: (v) => controller.title.value = v,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(labelText: 'Kategori'),
                onChanged: (v) => controller.category.value = v,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(labelText: 'Kemasan'),
                onChanged: (v) => controller.packaging.value = v,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (v) => controller.price.value = v,
              ),
              const SizedBox(height: 20),
              Obx(
                () => ElevatedButton(
                  onPressed:
                      controller.isLoading.value ||
                          controller.uploadingImage.value
                      ? null
                      : () async {
                          await controller.submit();
                          // close and pop back
                          if (Get.isDialogOpen ?? false) Get.back();
                          Get.back();
                        },
                  child:
                      controller.isLoading.value ||
                          controller.uploadingImage.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Tambah ke Cloud'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
