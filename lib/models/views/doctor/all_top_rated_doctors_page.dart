import 'package:flutter/material.dart';
// !! تأكد من أن هذا المسار صحيح بالنسبة لمشروعك !!
import 'doctor_detail_page.dart'; // استيراد صفحة تفاصيل الطبيب (النسخة المعدلة)

// --- دالة مساعدة لحساب متوسط التقييم (يمكن نقلها لملف utils أو جعلها static) ---
double calculateAverageRatingForList(List<dynamic>? ratings) {
  if (ratings == null || ratings.isEmpty) {
    return 0.0;
  }
  double sum = 0;
  int validRatingsCount = 0;
  for (var rating in ratings) {
    // التحقق من أن العنصر خريطة ويحتوي على المفتاح والنوع الصحيح
    if (rating is Map && rating.containsKey('score') && rating['score'] is num) {
      try {
        sum += (rating['score'] as num).toDouble();
        validRatingsCount++;
      } catch (e) {
        // سجل تحذيرًا في حالة فشل التحويل، لكن استمر
        print("[AvgRating Warn] Could not convert score '${rating['score']}' to double.");
      }
    } else {
      // سجل تحذيرًا إذا كان عنصر التقييم بتنسيق غير متوقع
      // print("[AvgRating Warn] Invalid rating item format: $rating");
    }
  }
  // تجنب القسمة على صفر
  return validRatingsCount > 0 ? (sum / validRatingsCount) : 0.0;
}


class AllTopRatedDoctorsPage extends StatelessWidget {
  // استقبال قائمة الأطباء الكاملة ودالة رد الاتصال للتقييم
  final List<Map<String, dynamic>> allDoctors; // القائمة الكاملة والمحدثة من HomePage
  final void Function(String doctorId, double rating, String comment) onRateDoctorCallback; // دالة التقييم من HomePage

