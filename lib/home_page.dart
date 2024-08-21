import 'package:flutter/material.dart';
import 'category_card.dart';
import 'doctor_card.dart'; // Ensure this import is correct
import 'results_page.dart';
import 'dart:typed_data';
import 'dart:io';

class HomePage extends StatelessWidget {
  Future<void> _navigateToResultsPage(BuildContext context) async {
    // Replace this with actual logic to get the PDF bytes.
    // For example, this could be an API call or fetching from local storage.
    // Here, we simulate this with a dummy file read.
    final pdfBytes = await _getPdfBytes();
    if (pdfBytes != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsPage(pdfBytes: pdfBytes),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load PDF.')),
      );
    }
  }

  Future<Uint8List?> _getPdfBytes() async {
    // Simulate fetching PDF bytes.
    // Replace this with your actual logic.
    final file = File('/path/to/result.pdf'); // Update this with your actual file path
    if (await file.exists()) {
      return await file.readAsBytes();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text("Medical Services"),
        backgroundColor: Color(0xFF9fbdff),
      ),
      backgroundColor: Colors.grey[300],  // Setting the background color to grey
      body: SafeArea(
        child: SingleChildScrollView(  // Allow for scrolling
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.06, 
                  vertical: screenHeight * 0.02
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Hello,",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: screenHeight * 0.022,
                          ),
                        ),
                        Text(
                          "Mick Husky",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: screenHeight * 0.03,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.all(screenWidth * 0.03),
                      decoration: BoxDecoration(
                        color: Color(0xFF9fbdff),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.person, size: screenHeight * 0.06),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                child: Container(
                  padding: EdgeInsets.all(screenWidth * 0.05),
                  decoration: BoxDecoration(
                    color: Color(0xFFe2bfcf),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Test Your Ocular Health Now!",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: screenHeight * 0.022,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      Text(
                        "Upload your Retinal and OCT scans for instant analysis.",
                        style: TextStyle(fontSize: screenHeight * 0.02),
                      ),
                      SizedBox(height: screenHeight * 0.018),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pushNamed(context, '/uploadScans'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(double.infinity, screenHeight * 0.065), // Make button full width
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.04, 
                                  vertical: screenHeight * 0.012
                                ), // Consistent padding
                                backgroundColor: Color(0xFF407BFF),
                                alignment: Alignment.center, // Explicitly center the content
                              ),
                              child: Text(
                                'Retinal Scan',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.03), // Space between the buttons
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pushNamed(context, '/uploadOCTScan'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(double.infinity, screenHeight * 0.065), // Make button full width
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.04, 
                                  vertical: screenHeight * 0.012
                                ), // Consistent padding
                                backgroundColor: Color(0xFF407BFF), // Different color for differentiation
                                alignment: Alignment.center, // Explicitly center the content
                              ),
                              child: Text(
                                'OCT Scan',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.018),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                child: SizedBox(
                  height: screenHeight * 0.12,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[
                      CategoryCard(
                        categoryName: 'Results',
                        iconImagePath: 'lib/icons/result.png',
                        onTap: () => _navigateToResultsPage(context), // Updated to handle navigation
                      ),
                      CategoryCard(
                        categoryName: 'Specialist',
                        iconImagePath: 'lib/icons/eye-exam.png',
                        onTap: () {
                          // Navigation or other actions for Specialist
                        },
                      ),
                      CategoryCard(
                        categoryName: 'Surgeon',
                        iconImagePath: 'lib/icons/surgeon.png',
                        onTap: () {
                          // Navigation or other actions for Specialist
                        },
                      ),
                      CategoryCard(
                        categoryName: 'Pharmacist',
                        iconImagePath: 'lib/icons/eye-drop_2.png',
                        onTap: () {
                          // Navigation or other actions for Specialist
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Doctor List', style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenHeight * 0.025)),
                        Text('See all', style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenHeight * 0.02, color: Colors.grey[500])),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    SizedBox(
                      height: screenHeight * 0.301,  // Adjust height based on content
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: <Widget>[
                          DoctorCard(
                            doctorImagePath: 'lib/images/doc_1.jpg',
                            rating: '4.9',
                            doctorName: 'Dr. Sneha Seth',
                            doctorProfession: 'Specialist',
                          ),
                          DoctorCard(
                            doctorImagePath: 'lib/images/doc_2.jpg',
                            rating: '4.4',
                            doctorName: 'Dr. Prashant',
                            doctorProfession: 'Therapist',
                          ),
                          DoctorCard(
                            doctorImagePath: 'lib/images/doc_3.jpg',
                            rating: '5.0',
                            doctorName: 'Dr. Steve Jobs',
                            doctorProfession: 'Surgeon',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
