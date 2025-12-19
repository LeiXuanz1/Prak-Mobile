import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../data/local/hive_boxes.dart';
import '../../../data/local/models/contact_hive_model.dart';

class ContactController extends GetxController {
  final contacts = <ContactHiveModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = Rx<String?>(null);
  final successMessage = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    _loadContacts();
  }

  void _loadContacts() {
    try {
      final contactList = HiveBoxes.contacts.values.toList();
      contacts.value = contactList;
    } catch (e) {
      errorMessage.value = 'Gagal memuat kontak: $e';
    }
  }

  Future<void> addContact({
    required String name,
    String? phone,
    String? email,
    required String address,
    double? latitude,
    double? longitude,
    String? locationLabel,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      if (name.isEmpty || address.isEmpty) {
        errorMessage.value = 'Nama dan alamat tidak boleh kosong';
        isLoading.value = false;
        return;
      }

      final contact = ContactHiveModel(
        id: const Uuid().v4(),
        name: name,
        phone: phone,
        email: email,
        address: address,
        latitude: latitude,
        longitude: longitude,
        locationLabel: locationLabel,
        createdAt: DateTime.now(),
      );

      await HiveBoxes.contacts.add(contact);
      _loadContacts();
      successMessage.value = 'Kontak "$name" berhasil ditambahkan';

      // Clear success message after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        successMessage.value = null;
      });

      isLoading.value = false;
    } catch (e) {
      errorMessage.value = 'Gagal menambahkan kontak: $e';
      isLoading.value = false;
    }
  }

  Future<void> updateContact({
    required String id,
    required String name,
    String? phone,
    String? email,
    required String address,
    double? latitude,
    double? longitude,
    String? locationLabel,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      // Find the index
      final index = HiveBoxes.contacts.values.toList().indexWhere(
        (c) => c.id == id,
      );

      if (index == -1) {
        errorMessage.value = 'Kontak tidak ditemukan';
        isLoading.value = false;
        return;
      }

      final updatedContact = ContactHiveModel(
        id: id,
        name: name,
        phone: phone,
        email: email,
        address: address,
        latitude: latitude,
        longitude: longitude,
        locationLabel: locationLabel,
        createdAt: HiveBoxes.contacts.getAt(index)?.createdAt ?? DateTime.now(),
      );

      await HiveBoxes.contacts.putAt(index, updatedContact);
      _loadContacts();
      successMessage.value = 'Kontak "$name" berhasil diperbarui';

      Future.delayed(const Duration(seconds: 2), () {
        successMessage.value = null;
      });

      isLoading.value = false;
    } catch (e) {
      errorMessage.value = 'Gagal memperbarui kontak: $e';
      isLoading.value = false;
    }
  }

  Future<void> deleteContact(String id) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final index = HiveBoxes.contacts.values.toList().indexWhere(
        (c) => c.id == id,
      );

      if (index == -1) {
        errorMessage.value = 'Kontak tidak ditemukan';
        isLoading.value = false;
        return;
      }

      await HiveBoxes.contacts.deleteAt(index);
      _loadContacts();
      successMessage.value = 'Kontak berhasil dihapus';

      Future.delayed(const Duration(seconds: 2), () {
        successMessage.value = null;
      });

      isLoading.value = false;
    } catch (e) {
      errorMessage.value = 'Gagal menghapus kontak: $e';
      isLoading.value = false;
    }
  }

  ContactHiveModel? getContactById(String id) {
    try {
      return HiveBoxes.contacts.values.firstWhere(
        (c) => c.id == id,
        orElse: () => throw Exception(),
      );
    } catch (_) {
      return null;
    }
  }
}
