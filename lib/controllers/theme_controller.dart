import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_constants.dart';

class ThemeController extends GetxController {
  final RxBool isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadThemeFromPrefs();
  }

  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode.value = prefs.getBool(AppConstants.prefThemeKey) ?? false;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> toggleTheme() async {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefThemeKey, isDarkMode.value);
  }
}

