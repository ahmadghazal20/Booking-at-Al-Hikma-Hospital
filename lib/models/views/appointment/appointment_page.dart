// مسار الملف: lib/views/appointment/appointment_page.dart

// --- لا حاجة لـ dart:convert أو shared_preferences هنا ---
// import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import '../home/home_page.dart'; // للعودة للصفحة الرئيسية

class AppointmentPage extends StatelessWidget {
  final Map<String, String>? doctor;

  AppointmentPage({ Key? key, required this.doctor, }) : super(key: key);

  // --- تمت إزالة دالة _saveBookingRequest من هنا ---

  @override
  Widget build(BuildContext context) {
    final String doctorName = doctor?['name'] ?? 'اسم الطبيب';
    final String doctorSpeciality = doctor?['speciality'] ?? 'التخصص';
    final Color primaryColor = Theme.of(context).primaryColor;

    // --- تمت إزالة استدعاء الحفظ من هنا ---
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //    if (mounted) { _saveBookingRequest(context); }
    // });

    return Scaffold(
      appBar: AppBar(
        title: Text('تأكيد طلب الحجز'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon( Icons.check_circle_outline_rounded, color: primaryColor, size: 80, ),
              SizedBox(height: 25),
              Text( 'تم إرسال طلب الحجز بنجاح!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,), textAlign: TextAlign.center, ),
              SizedBox(height: 15),
              Text( 'سيتم مراجعة طلبك وسيتم التواصل معك قريبًا لتأكيد الموعد.', style: TextStyle(fontSize: 16, color: Theme.of(context).hintColor, height: 1.4), textAlign: TextAlign.center, ),
              SizedBox(height: 35),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                  child: Column(
                    children: [
                      _buildDetailRow(context, icon: Icons.person_outline_rounded, label: 'الطبيب:', value: doctorName),
                      Divider(height: 20, thickness: 0.5),
                      _buildDetailRow(context, icon: Icons.medical_services_outlined, label: 'التخصص:', value: doctorSpeciality),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton.icon(
                icon: Icon(Icons.home_rounded),
                label: Text('العودة إلى الرئيسية'),
                onPressed: () {
                  if (!context.mounted) return;
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom( minimumSize: Size(220, 50) ),
              )
            ],
          ),
        ),
      ),
    );
  } // نهاية build

  // دالة بناء الصف (لا تغيير هنا)
  Widget _buildDetailRow(BuildContext context, {required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          SizedBox(width: 12),
          Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black54)),
          SizedBox(width: 10),
          Expanded(
            child: Text( value, style: TextStyle(fontSize: 16), textAlign: TextAlign.end, overflow: TextOverflow.ellipsis,),
          ),
        ],
      ),
    );
  }
} // نهاية AppointmentPage