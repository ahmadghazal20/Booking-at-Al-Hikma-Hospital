import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  Locale _locale;

  LanguageProvider({Locale? initialLocale}) : _locale = initialLocale ?? Locale('ar');

  Locale get locale => _locale;

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;

    // حفظ اللغة في SharedPreferences لتكون متاحة عند إعادة تشغيل التطبيق
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', locale.languageCode);

    notifyListeners();
  }
}
