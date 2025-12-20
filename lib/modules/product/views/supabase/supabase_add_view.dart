import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/supabase_add_controller.dart';
import '../../widgets/product_form.dart';
import '../../models/product_form_data.dart';


class SupabaseAddView extends StatelessWidget {
  SupabaseAddView({super.key});

  final SupabaseAddController controller =
      Get.put(SupabaseAddController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Produk (Cloud)'),
        centerTitle: true,
      ),

      body: Obx(
        () => Stack(
          children: [
            ProductForm(
              submitLabel: 'Tambah ke Cloud',
              onSubmit: (ProductFormData data) async {
                await controller.submitForm(data);
                Get.back();
              },
            ),

            // LOADING OVERLAY
            if (controller.isLoading.value)
              Container(
                color: Colors.black.withValues(alpha: 0.2),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
