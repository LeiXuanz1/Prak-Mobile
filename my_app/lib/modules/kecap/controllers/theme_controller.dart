import 'package:get/get.dart';

class ThemeController extends GetxController {
  RxBool isDark = false.obs;

  void toggleTheme() {
    isDark.value = !isDark.value;
  }
}