  const AllTopRatedDoctorsPage({
    Key? key,
    required this.allDoctors,
    required this.onRateDoctorCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // فرز الأطباء حسب الأعلى تقييماً قبل عرضهم
    // إنشاء نسخة قابلة للتعديل لتجنب تعديل القائمة الأصلية الممررة
    List<Map<String, dynamic>> sortedDoctors = List.from(allDoctors);
    try {
      sortedDoctors.sort((a, b) {
        // حساب متوسط التقييم لكل طبيب بأمان
        double ratingA = calculateAverageRatingForList(a['ratings'] as List<dynamic>?);
        double ratingB = calculateAverageRatingForList(b['ratings'] as List<dynamic>?);
        // ترتيب تنازلي (الأعلى تقييمًا أولاً)
        return ratingB.compareTo(ratingA);
      });
    } catch (e, stackTrace) {
      // في حالة حدوث خطأ أثناء الفرز، سجل الخطأ واستخدم القائمة غير المفرزة
      print("[AllTopRatedDoctorsPage] Error sorting doctors: $e\n$stackTrace");
      // يمكنك اختيار عرض رسالة خطأ أو استخدام القائمة الأصلية
      // sortedDoctors = List.from(widget.allDoctors); // العودة للقائمة الأصلية
    }


    print("[AllTopRatedDoctorsPage] Displaying ${sortedDoctors.length} doctors, sorted by rating.");

    return Scaffold(
      appBar: AppBar(
        title: Text('الأطباء الأعلى تقييماً'), // عنوان يعكس المحتوى
      ),
      body: sortedDoctors.isEmpty
          ? Center( // رسالة في حالة عدم وجود أطباء لعرضهم
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column( // استخدام Column لعرض الأيقونة والنص
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline, size: 60, color: Colors.grey[400]),
              SizedBox(height: 15),
              Text(
                'لا يوجد أطباء لعرضهم حاليًا.',
                style: TextStyle(fontSize: 17, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      )
          : ListView.builder( // بناء القائمة من الأطباء المفرزين
        padding: EdgeInsets.all(10.0), // حشو حول القائمة
        itemCount: sortedDoctors.length, // عدد العناصر في القائمة المفرزة
        itemBuilder: (context, index) {
          try {
            // الحصول على بيانات الطبيب الحالي من القائمة المفرزة
            final doctorData = sortedDoctors[index];
            // استدعاء الويدجت المسؤول عن بناء بطاقة الطبيب
            // مع تمرير بيانات الطبيب الكاملة ودالة التقييم
            return _buildDoctorCard(context, doctorData, onRateDoctorCallback);
          } catch (e, stackTrace) {
            // في حالة حدوث خطأ أثناء بناء البطاقة
            print("[AllTopRatedDoctorsPage] Error building card at index $index: $e\n$stackTrace");
            // عرض بطاقة خطأ بدلاً من التسبب في تعطل التطبيق
            return _buildErrorCard(index, e);
          }
        },
      ),
    );
  } // نهاية دالة build

  // --- ويدجت لبناء بطاقة الطبيب (تستقبل دالة التقييم) ---
  Widget _buildDoctorCard(
      BuildContext context,
      Map<String, dynamic> doctorDataMap,
      void Function(String doctorId, double rating, String comment) onRateDoctor // استقبال الكول باك
      ) {
    // استخلاص البيانات بأمان من الخريطة `doctorDataMap` مع قيم افتراضية
    final String name = doctorDataMap['name'] as String? ?? 'اسم غير متوفر';
    final String speciality = doctorDataMap['speciality'] as String? ?? 'تخصص غير متوفر';
    final String imagePath = doctorDataMap['image'] as String? ?? 'assets/doctor_placeholder.png'; // صورة افتراضية
    final String? doctorId = doctorDataMap['id'] as String?; // استخلاص المعرف الفريد للطبيب
    final List<dynamic>? ratings = doctorDataMap['ratings'] as List<dynamic>?; // استخلاص قائمة التقييمات
    final double averageRating = calculateAverageRatingForList(ratings); // حساب متوسط التقييم

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5), // مسافات حول البطاقة
      elevation: 3, // إضافة ظل خفيف للبطاقة
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // زوايا دائرية للبطاقة
      clipBehavior: Clip.antiAlias, // لضمان أن المحتوى لا يتجاوز الحدود الدائرية
      child: InkWell( // لجعل البطاقة قابلة للنقر وإظهار تأثير بصري
        onTap: () {
          // --- التحقق من وجود المعرف قبل الانتقال ---
          if (doctorId == null) {
            print("[AllTopRatedDoctorsPage] Error: Doctor ID is null for '$name'. Cannot navigate.");
            // عرض رسالة للمستخدم تشير إلى وجود مشكلة
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('خطأ: لا يمكن عرض تفاصيل هذا الطبيب الآن (المعرف مفقود).'), backgroundColor: Colors.red[700])
            );
            return; // منع الانتقال إذا لم يكن هناك معرف
          }

          // طباعة البيانات التي سيتم تمريرها (للتشخيص)
          print("[AllTopRatedDoctorsPage] Navigating to details for ID: $doctorId");

          // التأكد من أن السياق (الصفحة) لا يزال موجودًا قبل محاولة الانتقال
          if (!context.mounted) return;

          // --- تنفيذ الانتقال وتمرير البيانات الصحيحة ---
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorDetailPage(
                // تمرير البيانات الكاملة للطبيب إلى صفحة التفاصيل
                doctorData: doctorDataMap,
                // تمرير دالة رد الاتصال للتقييم التي تم استقبالها
                onRateSubmitted: onRateDoctor,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12), // جعل تأثير النقر يطابق زوايا البطاقة
        child: Padding(
          padding: const EdgeInsets.all(12.0), // حشو داخلي لمحتوى البطاقة
          child: Row( // ترتيب العناصر أفقيًا: صورة | معلومات | سهم
            children: [
              // --- صورة الطبيب ---
              ClipRRect( // لجعل زوايا الصورة دائرية
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  imagePath, // استخدام مسار الصورة المستخرج
                  height: 75, // تحديد ارتفاع الصورة
                  width: 75,  // تحديد عرض الصورة
                  fit: BoxFit.cover, // كيفية ملء الصورة للمساحة المحددة
                  // --- معالج الخطأ في حال فشل تحميل الصورة ---
                  errorBuilder: (context, error, stackTrace) {
                    print("[AllTopRatedDoctorsPage] Error loading image '$imagePath' for '$name': $error");
                    // عرض أيقونة بديلة في حالة الخطأ
                    return Container(
                      height: 75, width: 75,
                      decoration: BoxDecoration(
                        color: Colors.grey[200], // خلفية رمادية
                        borderRadius: BorderRadius.circular(8.0), // نفس دائرية الزوايا
                      ),
                      child: Icon(Icons.person_outline, color: Colors.grey[600], size: 40), // أيقونة شخص
                    );
                  },
                ),
              ),
              SizedBox(width: 15), // مسافة بين الصورة والنصوص

              // --- معلومات الطبيب (الاسم، التخصص، التقييم) ---
              Expanded( // لجعل هذا العمود يأخذ كل المساحة الأفقية المتبقية
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // محاذاة النصوص للبداية
                  children: [
                    // اسم الطبيب
                    Text(
                      name,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xff363636)),
                      maxLines: 1, // قصر الاسم على سطر واحد
                      overflow: TextOverflow.ellipsis, // إظهار "..." إذا كان الاسم طويلاً
                    ),
                    SizedBox(height: 5), // مسافة بين الاسم والتخصص
                    // تخصص الطبيب
                    Text(
                      speciality,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      maxLines: 1, // قصر التخصص على سطر واحد
                      overflow: TextOverflow.ellipsis, // إظهار "..." إذا كان التخصص طويلاً
                    ),
                    SizedBox(height: 6), // مسافة بين التخصص والتقييم
                    // --- عرض التقييم المحسوب ---
                    Row(
                      children: [
                        Icon(
                            Icons.star_rounded,
                            // لون النجمة يعتمد على وجود تقييم فعلي
                            color: averageRating > 0 ? Colors.amber : Colors.grey[400],
                            size: 18
                        ),
                        SizedBox(width: 4), // مسافة صغيرة
                        Text(
                          // عرض قيمة المتوسط مقربة لرقم عشري واحد أو رسالة بديلة
                            averageRating > 0 ? averageRating.toStringAsFixed(1) : 'لا تقييم',
                            style: TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500)
                        ),
                        // يمكنك إضافة عدد التقييمات هنا إذا أردت
                        // Text(' (${ratings?.length ?? 0})', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                      ],
                    ),
                  ],
                ),
              ),

              // --- أيقونة السهم للدلالة على إمكانية النقر ---
              Icon(Icons.chevron_right, color: Colors.grey[400], size: 28),
            ],
          ),
        ),
      ),
    );
  } // نهاية دالة _buildDoctorCard

  // --- ويدجت لعرض بطاقة خطأ (في حال فشل بناء بطاقة طبيب) ---
  Widget _buildErrorCard(int index, Object error) {
    return Card(
      color: Colors.red[50], // خلفية حمراء فاتحة
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.warning_amber_rounded, color: Colors.red[700], size: 30),
        title: Text('خطأ في عرض الطبيب رقم ${index + 1}', style: TextStyle(color: Colors.red[900], fontWeight: FontWeight.bold)),
        subtitle: Text('حدث خطأ غير متوقع. حاول لاحقًا.\n${error.toString().split('\n').first}', // عرض الجزء الأول من الخطأ فقط
            style: TextStyle(color: Colors.red[800], fontSize: 12)),
        dense: true, // جعل البطاقة أصغر قليلاً
      ),
    );
  }

} // نهاية كلاس AllTopRatedDoctorsPage