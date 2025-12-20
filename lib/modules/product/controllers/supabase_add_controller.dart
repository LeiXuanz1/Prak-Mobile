import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:my_app/data/local/controllers/hive_product_controller.dart';
import 'package:my_app/data/local/hive_models/product_hive_model.dart';
import '../../../data/cloud/supabase_service.dart';
import '../../apify/controllers/apify_controller.dart';
import '../controllers/supabase_product_controller.dart';
import 'package:my_app/modules/product/models/product_form_data.dart';

class SupabaseAddController extends GetxController {
  final title = ''.obs;
  final category = ''.obs;
  final packaging = ''.obs;
  final price = ''.obs;
  final isLoading = false.obs;
  final selectedImageFile = Rx<File?>(null);
  final uploadingImage = false.obs;

  final ImagePicker _imagePicker = ImagePicker();

  // Pick image from gallery/camera
  Future<void> pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final fileSizeInMB = await file.length() / (1024 * 1024);

        // Validate: max 5MB, allowed formats
        if (fileSizeInMB > 5) {
          Get.snackbar(
            'File Terlalu Besar',
            'Maksimal ukuran file adalah 5 MB',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
          return;
        }

        final ext = file.path.split('.').last.toLowerCase();
        if (!['jpg', 'jpeg', 'png'].contains(ext)) {
          Get.snackbar(
            'Format Tidak Didukung',
            'Hanya jpg, jpeg, png yang didukung',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
          return;
        }

        selectedImageFile.value = file;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memilih gambar: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Upload image to Supabase Storage
  // Returns the storage object path (e.g. "soy_sauces/abc123.jpg") or null on failure
  Future<String?> _uploadImageToStorage(File imageFile) async {
    try {
      uploadingImage.value = true;

      // Generate unique filename: soy_sauces/{uuid}_{originalname}
      final ext = imageFile.path.split('.').last;
      final uuid = DateTime.now().millisecondsSinceEpoch.toString();
      // Store as soy_sauces/{uuid}.{ext}
      final storagePath = 'soy_sauces/${uuid}.$ext';

      // Upload to Supabase Storage
      final bytes = await imageFile.readAsBytes();
      await SupabaseService.client.storage
          .from('kecap-images')
          .uploadBinary(storagePath, bytes);

      return storagePath;
    } catch (e) {
      Get.snackbar(
        'Upload Error',
        'Gagal upload gambar: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    } finally {
      uploadingImage.value = false;
    }
  }

  Future<void> submit() async {
    print('SUBMIT DIPANGGIL');
    isLoading.value = true;
    try {
      // Create a simple slug from the display name
      String slug = title.value
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
          .replaceAll(RegExp(r'(^-+|-+$)'), '');

      print('SEBELUM UPLOAD IMAGE');
      // Upload image if selected
      String? thumbnailStoragePath;
      if (selectedImageFile.value != null) {
        thumbnailStoragePath = await _uploadImageToStorage(
          selectedImageFile.value!,
        );
        if (thumbnailStoragePath == null) {
          // Upload failed, snackbar already shown
          print('UPLOAD GAGAL, SUBMIT BERHENTI');
          throw Exception('Upload image gagal');
        }
      }

      final Map<String, dynamic> row = {
        'display_name': title.value.trim(),
        'slug': slug,
        'category': category.value.trim().isEmpty
            ? null
            : category.value.trim(),
        'packaging': packaging.value.trim().isEmpty
            ? null
            : packaging.value.trim(),
        'price': double.tryParse(price.value) ?? 0.0,
        if (thumbnailStoragePath != null) 'thumbnail': thumbnailStoragePath,
      };

      final res = await SupabaseService.insertSoySauce(row);
      print('INSERTED ROW => $res');

      try {
        final hive = Get.find<HiveProductController>();

        final localProduct = ProductHiveModel(
          id: res['id'],
          title: row['display_name'],
          category: row['category'],
          stock: 0,
          unit: row['unit_size'],
          price: row['price'],
          description: row['description'],
          thumbnail: thumbnailStoragePath,
          source: 'supabase',
          status: 'Available',
          updatedAt: DateTime.now(),
          isSynced: true,
          isDeleted: false,
          packaging: row['packaging'],
        );

        await hive.addProduct(localProduct);
      } catch (e) {
        // Bubble error to UI with a visible snackbar and rethrow so caller may inspect.
        Get.snackbar(
          'Supabase Error',
          e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        rethrow;
      }

      // refresh supabase product list
      try {
        final sp = Get.find<SupabaseProductController>();
        await sp.loadProducts();
      } catch (_) {}

      // show success snackbar and log recent activity
      Get.snackbar(
        'Sukses',
        'Produk berhasil ditambahkan ke cloud',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // log recent activity
      try {
        final apify = Get.find<ApifyController>();
        apify.addRecentActivity({
          'type': 'added',
          'title': title.value,
          'description': 'Added to cloud (Supabase)',
          'timeAgo': 'just now',
          'timestamp': DateTime.now().toIso8601String(),
        });
      } catch (_) {}
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitForm(ProductFormData data) async {
    try {
      isLoading.value = true;

      String? imagePath;

      if (data.imagePath != null) {
        imagePath = await _uploadImageToStorage(File(data.imagePath!));
      }

      await SupabaseService.client.from('soy_sauces').insert({
        'display_name': data.title,
        'category': data.category,
        'stock': data.stock,
        'unit_size': data.unit.trim().toLowerCase(),
        'price': data.price,
        'packaging': data.packaging,
        'description': data.description,
        'thumbnail': imagePath,
      });

      await Get.find<SupabaseProductController>().loadProducts();
    } finally {
      isLoading.value = false;
    }
  }
}
