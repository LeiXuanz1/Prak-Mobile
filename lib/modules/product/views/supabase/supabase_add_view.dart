import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/supabase_add_controller.dart';

class SupabaseAddView extends StatelessWidget {
  SupabaseAddView({super.key});

  final SupabaseAddController controller = Get.put(SupabaseAddController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Produk'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // IMAGE PICKER (M3 CARD)
              Obx(
                () => Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerHighest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: controller.selectedImageFile.value == null
                        ? controller.pickImage
                        : null,
                    child: SizedBox(
                      width: double.infinity,
                      height: 200,
                      child: controller.selectedImageFile.value != null
                          ? Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.file(
                                    controller.selectedImageFile.value!,
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: IconButton(
                                    onPressed: () =>
                                        controller.selectedImageFile.value =
                                            null,
                                    style: IconButton.styleFrom(
                                      backgroundColor:
                                          theme.colorScheme.errorContainer,
                                    ),
                                    icon: Icon(
                                      Icons.close,
                                      color:
                                          theme.colorScheme.onErrorContainer,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_outlined,
                                  size: 48,
                                  color:
                                      theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Pilih Gambar (Opsional)',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'JPG / PNG • Max 5 MB',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // FORM
              _buildField(
                label: 'Nama Produk',
                onChanged: (v) => controller.title.value = v,
              ),
              _buildField(
                label: 'Kategori',
                onChanged: (v) => controller.category.value = v,
              ),
              _buildField(
                label: 'Kemasan',
                onChanged: (v) => controller.packaging.value = v,
              ),
              _buildField(
                label: 'Harga',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: (v) => controller.price.value = v,
              ),

              const SizedBox(height: 32),

              // SUBMIT BUTTON
              Obx(
                () => FilledButton(
                  onPressed: controller.isLoading.value ||
                          controller.uploadingImage.value
                      ? null
                      : () {
                          controller.submit();
                        },
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: controller.isLoading.value ||
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

  Widget _buildField({
    required String label,
    TextInputType? keyboardType,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
