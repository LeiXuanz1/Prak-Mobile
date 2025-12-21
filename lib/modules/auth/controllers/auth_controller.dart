import 'package:get/get.dart';
import 'package:my_app/data/local/controllers/hive_product_controller.dart';
import 'package:my_app/data/sync/product_sync_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final isLoggedIn = false.obs;
  final isLoading = true.obs;
  bool _initialSyncDone = false;

  final isPasswordVisible = false.obs;
  final emailError = RxnString();
  final passwordError = RxnString();
  final confirmPasswordError = RxnString();
  final generalError = RxnString();

  @override
  void onInit() {
    super.onInit();

    _authService.onAuthStateChanged((session) async {
      print('AUTH EVENT: ${session != null}');

      if (session == null) {
        _initialSyncDone = false;
        isLoggedIn.value = false;
        isLoading.value = false;
        return;
      }

      if (_initialSyncDone) return;

      _initialSyncDone = true;
      isLoading.value = true;

      try {
        await _authService.ensureProfile();

        print('AUTH READY -> RUN INITIAL SYNC');
        await ProductSyncService.sync();

        if (Get.isRegistered<HiveProductController>()) {
          Get.find<HiveProductController>().loadProducts();
        }

        isLoggedIn.value = true;
      } catch (e, s) {
        print('AUTH INIT ERROR');
        print(e);
        print(s);
      } finally {
        isLoading.value = false;
      }
    });
  }

  void togglePassword() {
    isPasswordVisible.toggle();
  }

  void clearErrors() {
    emailError.value = null;
    passwordError.value = null;
    confirmPasswordError.value = null;
    generalError.value = null;
  }

  // return true jika sukses
  Future<bool> login(String email, String password) async {
    clearErrors();

    if (email.isEmpty) {
      emailError.value = 'Email wajib diisi';
      return false;
    }

    if (password.isEmpty) {
      passwordError.value = 'Password wajib diisi';
      return false;
    }

    try {
      isLoading.value = true;
      await _authService.login(email: email, password: password);
      await _authService.ensureProfile();
      isLoggedIn.value = true;
      return true;
    } catch (e) {
      generalError.value = 'Email atau password salah';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> register(String email, String password) async {
    clearErrors();

    if (email.isEmpty) {
      emailError.value = 'Email wajib diisi';
      return false;
    }

    if (password.length < 6) {
      passwordError.value = 'Password minimal 6 karakter';
      return false;
    }

    try {
      isLoading.value = true;

      await _authService.register(email: email, password: password);
      await _authService.ensureProfile();

      return true;
    } on AuthException catch (e) {
      generalError.value = e.message;
      return false;
    } catch (e) {
      generalError.value = 'Registrasi gagal';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    isLoggedIn.value = false;
  }
}
