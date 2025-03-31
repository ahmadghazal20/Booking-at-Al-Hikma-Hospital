import 'dart:convert'; // لاستخدام jsonEncode/jsonDecode
// Corrected import for LoginPage if it's inside the same 'auth' folder
// تأكد من المسار الصحيح لـ LoginPage
import 'package:doctor_appointment_ui/models/views/auth/login_page..dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _password = '';
  String _nationality = 'سوري';
  String? _governorate;
  String? _city;
  // *** إضافة: متغير حالة للجنس ***
  String? _selectedGender; // null يعني لم يتم الاختيار بعد
  // ********************************
  final TextEditingController _otherCityController = TextEditingController();
  bool _isLoading = false;

  // --- تعريف ألوان الحكمة ---
  static const Color alhikmaGreen = Color(0xFF00C853);
  static const Color alhikmaRed = Color(0xFFD50000);
  static const Color alhikmaGrey = Color(0xFFA0A0A0);
  static const Color darkTextColor = Color(0xFF333333);
  static const Color whiteColor = Colors.white;
  static const Color pageBackgroundColor = Color(0xFFFAFAFA);
  static const Color cardBackgroundColor = Colors.white;
  static final Color warningColor = Colors.orange.shade700;

  final List<String> _governorates = ['إدلب', 'حلب', 'أخرى'];
  final Map<String, List<String>> _cities = {
    'إدلب': [
      'عقربات', 'أطمة', 'قاح', 'سراقب', 'ارمناز', 'حارم', 'سرمدا', 'الدانا', 'حزانو', 'سلقين',
      'معرة النعمان', 'أريحا', 'بنش', 'تفتناز', 'سرمين', 'جسر الشغور', 'كفرنبل', 'خان شيخون',
      'كفرتخاريم', 'معرة مصرين', 'قميناس', 'تلعادة', 'كفرومة', 'حاس', 'التح', 'كفرسجنة',
      'البارة', 'كنصفرة', 'إحسم', 'بليون', 'الهبيط', 'بسقلا', 'كفرنجد', 'كفرعويد', 'مشمشان',
      'المغارة', 'مرعيان', 'فركيا', 'كرسعا', 'معرشمارين', 'بابيلا', 'معرشورين', 'الغدفة',
      'الجرادة', 'ترملا', 'حيش', 'معرة حرمة', 'بسيدا', 'معصران', 'الحامدية', 'شنان',
      'دير سنبل', 'معرزيتا', 'جرجناز', 'سفوهن', 'تلمنس', 'معرتحرمة', 'أم جلال', 'سكيك',
      'القصابية', 'الركايا', 'الشيخ مصطفى', 'معرتماتر', 'النقير', 'أبو الظهور', 'تل الطوقان',
      'أم الخلاخيل', 'الكتيبة', 'أبو دفنة', 'أبو مكة', 'إدلب'
    ],
    'حلب': [
      'إعزاز', 'مارع', 'صوران', 'أخترين', 'دابق', 'تلالين', 'الغندورة', 'الراعي', 'الباب',
      'قباسين', 'بزاعة', 'جرابلس', 'تل رفعت', 'منبج', 'عين العرب (كوباني)', 'الشيوخ', 'أرشاف',
      'كفرغان', 'تل بطال', 'دوير الهوى', 'دارة عزة', 'الأتارب', 'باتبو', 'كفر نوران', 'كفر كرمين',
      'أورم الكبرى', 'أورم الصغرى', 'تقاد', 'بسرطون', 'قبتان الجبل', 'كفر داعل', 'الأبزمو', 'الجينة',
      'السحارة', 'كفرحلب', 'ميزناز', 'كفرناها', 'عنجارة', 'حور', 'القصر', 'تل حدية', 'الحاضر',
      'الزربة', 'العيس', 'خان طومان', 'تل الضمان', 'الكماري', 'جزرايا', 'هوبر', 'رسم العيس', 'خناصر',
      'رسم السيالة', 'أم ميال', 'سرجة', 'بنان', 'تل دادين', 'مسكنة', 'دير حافر', 'تلعرن', 'تل حاصل',
      'السفيرة', 'رسم حرمل الإمام', 'حميمة كبيرة', 'حميمة صغيرة', 'أم خرزة', 'أبو جرين', 'الطيبة',
      'قصر هدلة', 'جب الحمام', 'رسم الكبير', 'المهدوم'
    ],
  };

  @override
  void dispose() {
    _otherCityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // الألوان معرفة كـ static const أعلاه

    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        backgroundColor: alhikmaRed,
        title: Text('إنشاء حساب جديد', style: TextStyle(color: whiteColor)),
        centerTitle: true,
        leading: BackButton(color: whiteColor),
        iconTheme: IconThemeData(color: whiteColor),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
        child: Card(
          elevation: 4.0,
          shadowColor: alhikmaGrey.withOpacity(0.3),
          color: cardBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          child: Padding(
            padding: EdgeInsets.all(25.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text( 'إنشاء حساب', style: TextStyle( fontSize: 26.0, fontWeight: FontWeight.bold, color: alhikmaRed,), textAlign: TextAlign.center, ),
                  SizedBox(height: 25.0),

                  // --- حقول النموذج (الاسم, الايميل, كلمة المرور) ---
                  TextFormField( decoration: _inputDecoration('الاسم الثلاثي', Icons.person_outline), style: TextStyle(color: darkTextColor), validator: (v) => v == null || v.trim().isEmpty ? 'الرجاء إدخال الاسم' : null, onSaved: (v) => _name = v!.trim(), ),
                  SizedBox(height: 15.0),
                  TextFormField( decoration: _inputDecoration('البريد الإلكتروني', Icons.email_outlined), style: TextStyle(color: darkTextColor), keyboardType: TextInputType.emailAddress, validator: (v) { if (v == null || v.trim().isEmpty) return 'الرجاء إدخال البريد الإلكتروني'; if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) return 'البريد الإلكتروني غير صالح'; return null; }, onSaved: (v) => _email = v!.trim(), ),
                  SizedBox(height: 15.0),
                  TextFormField( decoration: _inputDecoration('كلمة المرور', Icons.lock_outline), style: TextStyle(color: darkTextColor), obscureText: true, validator: (v) { if (v == null || v.isEmpty) return 'الرجاء إدخال كلمة المرور'; if (v.length < 6) return 'كلمة المرور قصيرة (6 أحرف على الأقل)'; return null; }, onSaved: (v) => _password = v!, ),
                  SizedBox(height: 20.0), // زيادة المسافة قبل قسم الجنس

                  // --- *** إضافة: قسم اختيار الجنس *** ---
                  Text('الجنس', style: TextStyle(fontSize: 16, color: alhikmaGrey, fontWeight: FontWeight.w500)),
                  Row( // استخدام Row لوضع أزرار الراديو جنبًا إلى جنب
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('ذكر'),
                          value: 'ذكر',
                          groupValue: _selectedGender,
                          onChanged: (value) { setState(() { _selectedGender = value; }); },
                          activeColor: alhikmaRed, // اللون الأحمر عند الاختيار
                          contentPadding: EdgeInsets.zero, // لإزالة الحشو الافتراضي
                          visualDensity: VisualDensity.compact, // لتقليل المساحة العمودية
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('أنثى'),
                          value: 'أنثى',
                          groupValue: _selectedGender,
                          onChanged: (value) { setState(() { _selectedGender = value; }); },
                          activeColor: alhikmaRed, // اللون الأحمر عند الاختيار
                          contentPadding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                  ),
                  // إضافة Divider للتمييز البصري (اختياري)
                  Divider(height: 25, thickness: 0.5, color: alhikmaGrey.withOpacity(0.5)),
                  // --- ******************************** ---


                  // --- القوائم المنسدلة (الجنسية, المحافظة, المدينة) ---
                  DropdownButtonFormField<String>( decoration: _inputDecoration('الجنسية', Icons.flag_outlined), dropdownColor: cardBackgroundColor, style: TextStyle(color: darkTextColor, fontSize: 16), value: _nationality, items: ['سوري', 'أجنبي'].map((n) => DropdownMenuItem(value: n, child: Text(n))).toList(), onChanged: (v) { if (v != null) { setState(() { _nationality = v; }); } }, ),
                  SizedBox(height: 15.0),
                  DropdownButtonFormField<String>( decoration: _inputDecoration('المحافظة', Icons.location_city_outlined), dropdownColor: cardBackgroundColor, style: TextStyle(color: darkTextColor, fontSize: 16), value: _governorate, hint: Text('اختر المحافظة', style: TextStyle(color: alhikmaGrey)), items: _governorates.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(), onChanged: (v) { if (v != null) { setState(() { _governorate = v; _city = null; _otherCityController.clear(); }); } }, validator: (v) => v == null ? 'الرجاء اختيار المحافظة' : null, ),
                  SizedBox(height: 15.0),
                  if (_governorate == 'إدلب' || _governorate == 'حلب') DropdownButtonFormField<String>( decoration: _inputDecoration('المدينة', Icons.location_on_outlined), dropdownColor: cardBackgroundColor, style: TextStyle(color: darkTextColor, fontSize: 16), value: _city, hint: Text('اختر المدينة', style: TextStyle(color: alhikmaGrey)), items: (_cities[_governorate ?? ''] ?? []).map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) { if (v != null) { setState(() { _city = v; }); } }, validator: (v) => v == null ? 'الرجاء اختيار المدينة' : null, ),
                  if (_governorate == 'أخرى') TextFormField( controller: _otherCityController, decoration: _inputDecoration('اسم المدينة', Icons.edit_location_alt_outlined), style: TextStyle(color: darkTextColor), validator: (v) => v == null || v.trim().isEmpty ? 'الرجاء إدخال اسم المدينة' : null, ),
                  SizedBox(height: 30.0),

                  // --- زر إنشاء الحساب أو مؤشر التحميل ---
                  _isLoading
                      ? Center(child: CircularProgressIndicator(color: alhikmaGreen))
                      : ElevatedButton( style: ElevatedButton.styleFrom( backgroundColor: alhikmaGreen, padding: EdgeInsets.symmetric(vertical: 15.0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)), elevation: 4, ), onPressed: _registerUser, child: Text( 'إنشاء الحساب', style: TextStyle(fontSize: 18.0, color: whiteColor), ), ),
                  SizedBox(height: 15.0),

                  // --- زر الانتقال لصفحة تسجيل الدخول ---
                  TextButton( onPressed: () { Navigator.pushReplacement( context, MaterialPageRoute(builder: (context) => LoginPage()), ); }, child: Text( 'لديك حساب بالفعل؟ تسجيل الدخول', style: TextStyle(color: alhikmaRed, fontWeight: FontWeight.w500), ), ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- دالة مساعدة لإنشاء تنسيق حقول الإدخال (كما هي) ---
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration( labelText: label, labelStyle: TextStyle(color: alhikmaGrey), prefixIcon: Icon(icon, color: alhikmaGrey), enabledBorder: OutlineInputBorder( borderSide: BorderSide(color: alhikmaGrey.withOpacity(0.4)), borderRadius: BorderRadius.circular(10.0), ), focusedBorder: OutlineInputBorder( borderSide: BorderSide(color: alhikmaRed, width: 2.0), borderRadius: BorderRadius.circular(10.0), ), errorBorder: OutlineInputBorder( borderSide: BorderSide(color: alhikmaRed.withOpacity(0.7), width: 1.5), borderRadius: BorderRadius.circular(10.0), ), focusedErrorBorder: OutlineInputBorder( borderSide: BorderSide(color: alhikmaRed, width: 2.0), borderRadius: BorderRadius.circular(10.0), ), errorStyle: TextStyle(color: alhikmaRed.withOpacity(0.9)), contentPadding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0), );
  }


  // --- دالة لتنفيذ عملية تسجيل المستخدم ---
  Future<void> _registerUser() async {
    // *** إضافة: التحقق من اختيار الجنس ***
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar( content: Text('الرجاء اختيار الجنس.'), backgroundColor: warningColor,),
      );
      return; // إيقاف التنفيذ إذا لم يتم اختيار الجنس
    }
    // *************************************

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() { _isLoading = true; });

      final String finalCity = (_governorate == 'أخرى') ? _otherCityController.text.trim() : _city!;

      // التحقق من وجود مستخدم بنفس الايميل (كما هو)
      SharedPreferences prefsCheck = await SharedPreferences.getInstance();
      List<String> existingUsers = prefsCheck.getStringList('registeredUsers') ?? [];
      bool emailExists = false;
      for (String userJson in existingUsers) { /* ... (كود التحقق من الايميل كما هو) ... */
        try { Map<String, dynamic> user = jsonDecode(userJson); if (user['email'] == _email) { emailExists = true; break; } } catch(e) { print("Error decoding user data during check: $e"); }
      }
      if (emailExists) { if(mounted){ setState(() { _isLoading = false; }); ScaffoldMessenger.of(context).showSnackBar( SnackBar( content: Text('هذا البريد الإلكتروني مسجل بالفعل.'), backgroundColor: warningColor, ), ); } return; }

      // *** تعديل: إضافة الجنس إلى بيانات المستخدم ***
      final userData = {
        'name': _name, 'email': _email, 'password': _password,
        'nationality': _nationality, 'governorate': _governorate, 'city': finalCity,
        'age': 'غير محدد', // القيمة الافتراضية للعمر
        'gender': _selectedGender, // <-- حفظ الجنس المختار
      };
      // *******************************************

      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        List<String> usersList = prefs.getStringList('registeredUsers') ?? [];
        usersList.add(jsonEncode(userData));
        await prefs.setStringList('registeredUsers', usersList);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar( SnackBar( content: Text('تم إنشاء حسابك بنجاح! يمكنك الآن تسجيل الدخول.'), backgroundColor: alhikmaGreen, ), );
          Navigator.pushReplacement( context, MaterialPageRoute(builder: (context) => LoginPage()), );
        }
      } catch (e) {
        print("Error saving new user: $e");
        if (mounted) { ScaffoldMessenger.of(context).showSnackBar( SnackBar( content: Text('حدث خطأ أثناء حفظ الحساب. حاول مرة أخرى.'), backgroundColor: alhikmaRed, ), ); }
      } finally {
        if (mounted) { setState(() { _isLoading = false; }); }
      }
    } else {
      if(mounted){ ScaffoldMessenger.of(context).showSnackBar( SnackBar( content: Text('الرجاء مراجعة البيانات المدخلة والتأكد من صحتها.'), backgroundColor: warningColor, ), ); }
    }
  }
}