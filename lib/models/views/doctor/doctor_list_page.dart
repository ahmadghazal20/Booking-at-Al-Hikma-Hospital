import 'package:flutter/material.dart';
// !! تأكد من أن هذا المسار صحيح بالنسبة لمشروعك !!
import 'doctor_detail_page.dart'; // استيراد صفحة تفاصيل الطبيب (النسخة المعدلة)

// --- دالة مساعدة لحساب متوسط التقييم (يمكن نقلها لملف utils) ---
double calculateAverageRatingForList(List<dynamic>? ratings) {
  if (ratings == null || ratings.isEmpty) {
    return 0.0;
  }
  double sum = 0;
  int validRatingsCount = 0;
  for (var rating in ratings) {
    if (rating is Map && rating.containsKey('score') && rating['score'] is num) {
      try {
        sum += (rating['score'] as num).toDouble();
        validRatingsCount++;
      } catch (e) {
        print("[AvgRating Warn] Could not convert score '${rating['score']}' to double.");
      }
    }
  }
  return validRatingsCount > 0 ? (sum / validRatingsCount) : 0.0;
}


class DoctorListPage extends StatelessWidget {
  final String speciality; // اسم التخصص المطلوب
  final List<Map<String, dynamic>> allDoctors; // القائمة الكاملة والمحدثة من HomePage
  final void Function(String doctorId, double rating, String comment) onRateDoctorCallback; // دالة التقييم من HomePage

  // Constructor لاستقبال البيانات المطلوبة
  const DoctorListPage({
    Key? key,
    required this.speciality,
    required this.allDoctors,
    required this.onRateDoctorCallback, required void Function(String doctorId, double rating, String comment) onRateDoctor, // تم تغيير الاسم للوضوح
  }) : super(key: key);

  // --- لا حاجة للخريطة المحلية doctorsData بعد الآن ---
  // final Map<String, List<Map<String, dynamic>>> doctorsData = { ... }; // <-- إزالة هذا

  @override
  Widget build(BuildContext context) {
    print("[DoctorListPage] Building page for speciality: '$speciality'");
    print("[DoctorListPage] Received ${allDoctors.length} total doctors.");

    // --- فلترة قائمة allDoctors بناءً على التخصص ---
    // مقارنة حساسة لحالة الأحرف وافتراض أن التخصص موجود في حقل 'speciality'
    // وقد تحتاج لتعديل هذا الشرط إذا كانت التخصصات مركبة أو غير دقيقة
    final List<Map<String, dynamic>> filteredDoctorList = allDoctors.where((doctor) {
      final docSpeciality = doctor['speciality'] as String?;
      // مثال بسيط للفلترة (قد يحتاج لتحسين ليتوافق مع تخصصات أكثر تعقيدًا)
      // هنا نفترض أن 'العينية' يجب أن يكون جزءًا من 'استشاري عيون', 'أخصائي عيون', إلخ.
      // وأن 'الأذنية' جزء من 'أنف وأذن وحنجرة'
      if (docSpeciality == null) return false;
      final specialityLower = speciality.toLowerCase(); // 'العينية' -> 'العينية'
      final docSpecialityLower = docSpeciality.toLowerCase(); // 'استشاري عيون' -> 'استشاري عيون'

      // تحسين منطق الفلترة - تحقق مما إذا كان اسم التخصص المعروض (مثل 'العينية')
      // موجودًا ضمن تخصص الطبيب الفعلي.
      if (specialityLower == 'العينية' && (docSpecialityLower.contains('عيون') || docSpecialityLower.contains('eye'))) {
        return true;
      } else if (specialityLower == 'الأذنية' && (docSpecialityLower.contains('أنف وأذن وحنجرة') || docSpecialityLower.contains('ear'))) {
        return true;
      }
      // يمكنك إضافة شروط else if لتخصصات أخرى
      // أو استخدام طريقة فلترة أكثر مرونة إذا لزم الأمر
      return false; // إذا لم يتطابق أي شرط
    }).toList(); // تحويل النتيجة إلى قائمة

    print("[DoctorListPage] Found ${filteredDoctorList.length} doctors after filtering for '$speciality'.");

    return Scaffold(
      appBar: AppBar(
        title: Text('أطباء قسم $speciality'),
      ),
      body: filteredDoctorList.isEmpty
          ? Center( // عرض رسالة إذا كانت القائمة المفلترة فارغة
        // ... (نفس كود رسالة الخطأ السابقة)
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
              SizedBox(height: 15),
              Text(
                "لم يتم العثور على أطباء مسجلين حاليًا لقسم\n\"$speciality\"",
                style: TextStyle(fontSize: 17, color: Colors.grey[600], height: 1.4),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      )
          : ListView.builder( // بناء القائمة من القائمة المفلترة
        padding: EdgeInsets.all(10.0),
        itemCount: filteredDoctorList.length,
        itemBuilder: (context, index) {
          try {
            // الحصول على بيانات الطبيب الحالي (الكاملة مع id و ratings)
            final doctorData = filteredDoctorList[index];
            // استدعاء الويدجت المسؤول عن بناء بطاقة الطبيب
            // مع تمرير بيانات الطبيب الكاملة ودالة التقييم
            return _buildDoctorCard(context, doctorData, onRateDoctorCallback); // تمرير الكول باك
          } catch (e, stackTrace) {
            print("[DoctorListPage] Error building card at index $index: $e\n$stackTrace");
            return _buildErrorCard(index, e);
          }
        },
      ),
    );
  } // نهاية دالة build

  // --- تعديل: ويدجت بناء البطاقة يستقبل دالة التقييم ---
  Widget _buildDoctorCard(
      BuildContext context,
      Map<String, dynamic> doctorDataMap,
      void Function(String doctorId, double rating, String comment) onRateDoctor // استقبال الكول باك
      ) {
    // استخلاص البيانات بأمان (بما في ذلك id و ratings)
    final String name = doctorDataMap['name'] as String? ?? 'اسم غير متوفر';
    final String specialityDetail = doctorDataMap['speciality'] as String? ?? 'تخصص غير متوفر';
    final String imagePath = doctorDataMap['image'] as String? ?? 'assets/doctor_placeholder.png';
    final String? doctorId = doctorDataMap['id'] as String?; // استخلاص المعرف
    final List<dynamic>? ratings = doctorDataMap['ratings'] as List<dynamic>?; // استخلاص التقييمات
    final double averageRating = calculateAverageRatingForList(ratings); // حساب متوسط التقييم

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // --- التحقق من وجود المعرف قبل الانتقال ---
          if (doctorId == null) {
            print("[DoctorListPage] Error: Doctor ID is null for '$name'. Cannot navigate.");
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('خطأ: لا يمكن عرض تفاصيل هذا الطبيب الآن.'), backgroundColor: Colors.red)
            );
            return; // منع الانتقال
          }

