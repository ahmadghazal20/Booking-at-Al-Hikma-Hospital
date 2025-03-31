// مسار الملف: lib/views/doctor/doctor_detail_page.dart

import 'dart:convert'; // <-- لاستخدام jsonEncode/Decode
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <-- لحفظ الموعد
import 'package:table_calendar/table_calendar.dart';

// !! تم إزالة استيراد AppointmentPage لأننا نستخدم ديالوج التأكيد ونعود للخلف !!

class DoctorDetailPage extends StatefulWidget {
  final Map<String, dynamic> doctorData;
  final void Function(String doctorId, double rating, String comment) onRateSubmitted;

  const DoctorDetailPage({
    Key? key,
    required this.doctorData,
    required this.onRateSubmitted,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DoctorDetailState();
}

class _DoctorDetailState extends State<DoctorDetailPage> {
  // --- تعريف ألوان الحكمة ---
  static const Color alhikmaGreen = Color(0xFF00C853);
  static const Color alhikmaRed = Color(0xFFD50000);
  static const Color alhikmaGrey = Color(0xFFA0A0A0);
  static const Color darkTextColor = Color(0xFF333333);
  static const Color whiteColor = Colors.white;
  static const Color pageBackgroundColor = Color(0xFFFAFAFA);
  static final Color unselectedSlotColor = Colors.grey.shade200;
  static final Color unselectedBorderColor = Colors.grey.shade300;

  // --- متغيرات الحالة للتقويم والمواعيد ---
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  TimeOfDay? _selectedTimeSlot;
  List<TimeOfDay> _availableTimeSlots = [];

  // --- Controller للتعليق ---
  final TextEditingController _commentController = TextEditingController();
  double _currentRating = 0.0; // لتقييم الحوار

  // --- Getters للتحقق من الجدول ---
  bool get _hasSchedule => widget.doctorData['schedule'] != null;
  Map<String, dynamic>? get _schedule => widget.doctorData['schedule'] as Map<String, dynamic>?;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ar', null).then((_) {
      if (mounted) {
        setState(() {
          DateTime today = DateUtils.dateOnly(DateTime.now());
          _selectedDay = today;
          _focusedDay = today;
          if (_isDayAvailable(_selectedDay!)) {
            _generateAvailableTimeSlots(_selectedDay!);
          } else {
            _availableTimeSlots = [];
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // --- دالة حساب متوسط التقييم (كما هي) ---
  double _calculateAverageRating(List<dynamic>? ratings) {
    if (ratings == null || ratings.isEmpty) return 0.0;
    double sum = 0;
    int validRatingsCount = 0;
    for (var rating in ratings) {
      if (rating is Map && rating.containsKey('score') && rating['score'] is num) {
        try {
          sum += (rating['score'] as num).toDouble();
          validRatingsCount++;
        } catch (e) { /* Handle potential errors */ }
      }
    }
    return validRatingsCount > 0 ? (sum / validRatingsCount) : 0.0;
  }

  // --- دالة إظهار ديالوج التقييم (كما هي) ---
  void _showRatingDialog(String doctorId) {
    _currentRating = 0.0;
    _commentController.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('تقييم الطبيب', textAlign: TextAlign.center),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('ما هو تقييمك لـ ${widget.doctorData['name'] ?? 'الطبيب'}؟'),
                  SizedBox(height: 15),
                  RatingBar.builder(
                    initialRating: _currentRating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
                    onRatingUpdate: (rating) {
                      setDialogState(() { _currentRating = rating; });
                    },
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'أضف تعليقك (اختياري)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('إلغاء', style: TextStyle(color: alhikmaRed)),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: alhikmaGreen),
                child: Text('إرسال التقييم', style: TextStyle(color: whiteColor)),
                onPressed: () {
                  if (_currentRating > 0) {
                    widget.onRateSubmitted(doctorId, _currentRating, _commentController.text.trim());
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('شكراً لتقييمك!'), backgroundColor: alhikmaGreen),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('الرجاء تحديد عدد النجوم للتقييم.'), backgroundColor: alhikmaRed),
                    );
                  }
                },
              ),
            ],
          );
        });
      },
    );
  }

  // --- دالة التحقق من اليوم المتاح (كما هي) ---
  bool _isDayAvailable(DateTime day) {
    if (!_hasSchedule) return false;
    final schedule = _schedule!;
    final workingDays = schedule['workingDays'] as List<int>? ?? [];
    return workingDays.contains(day.weekday) && !day.isBefore(DateUtils.dateOnly(DateTime.now()));
  }

  // --- دالة توليد الأوقات المتاحة (كما هي) ---
  void _generateAvailableTimeSlots(DateTime day) {
    // ملاحظة: هذا لا يتحقق من المواعيد المحجوزة مسبقًا حاليًا
    if (!_hasSchedule || !_isDayAvailable(day)) {
      if(mounted) setState(() { _availableTimeSlots = []; _selectedTimeSlot = null; });
      return;
    }
    final schedule = _schedule!;
    final List<TimeOfDay> slots = [];
    final TimeOfDay startTime = schedule['startTime'] as TimeOfDay;
    final TimeOfDay endTime = schedule['endTime'] as TimeOfDay;
    final Duration slotDuration = schedule['slotDuration'] as Duration;
    final DateTime now = DateTime.now();
    DateTime currentSlotStartDateTime = DateTime(day.year, day.month, day.day, startTime.hour, startTime.minute);
    final DateTime scheduleEndDateTime = DateTime(day.year, day.month, day.day, endTime.hour, endTime.minute);

    while (currentSlotStartDateTime.add(slotDuration).isBefore(scheduleEndDateTime) || currentSlotStartDateTime.add(slotDuration).isAtSameMomentAs(scheduleEndDateTime)) {
      if (!currentSlotStartDateTime.isBefore(now)) {
        // هنا يجب إضافة التحقق من المواعيد المحجوزة في المستقبل
        slots.add(TimeOfDay.fromDateTime(currentSlotStartDateTime));
      }
      currentSlotStartDateTime = currentSlotStartDateTime.add(slotDuration);
    }
    if(mounted) setState(() { _availableTimeSlots = slots; _selectedTimeSlot = null; });
  }

  // --- *** تعديل: دالة لحفظ وتأكيد حجز الموعد *** ---
  Future<void> _bookAppointment() async { // <-- جعلها async
    if (_selectedDay == null || _selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('الرجاء اختيار اليوم والوقت أولاً.'), backgroundColor: Colors.orange),
      );
      return;
    }

    final DateTime appointmentDateTime = DateTime(
      _selectedDay!.year, _selectedDay!.month, _selectedDay!.day,
      _selectedTimeSlot!.hour, _selectedTimeSlot!.minute,
    );
    final String formattedDate = DateFormat.yMMMMEEEEd('ar').format(appointmentDateTime);
    final String formattedTime = DateFormat.jm('ar').format(appointmentDateTime);

    // --- بداية كود حفظ الموعد في SharedPreferences ---
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      // *** استخدام المفتاح الصحيح ***
      final List<String> existingAppointmentsJson = prefs.getStringList('userAppointments') ?? [];

      // إنشاء بيانات الموعد الجديد
      final newAppointmentData = {
        'doctorName': widget.doctorData['name'] ?? 'اسم غير معروف',
        'doctorSpeciality': widget.doctorData['speciality'] ?? 'تخصص غير معروف',
        'doctorImage': widget.doctorData['image'] as String?, // اسم الحقل كان image
        'appointmentDateTime': appointmentDateTime.toIso8601String(), // حفظ التاريخ والوقت
      };
      final String newAppointmentJson = jsonEncode(newAppointmentData);

      // ** تحقق مهم للمستقبل: منع حجز نفس الموعد مرتين **
      // قبل الإضافة، يجب فك تشفير existingAppointmentsJson والمقارنة

      existingAppointmentsJson.add(newAppointmentJson); // إضافة الموعد الجديد
      // *** استخدام المفتاح الصحيح ***
      await prefs.setStringList('userAppointments', existingAppointmentsJson);
      print("Appointment saved successfully!");
      // --- نهاية كود حفظ الموعد ---

      if (!mounted) return; // التحقق قبل عرض الحوار
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('تأكيد الحجز'),
          content: Text(
              'تم حجز موعدك بنجاح مع ${widget.doctorData['name']}\n'
                  'يوم $formattedDate\n'
                  'الساعة $formattedTime'
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // أغلق الحوار
                // *** العودة للصفحة السابقة بعد إغلاق الحوار ***
                if (mounted) Navigator.pop(context);
              },
              child: Text('حسناً'),
            ),
          ],
        ),
      );

    } catch (e) {
      print("Error saving appointment: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('حدث خطأ أثناء حفظ الموعد.'), backgroundColor: alhikmaRed)
        );
      }
    }
  }
  // --- *** نهاية دالة حجز الموعد المعدلة *** ---


  @override
  Widget build(BuildContext context) {
    // استخلاص البيانات من الويدجت (كما هي)
    final Map<String, dynamic> doctorData = widget.doctorData;
    final String doctorId = doctorData['id'] as String? ?? '';
    final String doctorName = doctorData['name'] as String? ?? 'اسم الدكتور';
    final String doctorSpeciality = doctorData['speciality'] as String? ?? 'تخصص الدكتور';
    final String doctorImage = doctorData['image'] as String? ?? 'assets/doctor_placeholder.png';
    final List<dynamic>? ratings = doctorData['ratings'] as List<dynamic>?;
    final double averageRating = _calculateAverageRating(ratings);
    final int ratingCount = ratings?.length ?? 0;

    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        title: Text(doctorName, style: TextStyle(color: whiteColor)),
        centerTitle: true,
        backgroundColor: alhikmaGreen,
        elevation: 2.0,
        leading: BackButton(color: whiteColor),
        iconTheme: IconThemeData(color: whiteColor),
        actions: [
          IconButton(
            icon: Icon(Icons.star_outline_rounded),
            tooltip: 'تقييم الطبيب',
            onPressed: () {
              if (doctorId.isEmpty) { /* ... رسالة خطأ ... */ return; }
              _showRatingDialog(doctorId);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. قسم معلومات الطبيب العلوي (كما هو) ---
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(20, 15, 20, 25),
              decoration: BoxDecoration(
                  color: alhikmaGreen,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(35),
                      bottomRight: Radius.circular(35))),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: whiteColor.withOpacity(0.9),
                    backgroundImage: AssetImage(doctorImage),
                    onBackgroundImageError: (e, s) { /* ... */ },
                    child: AssetImage(doctorImage).assetName.contains('placeholder')
                        ? Icon(Icons.person, size: 60, color: alhikmaGrey)
                        : null,
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text( doctorName, style: TextStyle(color: whiteColor, fontSize: 22, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis, ),
                        SizedBox(height: 8),
                        Text( doctorSpeciality, style: TextStyle(color: whiteColor.withOpacity(0.85), fontSize: 16), maxLines: 2, overflow: TextOverflow.ellipsis, ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Icon( Icons.star_rounded, color: averageRating > 0 ? Colors.amber : alhikmaGrey.withOpacity(0.7), size: 18 ),
                            SizedBox(width: 4),
                            if (averageRating > 0)
                              Text( averageRating.toStringAsFixed(1), style: TextStyle( color: whiteColor, fontSize: 15, fontWeight: FontWeight.bold,),)
                            else
                              Text( 'لا تقييمات', style: TextStyle( color: whiteColor.withOpacity(0.8), fontSize: 14), ),
                            SizedBox(width: 5),
                            if (ratingCount > 0)
                              Text( '($ratingCount تقييمات)', style: TextStyle( color: whiteColor.withOpacity(0.7), fontSize: 13,),),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),

            // --- 2. قسم الحجز (عرض شرطي - كما هو) ---
            if (_hasSchedule) ...[
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 30.0, bottom: 10),
                child: Text( 'اختر اليوم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkTextColor),),
              ),
              Card(
                margin: EdgeInsets.symmetric(horizontal: 15),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: TableCalendar(
                    locale: 'ar_SA',
                    firstDay: DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                    lastDay: DateTime.utc(DateTime.now().year + 1, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    enabledDayPredicate: _isDayAvailable,
                    onDaySelected: (selectedDay, focusedDay) {
                      if (!isSameDay(_selectedDay, selectedDay)) {
                        if (mounted) setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                          _calendarFormat = CalendarFormat.month;
                        });
                        _generateAvailableTimeSlots(selectedDay);
                      }
                    },
                    onFormatChanged: (format) {
                      if (_calendarFormat != format) {
                        if (mounted) setState(() { _calendarFormat = format; });
                      }
                    },
                    onPageChanged: (focusedDay) { _focusedDay = focusedDay; },
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(color: alhikmaGreen.withOpacity(0.5), shape: BoxShape.circle,),
                      selectedDecoration: BoxDecoration(color: alhikmaGreen, shape: BoxShape.circle,),
                      disabledTextStyle: TextStyle(color: Theme.of(context).disabledColor.withOpacity(0.4)),
                      weekendTextStyle: TextStyle(color: alhikmaRed.withOpacity(0.8)),
                      outsideDaysVisible: false,
                    ),
                    headerStyle: HeaderStyle(
                      titleCentered: true,
                      formatButtonVisible: true,
                      formatButtonShowsNext: false,
                      formatButtonDecoration: BoxDecoration( border: Border.all(color: alhikmaGrey), borderRadius: BorderRadius.circular(20)),
                      formatButtonTextStyle: TextStyle(color: alhikmaGrey, fontSize: 13),
                      titleTextStyle: TextStyle(fontSize: 17.0, color: Theme.of(context).textTheme.bodyLarge?.color),
                      leftChevronIcon: Icon(Icons.chevron_left, color: alhikmaGrey),
                      rightChevronIcon: Icon(Icons.chevron_right, color: alhikmaGrey),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 25.0),
                child: Text(
                  _selectedDay != null
                      ? 'الأوقات المتاحة ليوم ${DateFormat.yMMMMEEEEd('ar').format(_selectedDay!)}'
                      : 'اختر يومًا لعرض الأوقات المتاحة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkTextColor),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0, bottom: 20.0),
                child: _selectedDay == null || !_isDayAvailable(_selectedDay!)
                    ? Center(child: Text('اختر يوم عمل صالح لعرض الأوقات', style: TextStyle(color: alhikmaGrey)))
                    : _availableTimeSlots.isEmpty
                    ? Center(child: Text('لا توجد أوقات متاحة لهذا اليوم', style: TextStyle(color: alhikmaGrey)))
                    : Wrap(
                  spacing: 10.0, runSpacing: 10.0,
                  children: _availableTimeSlots.map((slot) {
                    final isSelected = _selectedTimeSlot == slot;
                    final displayTime = DateFormat.jm('ar').format(DateTime(
                        _selectedDay!.year, _selectedDay!.month, _selectedDay!.day, slot.hour, slot.minute));
                    return ChoiceChip(
                      avatar: Icon( Icons.access_time_rounded, color: isSelected ? whiteColor : alhikmaGrey, size: 16, ),
                      label: Text(displayTime),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (mounted) setState(() { _selectedTimeSlot = selected ? slot : null; });
                      },
                      selectedColor: alhikmaRed,
                      labelStyle: TextStyle( color: isSelected ? whiteColor : darkTextColor, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, ),
                      backgroundColor: unselectedSlotColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      side: BorderSide(color: isSelected ? alhikmaRed.withOpacity(0.5) : unselectedBorderColor),
                      elevation: isSelected ? 3 : 0,
                    );
                  }).toList(),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 25.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: alhikmaGreen, foregroundColor: whiteColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 5,
                    disabledBackgroundColor: alhikmaGreen.withOpacity(0.5), disabledForegroundColor: whiteColor.withOpacity(0.7),
                  ),
                  // *** استدعاء الدالة المعدلة ***
                  onPressed: (_selectedDay != null && _selectedTimeSlot != null) ? _bookAppointment : null,
                  child: Text(
                    (_selectedDay != null && _selectedTimeSlot != null) ? 'تأكيد الحجز' : 'اختر يومًا ووقتًا للحجز',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
              ),

            ] else ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
                child: Center(
                  child: Text( 'الحجز الإلكتروني غير متاح لهذا الطبيب حاليًا.', style: TextStyle(fontSize: 17, color: alhikmaGrey), textAlign: TextAlign.center, ),
                ),
              ),
            ],
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}