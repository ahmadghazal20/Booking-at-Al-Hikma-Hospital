import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? currentLanguage;

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentLanguage = prefs.getString('language') ?? 'ar';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTranslatedTitle()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // عناصر الملف الشخصي هنا...

            // أداة اختيار اللغة
            _buildLanguageSelector(),

            // محتوى آخر...
          ],
        ),
      ),
    );
  }

  String _getTranslatedTitle() {
    switch (currentLanguage) {
      case 'ar': return 'الملف الشخصي';
      case 'en': return 'Profile';
      case 'fr': return 'Profil';
      default: return 'Profile';
    }
  }

  Widget _buildLanguageSelector() {
    return DropdownButtonFormField<String>(
      value: currentLanguage,
      decoration: InputDecoration(
        labelText: _getTranslation('Language', 'اللغة', 'Langue'),
        border: OutlineInputBorder(),
      ),
      items: [
        DropdownMenuItem(
          value: 'ar',
          child: Text('العربية'),
        ),
        DropdownMenuItem(
          value: 'en',
          child: Text('English'),
        ),
        DropdownMenuItem(
          value: 'fr',
          child: Text('Français'),
        ),
      ],
      onChanged: (String? newValue) {
        if (newValue != null) {
        }
      },
    );
  }

  String _getTranslation(String en, String ar, String fr) {
    switch (currentLanguage) {
      case 'ar': return ar;
      case 'en': return en;
      case 'fr': return fr;
      default: return en;
    }
  }
}