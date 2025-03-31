// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light; // الوضع الافتراضي
  static const String _themePrefKey = 'isDarkMode'; // مفتاح الحفظ

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadThemePreference(); // تحميل الإعداد عند إنشاء البروفايدر
  }

  // تحميل الإعداد المحفوظ
  Future<void> _loadThemePreference() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isDark = prefs.getBool(_themePrefKey) ?? false; // القيمة الافتراضية false (فاتح)
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      // لا تستدعي notifyListeners هنا لتجنب إعادة بناء غير ضرورية عند البدء
      // سيتم تطبيق المظهر في main.dart عند القراءة الأولية
      print("Theme loaded: ${_themeMode}"); // For debugging
    } catch (e) {
      print("Error loading theme preference: $e");
      _themeMode = ThemeMode.light; // Fallback to light mode on error
    }
    // Notify after potential async gap if you need immediate update after load elsewhere
    // notifyListeners(); // Usually not needed if MaterialApp reads initial state
  }

  // تبديل المظهر وحفظ الإعداد
  Future<void> toggleTheme(bool isOn) async {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // أخبر المستمعين بالتغيير لإعادة بناء الواجهة

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themePrefKey, isOn);
      print("Theme preference saved: ${_themeMode}"); // For debugging
    } catch (e) {
      print("Error saving theme preference: $e");
    }
  }
}