import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalization {
  final Locale locale;
  static const LocalizationsDelegate<AppLocalization> delegate = _AppLocalizationDelegate();

  AppLocalization(this.locale);

  static AppLocalization? of(BuildContext context) {
    return Localizations.of<AppLocalization>(context, AppLocalization);
  }

  late Map<String, String> _localizedStrings;

  Future<bool> load() async {
    String jsonString = await rootBundle.loadString('l10n/app_${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  static Future<void> init() async {
    // يمكنك استخدام هذه الدالة للتهيئة المسبقة إذا لزم الأمر
  }
}

class _AppLocalizationDelegate extends LocalizationsDelegate<AppLocalization> {
  const _AppLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalization> load(Locale locale) async {
    AppLocalization localization = AppLocalization(locale);
    await localization.load();
    return localization;
  }

  @override
  bool shouldReload(_AppLocalizationDelegate old) => false;
}