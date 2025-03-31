import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String? _selectedGender; // لتتبع الجنس المحدد
  bool _isLoading = true;
  bool _isSaving = false;

  final List<String> _genders = ['ذكر', 'أنثى', 'غير محدد'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _nameController.text = prefs.getString('userName') ?? '';
      _emailController.text = prefs.getString('userEmail') ?? '';
      _ageController.text = prefs.getString('userAge') ?? '';
      _selectedGender = prefs.getString('userGender');
      // التأكد من أن الجنس المحمل موجود في قائمتنا
      if (_selectedGender != null && !_genders.contains(_selectedGender)) {
        _selectedGender = null; // إعادة التعيين إذا كانت قيمة غير صالحة
      }
    } catch (e) {
      print("Error loading profile data: $e");
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ في تحميل البيانات.')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveUserData() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userName', _nameController.text.trim());
        await prefs.setString('userEmail', _emailController.text.trim());
        await prefs.setString('userAge', _ageController.text.trim());
        if (_selectedGender != null) {
          await prefs.setString('userGender', _selectedGender!);
        } else {
          await prefs.remove('userGender'); // أو تعيين قيمة افتراضية
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم حفظ التغييرات بنجاح!')));
          // يمكنك العودة للصفحة السابقة أو تحديث الحالة في HomePage إذا لزم الأمر
          Navigator.pop(context, true); // إرسال true للإشارة إلى حدوث تغيير
        }

      } catch (e) {
        print("Error saving profile data: $e");
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ في حفظ البيانات.')));
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تعديل الملف الشخصي'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center( // صورة المستخدم (اختياري)
                child: CircleAvatar(
                  radius: 50,
                  // يمكنك إضافة صورة هنا
                  child: Icon(Icons.person, size: 60),
                ),
              ),
              SizedBox(height: 30),

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'الاسم الكامل',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الرجاء إدخال الاسم';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                // يمكنك جعل هذا الحقل للقراءة فقط إذا كان لا يمكن تغييره
                // readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال البريد الإلكتروني';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'البريد الإلكتروني غير صالح';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(
                  labelText: 'العمر',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.cake_outlined),
                ),
                keyboardType: TextInputType.number,
                // يمكنك إضافة validator للتحقق من أنه رقم صالح
              ),
              SizedBox(height: 20),

              // --- اختيار الجنس ---
              DropdownButtonFormField<String>(
                value: _selectedGender,
                hint: Text('اختر الجنس'), // نص يظهر عندما لا يكون هناك اختيار
                decoration: InputDecoration(
                  labelText: 'الجنس',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.wc_outlined),
                ),
                items: _genders.map((String gender) {
                  return DropdownMenuItem<String>(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGender = newValue;
                  });
                },
                // يمكنك إضافة validator إذا كان اختيار الجنس إلزاميًا
                // validator: (value) => value == null ? 'الرجاء اختيار الجنس' : null,
              ),
              SizedBox(height: 40),

              _isSaving
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _saveUserData,
                child: Text('حفظ التغييرات', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}