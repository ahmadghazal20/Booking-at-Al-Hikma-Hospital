// This is a basic Flutter widget test.
// ... (باقي التعليقات)

import 'package:doctor_appointment_ui/views/profile/theme_provider.dart'; // استيراد البروفايدر
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart'; // استيراد Provider
import 'package:doctor_appointment_ui/main.dart';
// --- تصحيح الاستيراد: استخدم اسم الحزمة الصحيح من pubspec.yaml ---
// غالبًا سيكون "doctor_appointment_ui" بناءً على main.dart
import 'package:doctor_appointment_ui/main.dart';
// قد تحتاج أيضًا لاستيراد LoginPage إذا أردت البحث عن عناصر محددة بداخله
// import 'package:doctor_appointment_ui/models/views/auth/login_page..dart';

void main() {
  // تم تغيير اسم ووصف الاختبار ليعكس ما يتم اختباره الآن
  testWidgets('App starts with LoginPage when not logged in', (WidgetTester tester) async {
    // --- تصحيح بناء الويدجت ---
    // 1. توفير ThemeProvider
    // 2. بناء MyApp مع isLoggedIn: false
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const MyApp(isLoggedIn: false), // توفير القيمة المطلوبة لـ isLoggedIn
      ),
    );

    // --- تعديل منطق الاختبار ---
    // تحقق من عرض LoginPage (بافتراض وجود هذا النص فيها)
    // !! استبدل 'تسجيل الدخول' بنص مميز موجود فعليًا في LoginPage لديك !!
    expect(find.text('تسجيل الدخول'), findsOneWidget); // أو ابحث عن زر أو حقل مميز

    // تحقق من عدم عرض HomePage (بافتراض وجود هذا النص فيها)
    // !! استبدل 'أهلاً بك!' بنص مميز موجود فعليًا في HomePage لديك !!
    expect(find.text('أهلاً بك!'), findsNothing);

    // يمكنك إضافة المزيد من التحققات هنا لعناصر LoginPage الأخرى
    // مثال: البحث عن حقل البريد الإلكتروني (بافتراض له مفتاح معين)
    // expect(find.byKey(const Key('login_email_field')), findsOneWidget);
  });

  // يمكنك إضافة اختبار آخر لحالة تسجيل الدخول
  testWidgets('App starts with HomePage when logged in', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const MyApp(isLoggedIn: true), // بناء MyApp مع isLoggedIn: true
      ),
    );

    // تحقق من عرض HomePage
    // !! استبدل 'أهلاً بك!' بنص مميز موجود فعليًا في HomePage لديك !!
    expect(find.text('أهلاً بك!'), findsOneWidget);

    // تحقق من عدم عرض LoginPage
    // !! استبدل 'تسجيل الدخول' بنص مميز موجود فعليًا في LoginPage لديك !!
    expect(find.text('تسجيل الدخول'), findsNothing);

    // يمكنك إضافة المزيد من التحققات هنا لعناصر HomePage الأخرى
    // مثال: البحث عن شريط البحث
    // expect(find.byType(TextField), findsOneWidget);
  });
}