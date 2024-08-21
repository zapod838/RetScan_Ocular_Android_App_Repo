import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'api_service.dart';
import 'results_page.dart';

class UploadOCTPage extends StatefulWidget {
  @override
  UploadOCTPageState createState() => UploadOCTPageState();
}

class UploadOCTPageState extends State<UploadOCTPage> {
  void _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg'],
    );

    if (!mounted) return;

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      _showLoadingDialog("Processing OCT image...");

      try {
        final pdfBytes = await ApiService.uploadFileToOct(file);
        Navigator.pop(context); // Close loading dialog

        // Inform user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF saved successfully!')),
        );

        // Navigate to the ResultsPage with the PDF bytes
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsPage(pdfBytes: pdfBytes), // Pass Uint8List directly
          ),
        );
      } catch (e) {
        Navigator.pop(context); // Close loading dialog
        _showErrorDialog(e.toString());
      }
    } else {
      _showErrorDialog("No file selected or file path is not accessible.");
    }
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 10),
            Text(message),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: Text('Failed to upload file: $message'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload OCT Scans"),
        backgroundColor: Color(0xFF9fbdff),
      ),
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("lib/images/Ophthalmologist-bro.png"), // Change this path to your OCT scan image asset
            SizedBox(height: 20),
            Text(
              "Upload your OCT Images",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Browse your device for OCT images\nMax file size: 25mb",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 50),  // Reduced space to move the button higher
            Transform.rotate(
              angle: 45 * 3.14159265 / 180, // Rotate by 45 degrees, converting degrees to radians
              child: ElevatedButton(
                onPressed: _pickFiles,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, // Text color
                  backgroundColor: Color(0xFF407BFF), // Button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15), // Rounded edges for the diamond shape
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20), // Adjust padding as needed
                ),
                child: Transform.rotate(
                  angle: 45 * 3.14159265 / 180, // Rotate the icon by 45 degrees
                  child: Icon(Icons.add, size: 30),
                ),
              ),
            ),
            SizedBox(height: 25),  // Space at the bottom of the button
          ],
        ),
      ),
    );
  }
}
