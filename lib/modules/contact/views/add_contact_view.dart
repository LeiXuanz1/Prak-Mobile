import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/contact_controller.dart';
import '../../location/views/location_view.dart';
import '../../location/controllers/location_controller.dart';
import '../../location/controllers/location_permission_controller.dart';
import '../../../data/local/hive_models/contact_hive_model.dart';
import '../../location/models/location_model.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AddContactView extends StatelessWidget {
  final controller = Get.put(ContactController());
  final ContactHiveModel? editingContact;

  AddContactView({super.key, this.editingContact});

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final locationLabelController = TextEditingController();

  final selectedLatitude = Rx<double?>(null);
  final selectedLongitude = Rx<double?>(null);
  final selectedLocationLabel = Rx<String?>(null);
  final hasLocation = false.obs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Populate form if editing (only once)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (editingContact != null) {
        nameController.text = editingContact!.name;
        phoneController.text = editingContact!.phone ?? '';
        emailController.text = editingContact!.email ?? '';
        addressController.text = editingContact!.address;
        if (editingContact!.latitude != null &&
            editingContact!.longitude != null) {
          selectedLatitude.value = editingContact!.latitude;
          selectedLongitude.value = editingContact!.longitude;
          selectedLocationLabel.value = editingContact!.locationLabel;
          hasLocation.value = true;
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          editingContact != null ? 'Edit Kontak' : 'Tambah Kontak Baru',
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success Message
            Obx(() {
              if (controller.successMessage.value != null) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF4CAF50),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF4CAF50),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          controller.successMessage.value!,
                          style: const TextStyle(
                            color: Color(0xFF4CAF50),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            // Error Message
            Obx(() {
              if (controller.errorMessage.value != null) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF44336).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFF44336),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Color(0xFFF44336),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          controller.errorMessage.value!,
                          style: const TextStyle(
                            color: Color(0xFFF44336),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            // Form Title
            Text(
              'Data Kontak',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Nama Toko/Pembeli
            Text(
              'Nama Toko / Pembeli *',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Contoh: Toko ABC, Supplier XYZ',
                prefixIcon: const Icon(Icons.business),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Nomor Telepon
            Text(
              'Nomor Telepon',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(13),
              ],
              decoration: InputDecoration(
                hintText: 'Contoh: 08123456789',
                helperText: '10-13 digit',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Email
            Text(
              'Email',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Contoh: toko@email.com',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Alamat
            Text(
              'Alamat *',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: addressController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Masukkan alamat lengkap',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Location Section
            Text(
              'Lokasi Toko (Opsional)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // Button untuk ambil lokasi dari map
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    // Navigate to location view untuk pick location
                    final result = await Get.to<Map<String, dynamic>?>(
                      () => LocationPickerWrapper(
                        initialLatitude: selectedLatitude.value,
                        initialLongitude: selectedLongitude.value,
                      ),
                    );

                    if (!context.mounted) return;

                    if (result != null) {
                      selectedLatitude.value = result['latitude'] as double?;
                      selectedLongitude.value = result['longitude'] as double?;
                      hasLocation.value = true;

                      // Show location label dialog
                      _showLocationLabelDialog(context);
                    }
                  },
                  icon: const Icon(Icons.my_location),
                  label: Text(
                    hasLocation.value
                        ? 'Lokasi Sudah Dipilih'
                        : 'Tambah Lokasi dari Map',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Display selected location
            Obx(
              () => hasLocation.value && selectedLocationLabel.value != null
                  ? Card(
                      elevation: 0,
                      color: theme.colorScheme.primaryContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedLocationLabel.value ?? '-',
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: theme
                                              .colorScheme
                                              .onPrimaryContainer,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${selectedLatitude.value?.toStringAsFixed(4) ?? '-'}, ${selectedLongitude.value?.toStringAsFixed(4) ?? '-'}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color:
                                          theme.colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                selectedLatitude.value = null;
                                selectedLongitude.value = null;
                                selectedLocationLabel.value = null;
                                hasLocation.value = false;
                              },
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            const SizedBox(height: 32),

            // Submit Button
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                          if (editingContact != null) {
                            // Update existing contact
                            controller.updateContact(
                              id: editingContact!.id,
                              name: nameController.text,
                              phone: phoneController.text.isEmpty
                                  ? null
                                  : phoneController.text,
                              email: emailController.text.isEmpty
                                  ? null
                                  : emailController.text,
                              address: addressController.text,
                              latitude: selectedLatitude.value,
                              longitude: selectedLongitude.value,
                              locationLabel: selectedLocationLabel.value,
                            );
                          } else {
                            // Add new contact
                            controller.addContact(
                              name: nameController.text,
                              phone: phoneController.text.isEmpty
                                  ? null
                                  : phoneController.text,
                              email: emailController.text.isEmpty
                                  ? null
                                  : emailController.text,
                              address: addressController.text,
                              latitude: selectedLatitude.value,
                              longitude: selectedLongitude.value,
                              locationLabel: selectedLocationLabel.value,
                            );
                          }

                          if (controller.errorMessage.value == null) {
                            Future.delayed(const Duration(seconds: 2), () {
                              Get.back();
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          editingContact != null
                              ? 'Update Kontak'
                              : 'Simpan Kontak',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLocationLabelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Label Lokasi'),
        content: TextField(
          controller: locationLabelController,
          decoration: InputDecoration(
            hintText: 'Contoh: Toko Utama, Gudang, Supplier ABC',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              locationLabelController.clear();
              selectedLatitude.value = null;
              selectedLongitude.value = null;
              hasLocation.value = false;
              Navigator.pop(context);
            },
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              if (locationLabelController.text.isNotEmpty) {
                selectedLocationLabel.value = locationLabelController.text;
              } else {
                selectedLocationLabel.value = 'Lokasi Toko';
              }
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}

// Wrapper untuk LocationView agar bisa return data
class LocationPickerWrapper extends StatelessWidget {
  final double? initialLatitude;
  final double? initialLongitude;

  const LocationPickerWrapper({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
  });

  @override
  Widget build(BuildContext context) {
    // Put controllers jika belum ada
    if (!Get.isRegistered<LocationPermissionController>()) {
      Get.put(LocationPermissionController());
    }
    final locationController = Get.isRegistered<LocationController>()
        ? Get.find<LocationController>()
        : Get.put(LocationController());

    // Jika ada initial location, set sebagai selectedMarker
    if (initialLatitude != null && initialLongitude != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        locationController.selectedLocation.value = LocationModel(
          latitude: initialLatitude!,
          longitude: initialLongitude!,
          accuracy: 0,
          timestamp: DateTime.now(),
        );

        locationController.selectedMarker.value = Marker(
          point: LatLng(initialLatitude!, initialLongitude!),
          width: 40,
          height: 40,
          child: const Icon(Icons.location_on, color: Colors.blue),
        );

        // Move map ke lokasi itu
        locationController.moveTo(initialLatitude!, initialLongitude!);
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Lokasi Toko'), centerTitle: true),
      body: LocationView(
        isPickerMode: true,
        onLocationSelected: (latitude, longitude) {
          Get.back(result: {'latitude': latitude, 'longitude': longitude});
        },
      ),
    );
  }
}
