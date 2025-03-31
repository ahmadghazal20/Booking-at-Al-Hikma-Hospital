// main.dart
import 'package:doctor_appointment_ui/models/views/auth/login_page..dart';
import 'package:doctor_appointment_ui/views/profile/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Needed for async main

// استيراد البروفايدر والصفحات
import 'models/views/home/home_page.dart';   // تأكد أن المسار صحيح لـ HomePage

void main() async {
  // تأكد من تهيئة Flutter Widgets قبل استخدام SharedPreferences أو Provider
  WidgetsFlutterBinding.ensureInitialized();

  // تحميل حالة تسجيل الدخول قبل تشغيل التطبيق
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(
    ChangeNotifierProvider(
      // إنشاء وتوفير ThemeProvider للتطبيق بأكمله
      create: (_) => ThemeProvider(),
      child: MyApp(isLoggedIn: isLoggedIn), // تمرير حالة تسجيل الدخول
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn; // استقبال حالة تسجيل الدخول

  const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);


  // --- تعريف ألوان الحكمة الأساسية ---
  static const Color alhikmaGreen = Color(0xFF00C853);
  static const Color alhikmaRed = Color(0xFFD50000);
  static const Color alhikmaGrey = Color(0xFFA0A0A0);
  static const Color darkTextColor = Color(0xFF333333);
  static const Color lightTextColor = Color(0xFF757575);
  static const Color whiteColor = Colors.white;
  static const Color pageBackgroundColorLight = Color(0xFFFAFAFA);
  static const Color cardBackgroundColorLight = Colors.white;

  // --- تعريف ألوان المظهر الداكن ---
  static const Color pageBackgroundColorDark = Color(0xFF121212);
  static const Color cardBackgroundColorDark = Color(0xFF1E1E1E); // لون أفتح قليلاً للبطاقات
  static const Color darkAppBarColor = Color(0xFF1F1F1F); // لون شريط علوي داكن
  static const Color darkTextPrimaryColor = Colors.white; // لون النص الأساسي الفاتح
  static const Color darkTextSecondaryColor = Colors.white70; // لون النص الثانوي الفاتح


  @override
  Widget build(BuildContext context) {
    // الحصول على ThemeProvider الحالي
    final themeProvider = Provider.of<ThemeProvider>(context);

    // --- تعريف بيانات المظهر الفاتح ---
    final lightTheme = ThemeData(
      brightness: Brightness.light,
      primaryColor: alhikmaGreen,
      scaffoldBackgroundColor: pageBackgroundColorLight,
      colorScheme: ColorScheme.light(
        primary: alhikmaGreen,
        secondary: alhikmaRed, // اللون الأحمر
        surface: cardBackgroundColorLight, // لون خلفية البطاقات والأشياء المرتفعة
        background: pageBackgroundColorLight,
        onPrimary: whiteColor, // لون النص على اللون الأساسي
        onSecondary: whiteColor, // لون النص على اللون الثانوي
        onSurface: darkTextColor, // لون النص على البطاقات
        onBackground: darkTextColor, // لون النص على الخلفية العامة
        error: alhikmaRed, // لون الخطأ
        onError: whiteColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: alhikmaGreen, // شريط أخضر في الفاتح
        foregroundColor: whiteColor, // لون الأيقونات والنص في الشريط
        elevation: 2.0,
        iconTheme: IconThemeData(color: whiteColor),
        titleTextStyle: TextStyle(color: whiteColor, fontSize: 20, fontWeight: FontWeight.w500),
      ),
      cardTheme: CardTheme(
        color: cardBackgroundColorLight,
        elevation: 4.0,
        shadowColor: alhikmaGrey.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(color: alhikmaGrey),
        hintStyle: TextStyle(color: alhikmaGrey),
        prefixIconColor: alhikmaGrey,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: alhikmaGrey.withOpacity(0.4))),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: alhikmaGrey.withOpacity(0.4)), borderRadius: BorderRadius.circular(10.0)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: alhikmaRed, width: 2.0), borderRadius: BorderRadius.circular(10.0)),
        errorBorder: OutlineInputBorder(borderSide: BorderSide(color: alhikmaRed.withOpacity(0.7), width: 1.5), borderRadius: BorderRadius.circular(10.0)),
        focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: alhikmaRed, width: 2.0), borderRadius: BorderRadius.circular(10.0)),
        errorStyle: TextStyle(color: alhikmaRed.withOpacity(0.9)),
      ),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: alhikmaRed) // لون الأزرار النصية أحمر
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: alhikmaGreen, // الأزرار المرتفعة خضراء
            foregroundColor: whiteColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 4,
          )
      ),
      // ... يمكنك تخصيص باقي عناصر الثيم الفاتح هنا
    );

    // --- تعريف بيانات المظهر الداكن ---
    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      primaryColor: alhikmaGreen, // يمكن إبقاؤه أخضر أو تعديله
      scaffoldBackgroundColor: pageBackgroundColorDark,
      colorScheme: ColorScheme.dark(
        primary: alhikmaGreen, // اللون الأساسي
        secondary: alhikmaRed, // اللون الثانوي (يمكن تعديله للداكن إذا أردت)
        surface: cardBackgroundColorDark, // خلفية البطاقات
        background: pageBackgroundColorDark,
        onPrimary: whiteColor,
        onSecondary: whiteColor,
        onSurface: darkTextPrimaryColor, // لون النص على البطاقات
        onBackground: darkTextPrimaryColor, // لون النص على الخلفية
        error: Colors.redAccent, // لون خطأ مختلف للداكن
        onError: darkTextPrimaryColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkAppBarColor, // شريط داكن
        foregroundColor: whiteColor, // نص وأيقونات بيضاء
        elevation: 0.0, // بدون ظل للاندماج مع الخلفية
        iconTheme: IconThemeData(color: whiteColor),
        titleTextStyle: TextStyle(color: whiteColor, fontSize: 20, fontWeight: FontWeight.w500),
      ),
      cardTheme: CardTheme(
        color: cardBackgroundColorDark,
        elevation: 2.0, // ظل أخف في الداكن
        shadowColor: Colors.black.withOpacity(0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(color: alhikmaGrey),
        hintStyle: TextStyle(color: alhikmaGrey),
        prefixIconColor: alhikmaGrey,
        // تعديل الألوان لتناسب الخلفية الداكنة
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: alhikmaGrey.withOpacity(0.5))),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: alhikmaGrey.withOpacity(0.5)), borderRadius: BorderRadius.circular(10.0)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: alhikmaRed, width: 2.0), borderRadius: BorderRadius.circular(10.0)),
        errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.redAccent.withOpacity(0.8), width: 1.5), borderRadius: BorderRadius.circular(10.0)),
        focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.redAccent, width: 2.0), borderRadius: BorderRadius.circular(10.0)),
        errorStyle: TextStyle(color: Colors.redAccent.withOpacity(0.9)),
        fillColor: Colors.grey.shade800.withOpacity(0.5), // خلفية خفيفة للحقول
        filled: true,
      ),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: alhikmaRed) // إبقاء اللون الأحمر للأزرار النصية
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: alhikmaGreen, // إبقاء الأخضر
            foregroundColor: whiteColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 4,
          )
      ),
      // ... يمكنك تخصيص باقي عناصر الثيم الداكن هنا
    );


    return MaterialApp(
      title: 'Alhikma Hospital App', // اسم التطبيق
      theme: lightTheme, // تطبيق الثيم الفاتح الافتراضي
      darkTheme: darkTheme, // تطبيق الثيم الداكن
      themeMode: themeProvider.themeMode, // تحديد الوضع الحالي من البروفايدر
      debugShowCheckedModeBanner: false, // إخفاء شارة Debug
      // تحديد الصفحة الرئيسية بناءً على حالة تسجيل الدخول
      home: isLoggedIn ? HomePage() : LoginPage(),
      builder: (context, child) { // دعم الاتجاه من اليمين لليسار
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
    );
  }
}