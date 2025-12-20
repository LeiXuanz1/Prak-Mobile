import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../modules/auth/controllers/auth_controller.dart';
import 'app_routes.dart';

class AuthMiddleware extends GetMiddleware {
  final auth = Get.find<AuthController>();

  @override
  RouteSettings? redirect(String? route) {
    return auth.isLoggedIn.value
        ? null
        : const RouteSettings(name: AppRoutes.login);
  }
}
