import 'package:flutter/material.dart';

class DoctorCard extends StatelessWidget {
  final String doctorImagePath;
  final String rating;
  final String doctorName;
  final String doctorProfession;

  const DoctorCard({
    required this.doctorImagePath,
    required this.rating,
    required this.doctorName,
    required this.doctorProfession,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 10.0),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Color(0xFF9fbdff),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.asset(doctorImagePath, height: 100),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.star, color: Colors.yellow[600]),
                Text(rating, style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 6),
            Text(doctorName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            SizedBox(height: 2),
            Text('$doctorProfession • 7+ Y.E.', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
