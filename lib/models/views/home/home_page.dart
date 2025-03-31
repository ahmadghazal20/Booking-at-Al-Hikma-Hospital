
import 'package:doctor_appointment_ui/models/views/auth/login_page..dart';
import 'package:doctor_appointment_ui/views/profile/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../doctor/doctor_detail_page.dart';
import '../appointment/my_appointments_page.dart';
import '../doctor/doctor_list_page.dart';
import '../profile/profile_page.dart';
import '../doctor/all_top_rated_doctors_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  // --- متغيرات الحالة وبيانات الأطباء الأولية كما هي ---
  String userName = 'المستخدم';
  String userEmail = '';
  String userAge = '';
  String userGender = '';
  bool _isLoadingUserData = true;

  final List<Map<String, dynamic>> _initialEyeDoctorsData = [
    { 'name': 'د. أحمد السيد علي', 'speciality': 'استشاري عيون', 'image': 'assets/eye-exam.png','schedule': {
      'workingDays': [DateTime.monday, DateTime.tuesday, DateTime.wednesday, DateTime.thursday, DateTime.friday], // كل الأيام عدا السبت والأحد
      'startTime': TimeOfDay(hour: 8, minute: 30),
      'endTime': TimeOfDay(hour: 13, minute: 0),
      'slotDuration': Duration(minutes: 20),
      }
    },
    { 'name': 'د. كرامة الجمعة', 'speciality': 'أخصائي عيون', 'image': 'assets/optometrist.png','schedule': {
      'workingDays': [DateTime.sunday, DateTime.monday, DateTime.tuesday], // الأحد, الإثنين, الثلاثاء
      'startTime': TimeOfDay(hour: 9, minute: 0),  // 9:00 صباحًا
      'endTime': TimeOfDay(hour: 16, minute: 0), // 4:00 مساءً
      'slotDuration': Duration(minutes: 45),
    } },
    { 'name': 'د. مريم المحمد', 'speciality': 'أخصائي عيون', 'image': 'assets/optometrist.png','schedule': {
      'workingDays': [DateTime.monday, DateTime.tuesday, DateTime.wednesday, DateTime.thursday, DateTime.friday], // كل الأيام عدا السبت والأحد
      'startTime': TimeOfDay(hour: 8, minute: 30),
      'endTime': TimeOfDay(hour: 13, minute: 0),
      'slotDuration': Duration(minutes: 20),
    } },
    { 'name': 'د. سالم ارديس', 'speciality': 'طبيب عيون', 'image': 'assets/eye-exam.png','schedule': {
      'workingDays': [DateTime.monday, DateTime.tuesday, DateTime.wednesday, DateTime.thursday, DateTime.friday], // كل الأيام عدا السبت والأحد
      'startTime': TimeOfDay(hour: 8, minute: 30),
      'endTime': TimeOfDay(hour: 13, minute: 0),
      'slotDuration': Duration(minutes: 20),
    } },
    { 'name': 'د. منصور اليوسق', 'speciality': 'طبيب عيون', 'image': 'assets/eye-exam.png','schedule': {
      'workingDays': [DateTime.monday, DateTime.tuesday, DateTime.wednesday, DateTime.thursday, DateTime.friday], // كل الأيام عدا السبت والأحد
      'startTime': TimeOfDay(hour: 8, minute: 30),
      'endTime': TimeOfDay(hour: 13, minute: 0),
      'slotDuration': Duration(minutes: 20),
    } },
    { 'name': 'د. ايمن جمالو', 'speciality': 'طبيب عيون', 'image': 'assets/eye-exam.png','schedule': {
      'workingDays': [DateTime.monday, DateTime.tuesday, DateTime.wednesday, DateTime.thursday, DateTime.friday], // كل الأيام عدا السبت والأحد
      'startTime': TimeOfDay(hour: 8, minute: 30),
      'endTime': TimeOfDay(hour: 13, minute: 0),
      'slotDuration': Duration(minutes: 20),
    } },
    { 'name': 'د. جهاد رحال', 'speciality': 'طبيب عيون', 'image': 'assets/eye-exam.png','schedule': {
      'workingDays': [DateTime.monday, DateTime.tuesday, DateTime.wednesday, DateTime.thursday, DateTime.friday], // كل الأيام عدا السبت والأحد
      'startTime': TimeOfDay(hour: 8, minute: 30),
      'endTime': TimeOfDay(hour: 13, minute: 0),
      'slotDuration': Duration(minutes: 20),
    } },
  ];

  final List<Map<String, dynamic>> _initialEarDoctorsData = [
    { 'name': 'د. علي السيد', 'speciality': 'استشاري أنف وأذن وحنجرة', 'image': 'assets/checkup.png','schedule': {
      'workingDays': [DateTime.monday, DateTime.tuesday, DateTime.wednesday, DateTime.thursday, DateTime.friday], // كل الأيام عدا السبت والأحد
      'startTime': TimeOfDay(hour: 8, minute: 30),
      'endTime': TimeOfDay(hour: 13, minute: 0),
      'slotDuration': Duration(minutes: 20),
    } },
    { 'name': 'د. ايمن قدور', 'speciality': 'طبيب أنف وأذن وحنجرة', 'image': 'assets/checkup.png','schedule': {
      'workingDays': [DateTime.monday, DateTime.tuesday, DateTime.wednesday, DateTime.thursday, DateTime.friday], // كل الأيام عدا السبت والأحد
      'startTime': TimeOfDay(hour: 8, minute: 30),
      'endTime': TimeOfDay(hour: 13, minute: 0),
      'slotDuration': Duration(minutes: 20),
    } },
    { 'name': 'د. محمد الاحمد', 'speciality': 'طبيب أنف وأذن وحنجرة', 'image': 'assets/checkup.png', 'schedule': {
      'workingDays': [DateTime.monday, DateTime.tuesday, DateTime.wednesday, DateTime.thursday, DateTime.friday], // كل الأيام عدا السبت والأحد
      'startTime': TimeOfDay(hour: 8, minute: 30),
      'endTime': TimeOfDay(hour: 13, minute: 0),
      'slotDuration': Duration(minutes: 20),
    }},
    { 'name': 'د. مريم رام الله', 'speciality': 'أخصائية أنف وأذن وحنجرة', 'image': 'assets/listening.png','schedule': {
      'workingDays': [DateTime.monday, DateTime.tuesday, DateTime.wednesday, DateTime.thursday, DateTime.friday], // كل الأيام عدا السبت والأحد
      'startTime': TimeOfDay(hour: 8, minute: 30),
      'endTime': TimeOfDay(hour: 13, minute: 0),
      'slotDuration': Duration(minutes: 20),
    } },
    { 'name': 'د.  فاطمة العيس', 'speciality': 'أخصائية أنف وأذن وحنجرة', 'image': 'assets/listening.png', 'schedule': {
      'workingDays': [DateTime.monday, DateTime.tuesday, DateTime.wednesday, DateTime.thursday, DateTime.friday], // كل الأيام عدا السبت والأحد
      'startTime': TimeOfDay(hour: 8, minute: 30),
      'endTime': TimeOfDay(hour: 13, minute: 0),
      'slotDuration': Duration(minutes: 20),
    }},
    { 'name': 'د. فاطمة غزال', 'speciality': 'أخصائي أنف وأذن وحنجرة', 'image': 'assets/listening.png','schedule': {
      'workingDays': [DateTime.monday, DateTime.tuesday, DateTime.wednesday, DateTime.thursday, DateTime.friday], // كل الأيام عدا السبت والأحد
      'startTime': TimeOfDay(hour: 8, minute: 30),
      'endTime': TimeOfDay(hour: 13, minute: 0),
      'slotDuration': Duration(minutes: 20),
    } },
  ];

  // --- قوائم حالة الأطباء والبحث كما هي ---
  List<Map<String, dynamic>> eyeDoctors = [];
  List<Map<String, dynamic>> earDoctors = [];
  List<Map<String, dynamic>> _allDoctors = [];
  String _searchQuery = '';
  List<Map<String, dynamic>> _searchResults = [];

  // --- دالة topRatedDoctors كما هي ---
  List<Map<String, dynamic>> get topRatedDoctors {
    if (_allDoctors.isEmpty) {
      return [];
    }
    List<Map<String, dynamic>> combined = List.from(_allDoctors);
    try {
      combined.sort((a, b) {
        double ratingA = _calculateAverageRating(a['ratings'] as List<dynamic>?);
        double ratingB = _calculateAverageRating(b['ratings'] as List<dynamic>?);
        return ratingB.compareTo(ratingA);
      });
      return combined.take(3).toList();
    } catch (e, stackTrace) {
      print("[Error in topRatedDoctors sort]: $e\n$stackTrace");
      return _allDoctors.take(3).toList();
    }
  }

  // --- دالة initState كما هي ---
  @override
  void initState() {
    super.initState();
    print("[Init] Starting HomePage initState...");
    _loadUserData();

    try {
      // تهيئة eyeDoctors بإضافة id و ratings
      eyeDoctors = _initialEyeDoctorsData.map((doc) => {
        ...doc,
        'id': '${doc['name']}_${doc['speciality']}'.hashCode.toString(),
        'ratings': <Map<String, dynamic>>[]
      }).toList();
      print("[Init] Initialized ${eyeDoctors.length} eye doctors.");

      // تهيئة earDoctors بإضافة id و ratings
      earDoctors = _initialEarDoctorsData.map((doc) => {
        ...doc,
        'id': '${doc['name']}_${doc['speciality']}'.hashCode.toString(),
        'ratings': <Map<String, dynamic>>[]
      }).toList();
      print("[Init] Initialized ${earDoctors.length} ear doctors.");

      // بناء القائمة الرئيسية _allDoctors
      _allDoctors = [...eyeDoctors, ...earDoctors];
      print("[Init] Combined _allDoctors count: ${_allDoctors.length}");
      if(_allDoctors.isNotEmpty) {
        // print("[Init] First doctor sample in _allDoctors: ${_allDoctors.first}");
      }

      // تهيئة نتائج البحث بالأطباء المقترحين
      _searchResults = topRatedDoctors;
      print("[Init] Initial search results (top rated): ${_searchResults.length}");
      if (_searchResults.isNotEmpty) {
        // print("[Init] First top rated doctor: ${_searchResults.first}");
      }

    } catch (e, stackTrace) {
      print("[Error in initState data processing]: $e\n$stackTrace");
      eyeDoctors = [];
      earDoctors = [];
      _allDoctors = [];
      _searchResults = [];
    }

    print("[Init] HomePage initState completed.");
  }

  // --- دوال _loadUserData, _logout, _searchDoctors, _addRating, _calculateAverageRating كما هي ---
  Future<void> _loadUserData() async {
    setState(() => _isLoadingUserData = true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // استخدام mounted للتحقق قبل تحديث الحالة
      if (mounted) {
        setState(() {
          userName = prefs.getString('userName') ?? 'المستخدم';
          userEmail = prefs.getString('userEmail') ?? 'لا يوجد بريد إلكتروني';
          userAge = prefs.getString('userAge') ?? 'غير محدد';
          userGender = prefs.getString('userGender') ?? 'غير محدد';
          _isLoadingUserData = false;
        });
      }
    } catch (e) {
      print("[Error loading user data in HomePage]: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ في تحميل بيانات المستخدم.'), backgroundColor: Colors.red[600]));
        setState(() { _isLoadingUserData = false; });
      }
    }
  }

  Future<void> _logout() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      // إزالة بيانات المستخدم عند الخروج
      await prefs.remove('userName');
      await prefs.remove('userEmail');
      await prefs.remove('userAge');
      await prefs.remove('userGender');
      // التحقق من mounted قبل الانتقال
      if (mounted) {
        // تأكد من استيراد LoginPage بشكل صحيح
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
              (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      print("[Error during logout]: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('حدث خطأ أثناء تسجيل الخروج.'), backgroundColor: Colors.red[600]));
      }
    }
  }

  void _searchDoctors(String query) {
    final searchQueryLower = query.toLowerCase().trim();
    print("[Search] Query changed: '$searchQueryLower'");
    setState(() {
      _searchQuery = query;
      if (searchQueryLower.isEmpty) {
        print("[Search] Query is empty, reverting to top rated doctors.");
        _searchResults = topRatedDoctors; // عرض المقترحين إذا كان البحث فارغًا
      } else {
        print("[Search] Filtering ${_allDoctors.length} doctors for '$searchQueryLower'.");
        if (_allDoctors.isEmpty) {
          print("[Search Warning] _allDoctors list is empty. Cannot search.");
          _searchResults = [];
          return;
        }
        _searchResults = _allDoctors.where((doctor) {
          final name = doctor['name'];
          final speciality = doctor['speciality'];
          bool nameMatch = false;
          if (name != null && name is String) {
            nameMatch = name.toLowerCase().contains(searchQueryLower);
          }
          bool specialityMatch = false;
          if (speciality != null && speciality is String) {
            specialityMatch = speciality.toLowerCase().contains(searchQueryLower);
          }
          return nameMatch || specialityMatch;
        }).toList();
        print("[Search] Found ${_searchResults.length} results.");
      }
    });
  }

  void _addRating(String doctorId, double rating, String comment) {
    if (!mounted) return;
    print("[Rating] Attempting to add rating for Doctor ID: $doctorId");
    setState(() {
      int doctorIndex = _allDoctors.indexWhere((doc) => doc['id'] == doctorId);
      if (doctorIndex != -1) {
        if (_allDoctors[doctorIndex]['ratings'] is! List) {
          print("[Rating Error] 'ratings' for Doctor ID $doctorId is not a List. Initializing.");
          _allDoctors[doctorIndex]['ratings'] = <Map<String, dynamic>>[];
        }
        try {
          (_allDoctors[doctorIndex]['ratings'] as List).add({
            'score': rating,
            'comment': comment.isEmpty ? null : comment,
            'timestamp': DateTime.now().toIso8601String(),
          });
          print("[Rating] Successfully added rating for $doctorId. New rating count: ${(_allDoctors[doctorIndex]['ratings'] as List).length}");

          // تحديث القوائم المنفصلة (اختياري إذا كنت لا تزال تستخدمها)
          int eyeIndex = eyeDoctors.indexWhere((doc) => doc['id'] == doctorId);
          if (eyeIndex != -1) eyeDoctors[eyeIndex] = _allDoctors[doctorIndex];
          int earIndex = earDoctors.indexWhere((doc) => doc['id'] == doctorId);
          if (earIndex != -1) earDoctors[earIndex] = _allDoctors[doctorIndex];

          // تحديث نتائج البحث أو المقترحين
          if (_searchQuery.isNotEmpty) {
            print("[Rating] Re-applying search filter after rating update.");
            _searchDoctors(_searchQuery);
          } else {
            print("[Rating] Updating top rated list after rating update.");
            _searchResults = topRatedDoctors;
          }
        } catch (e, stackTrace) {
          print("[Rating Error] Failed to add rating map to list for $doctorId: $e\n$stackTrace");
        }
      } else {
        print("[Rating Error] Could not find doctor with ID '$doctorId' in _allDoctors to add rating.");
      }
    });
  }

  double _calculateAverageRating(List<dynamic>? ratings) {
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

  // --- بناء واجهة المستخدم الرئيسية ---
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    print("[Build] HomePage build method called. Search query: '$_searchQuery'");

    return Scaffold(
      appBar: AppBar(
        title: Text('الصفحة الرئيسية'),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor?.withOpacity(0.8),
        elevation: 0,
        actions: [
          IconButton( tooltip: 'تغيير المظهر', onPressed: () => themeProvider.toggleTheme(!themeProvider.isDarkMode), icon: Icon(themeProvider.isDarkMode ? Icons.brightness_7_outlined : Icons.brightness_4_outlined), ),
          IconButton( tooltip: 'الإشعارات', icon: Icon(Icons.notifications_none_rounded), onPressed: () { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('الإشعارات غير مفعّلة بعد.'))); }),
          IconButton( tooltip: 'مواعيـدي', icon: Icon(Icons.calendar_today_outlined), onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => MyAppointmentsPage())); }),
        ],
      ),
      drawer: Drawer( /* ... كود Drawer كما هو ... */
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: theme.primaryColor,),
              child: _isLoadingUserData
                  ? Center(child: CircularProgressIndicator(color: theme.colorScheme.onPrimary))
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(radius: 30, backgroundColor: theme.colorScheme.onPrimary, child: Icon(Icons.person, color: theme.primaryColor, size: 40),),
                  SizedBox(height: 10),
                  Text(userName, style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 18, fontWeight: FontWeight.bold ),),
                  SizedBox(height: 5),
                  Text(userEmail, style: TextStyle(color: theme.colorScheme.onPrimary.withOpacity(0.8), fontSize: 14,),),
                ],
              ),
            ),
            // معلومات المستخدم
            ListTile( leading: Icon(Icons.person_outline), title: Text('الاسم: $userName'), ),
            ListTile( leading: Icon(Icons.email_outlined), title: Text('البريد: $userEmail'), ),
            ListTile( leading: Icon(Icons.cake_outlined), title: Text('العمر: $userAge'), ),
            ListTile( leading: Icon(Icons.accessibility_new_outlined), title: Text('الجنس: $userGender'), ),
            Divider(thickness: 0.8),
            // أزرار الإجراءات
            ListTile( leading: Icon(Icons.edit_outlined, color: theme.primaryColor), title: Text('تعديل الملف الشخصي', style: TextStyle(color: theme.primaryColor)), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage())); }, ),
            ListTile( leading: Icon(Icons.exit_to_app, color: theme.colorScheme.error), title: Text('تسجيل الخروج', style: TextStyle(color: theme.colorScheme.error)), onTap: () { Navigator.pop(context); _logout(); }, ),
          ],
        ),
      ),
      body: Container( // --- Container للخلفية ---
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/hospital.png"),
            fit: BoxFit.cover,
            opacity: 0.1,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _loadUserData, // تحديث بيانات المستخدم عند السحب
          color: theme.primaryColor,
          backgroundColor: theme.cardColor,
          child: SingleChildScrollView( // <--- هذا مهم ويضمن قابلية الصفحة للتمرير
            physics: AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- رسالة الترحيب ---
                Text( _isLoadingUserData ? "أهلاً بك!" : "أهلاً بك، $userName!", style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold), ),
                SizedBox(height: 5),
                Text( "ابحث عن طبيبك واحجز موعدك بسهولة", style: theme.textTheme.titleMedium?.copyWith(color: theme.hintColor), ),
                SizedBox(height: 25),

                // --- شريط البحث ---
                TextField(
                  onChanged: _searchDoctors,
                  decoration: InputDecoration(
                    hintText: 'ابحث عن طبيب أو تخصص...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder( borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none ),
                    filled: true,
                    fillColor: theme.inputDecorationTheme.fillColor?.withOpacity(0.85) ?? theme.colorScheme.surfaceVariant.withOpacity(0.5),
                  ),
                  style: theme.textTheme.bodyLarge,
                  textInputAction: TextInputAction.search,
                  onSubmitted: _searchDoctors,
                ),
                SizedBox(height: 30),

                // --- عرض المحتوى: الأقسام أو نتائج البحث ---
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _searchQuery.isEmpty
                      ? _buildMainContent(theme) // عرض الأقسام
                      : _buildSearchResults(theme), // عرض النتائج
                ),
                SizedBox(height: 20), // مسافة في الأسفل داخل المنطقة القابلة للتمرير
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- ويدجت بناء المحتوى الرئيسي (الأقسام) ---
  Widget _buildMainContent(ThemeData theme) {
    final int eyeDoctorCount = _initialEyeDoctorsData.length;
    final int earDoctorCount = _initialEarDoctorsData.length;
    final Color cardBackgroundColor = theme.cardColor.withOpacity(0.9);

    return Column(
      key: ValueKey('main_content'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'التخصصات المتاحة', () { /* لاحقًا: عرض كل التخصصات */ }),
        SizedBox(height: 15),
        Container(
          // ***** التغيير هنا *****
          height: 130, // زيادة الارتفاع قليلاً لإصلاح الـ Overflow
          // ***** نهاية التغيير *****
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildCategoryCard( 'assets/eye.png', 'العينية', '$eyeDoctorCount أطباء', () {
                // *** تصحيح استدعاء DoctorListPage ***
                Navigator.push(context, MaterialPageRoute(builder: (context) => DoctorListPage(
                  speciality: 'العينية',
                  allDoctors: _allDoctors, // تمرير القائمة الكاملة
                  onRateDoctorCallback: _addRating,
                  // تأكد من أن DoctorListPage يقبل `onRateDoctorCallback` أو أي اسم متفق عليه
                  // قد تحتاج إلى تعديل DoctorListPage لتقبل هذا الـ callback بالاسم الصحيح
                  onRateDoctor: (String doctorId, double rating, String comment) {
                    // لا تفعل شيئًا هنا إذا كان onRateDoctorCallback هو المستخدم
                  },
                )));
              },
                  theme.primaryColor, theme.hintColor, theme.colorScheme.primary.withOpacity(0.1),
                  cardBackgroundColor
              ),
              SizedBox(width: 15),
              _buildCategoryCard( 'assets/hearing-exam.png', 'الأذنية', '$earDoctorCount أطباء', () {
                // *** تصحيح استدعاء DoctorListPage ***
                Navigator.push(context, MaterialPageRoute(builder: (context) => DoctorListPage(
                  speciality: 'الأذنية',
                  allDoctors: _allDoctors, // تمرير القائمة الكاملة
                  onRateDoctorCallback: _addRating,
                  // تأكد من أن DoctorListPage يقبل `onRateDoctorCallback` أو أي اسم متفق عليه
                  onRateDoctor: (String doctorId, double rating, String comment) {
                    // لا تفعل شيئًا هنا إذا كان onRateDoctorCallback هو المستخدم
                  },
                )));
              },
                  theme.primaryColor, theme.hintColor, theme.colorScheme.primary.withOpacity(0.1),
                  cardBackgroundColor
              ),
            ],
          ),
        ),
        SizedBox(height: 30),

        // --- قسم الأطباء المقترحين ---
        _buildSectionTitle(context, 'الأطباء المقترحون', () {
          // *** تصحيح استدعاء AllTopRatedDoctorsPage ***
          Navigator.push(context, MaterialPageRoute(builder: (context) => AllTopRatedDoctorsPage(
            allDoctors: _allDoctors,         // تمرير القائمة الكاملة
            onRateDoctorCallback: _addRating, // تمرير الكول باك بالاسم الصحيح
          )));
        }),
        SizedBox(height: 10),
        // عرض الأطباء المقترحين (الأعلى تقييماً)
        _buildDoctorList(_searchResults, theme.hintColor, theme.textTheme.bodyLarge!.color!, cardBackgroundColor),
      ],
    );
  }

  // --- ويدجت بناء نتائج البحث ---
  Widget _buildSearchResults(ThemeData theme) {
    final Color cardBackgroundColor = theme.cardColor.withOpacity(0.9);
    return Column(
      key: ValueKey('search_results'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: Text(
            _searchResults.isNotEmpty
                ? 'نتائج البحث عن "$_searchQuery"'
                : 'لا توجد نتائج للبحث عن "$_searchQuery"',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        _buildDoctorList(_searchResults, theme.hintColor, theme.textTheme.bodyLarge!.color!, cardBackgroundColor),
      ],
    );
  }

  // --- الدوال المساعدة للبناء (_buildSectionTitle, _buildCategoryCard, _buildDoctorList) كما هي ---
  Widget _buildSectionTitle(BuildContext context, String title, VoidCallback onSeeAllTap) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text( title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700), ),
        TextButton(
          onPressed: onSeeAllTap,
          style: TextButton.styleFrom( padding: EdgeInsets.zero, visualDensity: VisualDensity.compact, foregroundColor: theme.primaryColor ),
          child: Text( 'عرض الكل', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500), ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(String imgPath, String name, String drCount, VoidCallback onTap, Color primaryColor, Color greyColor, Color iconBgColorOpacity, Color cardBgColor) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 105, // العرض يبقى كما هو
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: primaryColor.withOpacity(0.3))
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // توسيط المحتوى عمودياً
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration( color: iconBgColorOpacity, shape: BoxShape.circle, ),
              child: Image.asset(
                  imgPath, height: 35, width: 35,
                  errorBuilder: (c, o, s) => Icon(Icons.category_outlined, size: 30, color: primaryColor.withOpacity(0.7))
              ),
            ),
            SizedBox(height: 10),
            Text( name, textAlign: TextAlign.center, style: TextStyle( color: primaryColor, fontSize: 14, fontWeight: FontWeight.w500, ), maxLines: 1, overflow: TextOverflow.ellipsis, ),
            SizedBox(height: 4),
            Text( drCount, style: TextStyle( color: primaryColor.withOpacity(0.8), fontSize: 11, ), ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorList(List<Map<String, dynamic>> doctors, Color greyColor, Color textColor, Color cardBgColor) {
    if (doctors.isEmpty && _searchQuery.isNotEmpty) {
      return SizedBox.shrink(); // لا تعرض شيئًا إذا كان البحث نشطًا والنتائج فارغة
    }
    if (doctors.isEmpty && _searchQuery.isEmpty) {
      return Padding( // رسالة إذا كانت قائمة المقترحين فارغة
        padding: const EdgeInsets.symmetric(vertical: 30.0),
        child: Center(child: Text('لا يوجد أطباء مقترحون حاليًا.', style: TextStyle(color: Theme.of(context).hintColor))),
      );
    }

    return ListView.builder(
      shrinkWrap: true, // مهم لأنه داخل SingleChildScrollView
      physics: NeverScrollableScrollPhysics(), // مهم لأنه داخل SingleChildScrollView
      itemCount: doctors.length,
      itemBuilder: (context, index) {
        try {
          // التحقق قبل البناء
          if (doctors[index] is Map<String, dynamic>) {
            return _buildDoctorCard(doctors[index], greyColor, textColor, cardBgColor);
          } else {
            print("[Build Warn] Item at index $index in doctor list is not a Map: ${doctors[index].runtimeType}");
            return SizedBox.shrink(); // تجاهل العناصر غير الصالحة
          }
        } catch (e, stackTrace) {
          print("[Error building doctor card in list at index $index]: $e\n$stackTrace");
          // عرض بطاقة خطأ بسيطة
          return ListTile(
            leading: Icon(Icons.error_outline, color: Colors.red),
            title: Text('خطأ في عرض بيانات الطبيب', style: TextStyle(color: Colors.red)),
          );
        }
      },
    );
  }

  // بناء بطاقة الطبيب المفردة
  Widget _buildDoctorCard(Map<String, dynamic> doctorDataMap, Color greyColor, Color textColor, Color cardBgColor) {
    final theme = Theme.of(context);

    // استخلاص البيانات بأمان
    final String name = doctorDataMap['name'] as String? ?? 'اسم غير معروف';
    final String speciality = doctorDataMap['speciality'] as String? ?? 'تخصص غير معروف';
    final String imagePath = doctorDataMap['image'] as String? ?? 'assets/doctor_placeholder.png';
    final String? doctorId = doctorDataMap['id'] as String?;

    // حساب التقييم بأمان
    final List<dynamic>? ratings = doctorDataMap['ratings'] as List<dynamic>?;
    final double averageRating = _calculateAverageRating(ratings);
    final int ratingCount = ratings?.length ?? 0;

    return Card(
      margin: EdgeInsets.only(bottom: 15),
      color: cardBgColor,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)), // توحيد شكل البطاقة
      child: InkWell(
        onTap: () {
          if (doctorId == null) {
            print("[Navigation Error] Doctor ID is null for '$name'. Cannot navigate.");
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: لا يمكن فتح تفاصيل هذا الطبيب الآن.'), backgroundColor: Colors.orange[800]));
            return;
          }

          // البحث عن بيانات الطبيب الكاملة *داخل* القائمة _allDoctors
          Map<String, dynamic>? fullDoctorData = _allDoctors.firstWhere(
                  (doc) => doc['id'] == doctorId,
              orElse: () {
                print("[Navigation Warn] Doctor ID $doctorId from card not found in _allDoctors. Using card data directly.");
                return doctorDataMap; // استخدام البيانات الحالية كاحتياط
              }
          );

          if (fullDoctorData == null) { // تحقق إضافي (نظريًا لا يحدث بسبب orElse)
            print("[Navigation Error] Critical: Could not find or use fallback data for Doctor ID $doctorId.");
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ فادح: تعذر تحميل بيانات الطبيب.'), backgroundColor: Colors.red[900]));
            return;
          }

          print("[Navigation] Navigating to details for Doctor ID: $doctorId");

          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorDetailPage(
                doctorData: fullDoctorData, // تمرير البيانات الكاملة
                onRateSubmitted: _addRating, // تمرير دالة التقييم
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(15.0), // يطابق شكل الـ Card
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // --- صورة الطبيب ---
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  imagePath, height: 70, width: 70, fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 70, width: 70,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Icon(Icons.person_outline, color: theme.hintColor, size: 40),
                    );
                  },
                ),
              ),
              SizedBox(width: 15),

              // --- معلومات الطبيب ---
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text( name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis, ),
                    SizedBox(height: 5),
                    Text( speciality, style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor), maxLines: 1, overflow: TextOverflow.ellipsis, ),
                    SizedBox(height: 6),
                    // --- عرض التقييم المحسوب ---
                    Row(
                      children: [
                        Icon(Icons.star_rounded, color: averageRating > 0 ? Colors.amber : theme.disabledColor.withOpacity(0.5), size: 18),
                        SizedBox(width: 4),
                        if (averageRating > 0)
                          Text( averageRating.toStringAsFixed(1), style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500), )
                        else
                          Text( 'لا تقييمات', style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor), ),
                        SizedBox(width: 5),
                        if (ratingCount > 0)
                          Text( '($ratingCount)', style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor), ),
                      ],
                    ),
                  ],
                ),
              ),
              // --- أيقونة السهم ---
              Icon(Icons.chevron_right, color: theme.hintColor, size: 28),
            ],
          ),
        ),
      ),
    );
  }
} // نهاية HomePageState