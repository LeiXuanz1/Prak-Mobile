import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  final auth = Get.find<AuthController>();
  final emailC = TextEditingController();
  final passC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.inventory_2_outlined, size: 64),
                  const SizedBox(height: 16),

                  Text(
                    'Login',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'Manajemen Stok Kecap',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // EMAIL
                  Obx(() => TextField(
                        controller: emailC,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon:
                              const Icon(Icons.email_outlined),
                          errorText: auth.emailError.value,
                        ),
                        onChanged: (_) => auth.emailError.value = null,
                      )),
                  const SizedBox(height: 16),

                  // PASSWORD
                  Obx(() => TextField(
                        controller: passC,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon:
                              const Icon(Icons.lock_outline),
                          errorText: auth.passwordError.value,
                        ),
                        onChanged: (_) =>
                            auth.passwordError.value = null,
                      )),
                  const SizedBox(height: 8),

                  // GENERAL ERROR (login gagal)
                  Obx(() => auth.generalError.value == null
                      ? const SizedBox.shrink()
                      : Text(
                          auth.generalError.value!,
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .error,
                          ),
                        )),
                  const SizedBox(height: 16),

                  // LOGIN BUTTON
                  Obx(() => FilledButton(
                        onPressed: auth.isLoading.value
                            ? null
                            : () async {
                                final success =
                                    await auth.login(
                                  emailC.text.trim(),
                                  passC.text.trim(),
                                );

                                if (success) {
                                  Get.offAllNamed(
                                      AppRoutes.home);
                                }
                              },
                        child: auth.isLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2),
                              )
                            : const Text('Login'),
                      )),

                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: () =>
                        Get.toNamed(AppRoutes.register),
                    child: const Text('Buat akun baru'),
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
