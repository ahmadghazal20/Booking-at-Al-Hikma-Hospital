import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddReviewPage extends StatefulWidget {
  final String doctorName;

  AddReviewPage({Key? key, required this.doctorName, required void Function(double rating, String comment) onSave, required double initialRating, required String initialComment}) : super(key: key);

  @override
  _AddReviewPageState createState() => _AddReviewPageState();
}

class _AddReviewPageState extends State<AddReviewPage> {
  double _rating = 3.0; // القيمة الافتراضية للتقييم
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPreviousReview();
  }

  // Load the previous rating and comment if they exist
  Future<void> _loadPreviousReview() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double? savedRating = prefs.getDouble('rating_${widget.doctorName}');
    String? savedComment = prefs.getString('comment_${widget.doctorName}');

    setState(() {
      if (savedRating != null) {
        _rating = savedRating;
      }
      if (savedComment != null) {
        _commentController.text = savedComment;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5), // Light gray background
      appBar: AppBar(
        title: Text('إضافة تقييم', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF419859), // Green AppBar
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تقييم د. ${widget.doctorName}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xff363636)),
            ),
            SizedBox(height: 20),
            Text(
              'التقييم:',
              style: TextStyle(fontSize: 18, color: Color(0xff363636)),
            ),
            Slider(
              value: _rating,
              min: 1,
              max: 5,
              divisions: 4,
              activeColor: Color(0xFFE57373),
              inactiveColor: Colors.grey[300],
              label: _rating.toString(),
              onChanged: (value) {
                setState(() {
                  _rating = value;
                });
              },
            ),
            SizedBox(height: 20),
            Text(
              'تعليق:',
              style: TextStyle(fontSize: 18, color: Color(0xff363636)),
            ),
            TextFormField(
              controller: _commentController,
              maxLines: 3,
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'اكتب تعليقك هنا...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF419859), // Green button
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  // Save rating and comment to SharedPreferences
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.setDouble('rating_${widget.doctorName}', _rating);
                  await prefs.setString('comment_${widget.doctorName}', _commentController.text);

                  // Show confirmation message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('تم حفظ تقييمك بنجاح')),
                  );

                  // Go back to the doctor detail page
                  Navigator.pop(context);
                },
                child: Text('حفظ التقييم', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}