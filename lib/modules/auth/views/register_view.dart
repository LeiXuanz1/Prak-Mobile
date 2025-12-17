import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';

class RegisterView extends StatelessWidget {
  RegisterView({super.key});

  final auth = Get.find<AuthController>();
  final emailC = TextEditingController();
  final passC = TextEditingController();
  final confirmC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Buat Akun',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // EMAIL
                  Obx(
                    () => TextField(
                      controller: emailC,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        errorText: auth.emailError.value,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // PASSWORD
                  Obx(
                    () => TextField(
                      controller: passC,
                      obscureText: !auth.isPasswordVisible.value,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        helperText: 'Minimal 6 karakter',
                        prefixIcon: const Icon(Icons.lock_outline),
                        errorText: auth.passwordError.value,
                        suffixIcon: IconButton(
                          icon: Icon(
                            auth.isPasswordVisible.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: auth.togglePassword,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // CONFIRM PASSWORD
                  Obx(
                    () => TextField(
                      controller: confirmC,
                      obscureText: !auth.isPasswordVisible.value,
                      decoration: InputDecoration(
                        labelText: 'Konfirmasi Password',
                        prefixIcon: const Icon(Icons.lock_reset_outlined),
                        errorText: auth.confirmPasswordError.value,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // GENERAL ERROR (AUTH FAILED)
                  Obx(
                    () => auth.generalError.value != null
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              auth.generalError.value!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : const SizedBox(),
                  ),

                  // REGISTER BUTTON
                  Obx(
                    () => FilledButton(
                      onPressed: auth.isLoading.value
                          ? null
                          : () async {
                              auth.clearErrors();

                              if (passC.text.isEmpty) {
                                auth.passwordError.value =
                                    'Password wajib diisi';
                                return;
                              }

                              if (confirmC.text.isEmpty) {
                                auth.confirmPasswordError.value =
                                    'Konfirmasi password wajib diisi';
                                return;
                              }

                              if (passC.text != confirmC.text) {
                                auth.confirmPasswordError.value =
                                    'Password tidak sama';
                                return;
                              }

                              final success = await auth.register(
                                emailC.text.trim(),
                                passC.text.trim(),
                              );

                              if (success) {
                                Get.offAllNamed(AppRoutes.login);
                                Get.snackbar(
                                  'Berhasil',
                                  'Akun berhasil dibuat',
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              }
                            },
                      child: auth.isLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Register'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
