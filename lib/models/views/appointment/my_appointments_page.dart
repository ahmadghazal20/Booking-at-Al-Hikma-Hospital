import 'dart:convert'; // لاستخدام jsonDecode/Encode
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // لقراءة/كتابة الحجوزات
import 'package:intl/intl.dart'; // لاستخدام DateFormat
import 'package:intl/date_symbol_data_local.dart'; // <<--- تأكد من إضافة هذا الاستيراد
// لاستخدام Navigator للعودة إلى HomePage
import '../home/home_page.dart'; // تأكد من المسار الصحيح

class MyAppointmentsPage extends StatefulWidget {
  @override
  _MyAppointmentsPageState createState() => _MyAppointmentsPageState();
}

class _MyAppointmentsPageState extends State<MyAppointmentsPage> {
  List<Map<String, dynamic>> _bookedAppointments = [];
  bool _isLoading = true;

  // --- ألوان الثيم (يمكن استيرادها من مكان مركزي لاحقًا) ---
  static const Color alhikmaGreen = Color(0xFF00C853);
  static const Color alhikmaRed = Color(0xFFD50000); // للون الحذف مثلاً

  @override
  void initState() {
    super.initState();
    // تهيئة دعم اللغة العربية للتواريخ (الأفضل وضعها في main.dart)
    initializeDateFormatting('ar', null).then((_) {
      if (mounted) {
        _loadAppointments(); // تحميل المواعيد بعد تهيئة اللغة
      }
    });
  }

