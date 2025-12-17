import 'package:get/get.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final isLoggedIn = false.obs;
  final isLoading = true.obs;

  final isPasswordVisible = false.obs;
  final emailError = RxnString();
  final passwordError = RxnString();
  final confirmPasswordError = RxnString();
  final generalError = RxnString();

  @override
  void onInit() {
    super.onInit();

    _authService.onAuthStateChanged((session) {
      print('AUTH EVENT: ${session != null}');

      isLoggedIn.value = session != null;
      isLoading.value = false;
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
      return true;
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
