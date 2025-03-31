import 'dart:convert'; // لاستخدام jsonDecode
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// !! تأكد من استيراد HomePage و RegisterPage بشكل صحيح !!
import '../home/home_page.dart';
import 'register_page.dart'; // لاستخدامه في زر "إنشاء حساب جديد"

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false; // لتتبع حالة عملية تسجيل الدخول

  // --- تعريف ألوان الحكمة (للاستخدام في هذه الصفحة) ---
  // (يفضل وضعها في ملف ثيم مركزي لاحقًا)
  static const Color alhikmaGreen = Color(0xFF00C853);
  static const Color alhikmaRed = Color(0xFFD50000);
  static const Color alhikmaGrey = Color(0xFFA0A0A0);
  static const Color darkTextColor = Color(0xFF333333);
  static const Color whiteColor = Colors.white;

  // --- دالة لتنفيذ عملية تسجيل الدخول ---
  Future<void> _login() async {
    // Basic validation added for demonstration
    if (_formKey.currentState?.validate() ?? false) {
      setState(() { _isLoading = true; });

      final String emailInput = _emailController.text.trim();
      final String passwordInput = _passwordController.text;

      Map<String, dynamic>? foundUser;

      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        List<String> usersJsonList = prefs.getStringList('registeredUsers') ?? [];

        for (String userJson in usersJsonList) {
          try {
            Map<String, dynamic> user = jsonDecode(userJson);
            if (user['email'] == emailInput && user['password'] == passwordInput) {
              foundUser = user;
              break;
            }
          } catch (e) { print("Error decoding user data during login check: $e"); }
        }

        if (foundUser != null) {
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('userName', foundUser['name'] ?? 'مستخدم');
          await prefs.setString('userEmail', foundUser['email'] ?? '');
          await prefs.setString('userAge', foundUser['age'] ?? 'غير محدد');
          await prefs.setString('userGender', foundUser['gender'] ?? 'غير محدد');

          if (mounted) {
            Navigator.pushReplacement( context, MaterialPageRoute(builder: (context) => HomePage()), );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar( SnackBar(
              content: Text('البريد الإلكتروني أو كلمة المرور غير صحيحة.'),
              backgroundColor: alhikmaRed, // استخدام اللون الأحمر للخطأ
            ), );
          }
        }

      } catch (e) {
        print("Error during login process: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar( SnackBar(
            content: Text('حدث خطأ غير متوقع أثناء تسجيل الدخول.'),
            backgroundColor: alhikmaRed, // استخدام اللون الأحمر للخطأ
          ), );
        }
      } finally {
        // Ensure isLoading is set to false even if widget is disposed during async operation
        if(mounted) {
          setState(() { _isLoading = false; });
        }
      }
    } // End validation check
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // الألوان تم تعريفها كـ static const في بداية الكلاس

    return Scaffold(
      // AppBar removed for full-screen background effect
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // --- 1. طبقة الخلفية (الصورة) ---
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/hospital.png'), // تأكد أن المسار صحيح
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.45), // زيادة التعتيم قليلاً
                  BlendMode.darken,
                ),
              ),
            ),
          ),

          // --- 2. طبقة المحتوى (النموذج) ---
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
              child: Card(
                elevation: 8.0,
                color: whiteColor.withOpacity(0.9), // زيادة وضوح خلفية البطاقة قليلاً
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        // --- شعار أو عنوان ---
                        Icon(Icons.local_hospital, size: 60, color: alhikmaRed), // استخدام اللون الأحمر للشعار
                        SizedBox(height: 15),
                        Text(
                          'تسجيل الدخول',
                          // استخدام اللون الأحمر للعنوان
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: alhikmaRed, // تطبيق اللون الأحمر
                          ),
                        ),
                        SizedBox(height: 30),

                        // --- حقول النموذج ---
                        TextFormField(
                          controller: _emailController,
                          style: TextStyle(color: darkTextColor), // لون النص المدخل
                          decoration: InputDecoration(
                              labelText: 'البريد الإلكتروني',
                              labelStyle: TextStyle(color: alhikmaGrey), // لون النص التلميحي
                              prefixIcon: Icon(Icons.email_outlined, color: alhikmaGrey), // لون الأيقونة رمادي
                              filled: true, fillColor: whiteColor.withOpacity(0.7), // خلفية للحقل
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(color: alhikmaGreen) // حدود خضراء عند التركيز
                              ),
                              errorStyle: TextStyle(color: alhikmaRed.withOpacity(0.9)) // لون نص الخطأ
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال البريد الإلكتروني';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                              return 'الرجاء إدخال بريد إلكتروني صالح';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          style: TextStyle(color: darkTextColor), // لون النص المدخل
                          decoration: InputDecoration(
                              labelText: 'كلمة المرور',
                              labelStyle: TextStyle(color: alhikmaGrey), // لون النص التلميحي
                              prefixIcon: Icon(Icons.lock_outline, color: alhikmaGrey), // لون الأيقونة رمادي
                              filled: true, fillColor: whiteColor.withOpacity(0.7), // خلفية للحقل
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(color: alhikmaGreen) // حدود خضراء عند التركيز
                              ),
                              errorStyle: TextStyle(color: alhikmaRed.withOpacity(0.9)) // لون نص الخطأ
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال كلمة المرور';
                            }
                            if (value.length < 6) { // مثال بسيط
                              return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 35),

                        // --- زر تسجيل الدخول ---
                        _isLoading
                            ? CircularProgressIndicator(color: alhikmaGreen) // مؤشر تحميل أخضر
                            : ElevatedButton(
                          onPressed: _login,
                          child: Text('تسجيل الدخول'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 50),
                            backgroundColor: alhikmaGreen, // اللون الأخضر للزر الرئيسي
                            foregroundColor: whiteColor, // لون النص أبيض
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 4,
                          ),
                        ),
                        SizedBox(height: 20),

                        // --- رابط إنشاء حساب ---
                        TextButton(
                          onPressed: () {
                            Navigator.push( context, MaterialPageRoute(builder: (context) => RegisterPage()), );
                          },
                          child: Text(
                            'ليس لديك حساب؟ إنشاء حساب جديد',
                            style: TextStyle(
                                color: alhikmaRed, // استخدام اللون الأحمر للرابط الثانوي
                                fontWeight: FontWeight.w600
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}