  // --- تعديل: دالة لقراءة المواعيد المحجوزة ---
  Future<void> _loadAppointments() async {
    if (!mounted) return; // تحقق قبل البدء
    setState(() { _isLoading = true; });
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // *** تعديل: استخدام المفتاح الصحيح ***
      List<String> appointmentsJsonList = prefs.getStringList('userAppointments') ?? [];
      List<Map<String, dynamic>> loadedAppointments = [];

      for (String appointmentJson in appointmentsJsonList) {
        try {
          Map<String, dynamic> appointmentMap = jsonDecode(appointmentJson);
          // *** تعديل: قراءة وتحويل حقل التاريخ الصحيح ***
          appointmentMap['appointmentDateTimeObject'] = DateTime.tryParse(appointmentMap['appointmentDateTime'] ?? '');
          loadedAppointments.add(appointmentMap);
        } catch (e) {
          print("Error decoding an appointment entry: $e");
        }
      }

      // فرز المواعيد حسب التاريخ (الأحدث أولاً)
      loadedAppointments.sort((a, b) {
        DateTime? timeA = a['appointmentDateTimeObject']; // *** تعديل: استخدام الكائن المحول ***
        DateTime? timeB = b['appointmentDateTimeObject']; // *** تعديل: استخدام الكائن المحول ***
        if (timeA == null && timeB == null) return 0;
        if (timeA == null) return 1; // المواعيد بدون تاريخ صالح تأتي لاحقًا
        if (timeB == null) return -1;
        return timeB.compareTo(timeA); // الأحدث أولاً
      });

      if (mounted) {
        setState(() {
          _bookedAppointments = loadedAppointments;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading appointments: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ في تحميل قائمة المواعيد.')));
        setState(() { _isLoading = false; });
      }
    }
  }
  // --- نهاية دالة القراءة المعدلة ---

  // --- تعديل: دالة لحذف موعد معين ---
  Future<void> _deleteAppointment(int indexToDelete) async {
    if (indexToDelete < 0 || indexToDelete >= _bookedAppointments.length) return;

    // لا نحتاج لـ jsonEncode هنا لأننا سنستخدم index مباشرة

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // *** تعديل: استخدام المفتاح الصحيح ***
      List<String> appointments = prefs.getStringList('userAppointments') ?? [];

      // التأكد من أن الـ index صالح قبل الحذف من القائمة المخزنة
      if (indexToDelete < appointments.length) {
        appointments.removeAt(indexToDelete); // إزالة الحجز باستخدام الـ Index

        // حفظ القائمة المحدثة
        // *** تعديل: استخدام المفتاح الصحيح ***
        await prefs.setStringList('userAppointments', appointments);

        // تحديث الواجهة بإزالة الحجز من القائمة المحلية
        if (mounted) {
          setState(() {
            _bookedAppointments.removeAt(indexToDelete);
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم إلغاء الموعد بنجاح.'), backgroundColor: Colors.green)); // لون أخضر للنجاح
        }
      } else {
        print("Error deleting appointment: Index out of bounds in stored list.");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: لم يتم العثور على الموعد في القائمة المخزنة.')));
        }
      }

    } catch (e) {
      print("Error deleting appointment: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ أثناء إلغاء الموعد.')));
      }
    }
  }
  // --- نهاية دالة الحذف المعدلة ---

  @override
  Widget build(BuildContext context) {
    // استخدام ألوان الثيم المعرفة هنا (أو من Provider لاحقًا)
    final Color primaryColor = alhikmaGreen;
    final Color accentColor = alhikmaRed; // استخدام الأحمر للحذف

    return Scaffold(
      // *** تعديل: تغيير عنوان الصفحة ***
      appBar: AppBar(
        title: Text('مواعيــدي المحجوزة'),
        backgroundColor: primaryColor, // لون الشريط من الثيم
        actions: [
          IconButton( // زر تحديث
            icon: Icon(Icons.refresh),
            tooltip: 'تحديث المواعيد',
            onPressed: _loadAppointments,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : _buildBody(context, primaryColor, accentColor),
    );
  }

  Widget _buildBody(BuildContext context, Color primaryColor, Color accentColor) {
    if (_bookedAppointments.isEmpty) {
      // --- حالة عدم وجود مواعيد ---
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today_outlined, size: 70, color: Colors.grey[400]),
              SizedBox(height: 20),
              // *** تعديل: تغيير النص ***
              Text( 'لا توجد مواعيد محجوزة حاليًا.', style: TextStyle(fontSize: 18, color: Colors.grey[600]), textAlign: TextAlign.center, ),
              SizedBox(height: 30),
              ElevatedButton.icon(
                icon: Icon(Icons.add_circle_outline),
                label: Text('احجز الآن'),
                onPressed: () {
                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil( context, MaterialPageRoute(builder: (context) => HomePage()), (Route<dynamic> route) => false, );
                },
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor), // استخدام لون الثيم
              )
            ],
          ),
        ),
      );
    } else {
      // --- حالة وجود مواعيد ---
      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: _bookedAppointments.length,
              itemBuilder: (context, index) {
                final appointment = _bookedAppointments[index];
                final String doctorName = appointment['doctorName'] ?? 'اسم غير معروف';
                final String speciality = appointment['doctorSpeciality'] ?? 'تخصص غير معروف';
                // *** تعديل: استخدام حقل الصورة الصحيح ***
                final String? imagePath = appointment['doctorImage']; // كان اسمه 'image' في الكود السابق
                // *** تعديل: استخدام كائن التاريخ المحول للتنسيق ***
                final DateTime? dateTime = appointment['appointmentDateTimeObject'];
                String formattedDateTime = 'تاريخ/وقت غير محدد';
                if (dateTime != null) {
                  // استخدام intl للتنسيق بالعربية - تأكد من تهيئة اللغة!
                  try {
                    // تنسيق شامل للتاريخ والوقت
                    formattedDateTime = DateFormat('EEEE, d MMMM yyyy • hh:mm a', 'ar').format(dateTime);
                  } catch (e) {
                    print("Error formatting date in list (locale issue?): $e");
                    // تنسيق افتراضي كحل بديل
                    formattedDateTime = DateFormat('yyyy-MM-dd • HH:mm').format(dateTime);
                  }
                }

                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  elevation: 2.0, // تقليل الظل قليلاً
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // توحيد الحواف
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundColor: primaryColor.withOpacity(0.1),
                      // *** تعديل: التحقق من imagePath ***
                      backgroundImage: (imagePath != null && imagePath.isNotEmpty) ? AssetImage(imagePath) as ImageProvider : null,
                      onBackgroundImageError: (e, s) => print("Error loading image in appointments: $e"),
                      // *** تعديل: التحقق من imagePath للعنصر النائب ***
                      child: (imagePath == null || imagePath.isEmpty) ? Icon(Icons.person_outline, color: primaryColor) : null,
                    ),
                    title: Text( doctorName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16), ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Text(speciality, style: TextStyle(color: Theme.of(context).hintColor, fontSize: 14)),
                        SizedBox(height: 6),
                        // *** تعديل: عرض تاريخ ووقت الموعد الفعلي ***
                        Row(
                          children: [
                            Icon(Icons.calendar_month_outlined, size: 15, color: primaryColor),
                            SizedBox(width: 5),
                            Expanded( // للسماح للنص بالالتفاف
                              child: Text(
                                formattedDateTime, // عرض التاريخ والوقت المنسق للموعد
                                style: TextStyle(fontSize: 13, color: Colors.grey[800], fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete_forever_outlined, color: accentColor), // أيقونة حذف حمراء
                      tooltip: 'إلغاء الموعد', // *** تعديل: تغيير النص ***
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext dialogContext) {
                            return AlertDialog(
                              title: Text('تأكيد الإلغاء'),
                              // *** تعديل: تغيير النص ***
                              content: Text('هل أنت متأكد من رغبتك في إلغاء الموعد مع "$doctorName"؟'),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('لا'),
                                  onPressed: () => Navigator.of(dialogContext).pop(),
                                ),
                                TextButton(
                                  // *** تعديل: تغيير النص ***
                                  child: Text('نعم، إلغاء الموعد', style: TextStyle(color: accentColor)),
                                  onPressed: () {
                                    Navigator.of(dialogContext).pop();
                                    _deleteAppointment(index);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          ),
          // --- زر إضافة حجز جديد (يظهر دائمًا في الأسفل) ---
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: ElevatedButton.icon(
              icon: Icon(Icons.add_circle_outline),
              label: Text('حجز موعد جديد'),
              onPressed: () {
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil( context, MaterialPageRoute(builder: (context) => HomePage()), (Route<dynamic> route) => false, );
              },
              style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 45),
                  backgroundColor: primaryColor // استخدام لون الثيم
              ),
            ),
          ),
        ],
      );
    }
  } // نهاية _buildBody
}