          // طباعة البيانات التي سيتم تمريرها (للتشخيص)
          // لاحظ أننا نمرر الخريطة الكاملة doctorDataMap
          print("[DoctorListPage] Navigating to details for ID: $doctorId");

          if (!context.mounted) return;

          // --- تنفيذ الانتقال ---
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorDetailPage(
                // *** التصحيح الرئيسي هنا ***
                doctorData: doctorDataMap, // 1. تمرير البيانات الكاملة
                onRateSubmitted: onRateDoctor, // 2. تمرير دالة رد الاتصال الصحيحة
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // --- صورة الطبيب ---
              ClipRRect(
                // ... (نفس الكود السابق للصورة)
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  imagePath,
                  height: 75, width: 75, fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // ... (نفس معالج الخطأ)
                    return Container(/* ... */);
                  },
                ),
              ),
              SizedBox(width: 15),

              // --- معلومات الطبيب ---
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, /* ... styles ... */),
                    SizedBox(height: 5),
                    Text(specialityDetail, /* ... styles ... */),
                    SizedBox(height: 6),
                    // --- عرض التقييم المحسوب ---
                    Row(
                      children: [
                        Icon(
                            Icons.star_rounded,
                            color: averageRating > 0 ? Colors.amber : Colors.grey[400], // لون يعتمد على التقييم
                            size: 18
                        ),
                        SizedBox(width: 4),
                        Text(
                            averageRating > 0 ? averageRating.toStringAsFixed(1) : 'لا تقييم', // عرض المتوسط أو رسالة
                            style: TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500)
                        ),
                        // يمكنك إضافة عدد التقييمات إذا أردت: (ratings?.length ?? 0)
                      ],
                    ),
                  ],
                ),
              ),

              // --- أيقونة السهم ---
              Icon(Icons.chevron_right, color: Colors.grey[400], size: 28),
            ],
          ),
        ),
      ),
    );
  } // نهاية دالة _buildDoctorCard

  // --- ويدجت لعرض بطاقة خطأ (كما هو) ---
  Widget _buildErrorCard(int index, Object error) {
    // ... (نفس الكود السابق)
    return Card(/* ... */);
  }

} // نهاية كلاس DoctorListPage