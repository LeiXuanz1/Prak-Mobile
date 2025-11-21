import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  final _isDark = false.obs;

  bool get isDark => _isDark.value;

  ThemeMode get themeMode => _isDark.value ? ThemeMode.light : ThemeMode.dark;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark.value = prefs.getBool("isDark") ?? false;
  }

  void toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark.value = !_isDark.value;
    prefs.setBool("isDark", _isDark.value);
  }
}
