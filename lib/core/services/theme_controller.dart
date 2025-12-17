import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  static const _key = 'isDarkMode';

  final _isDark = false.obs;

  bool get isDark => _isDark.value;

  ThemeMode get themeMode =>
      _isDark.value ? ThemeMode.dark : ThemeMode.light;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark.value = prefs.getBool(_key) ?? false;
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark.toggle();
    await prefs.setBool(_key, _isDark.value);
  }
}
