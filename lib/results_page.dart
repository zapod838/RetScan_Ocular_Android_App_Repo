import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ResultsPage extends StatefulWidget {
  final Uint8List pdfBytes;

  ResultsPage({required this.pdfBytes});

  @override
  _ResultsPageState createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  String? localFilePath;

  @override
  void initState() {
    super.initState();
    _savePdfFile();
  }

  Future<void> _savePdfFile() async {
    try {
      final tempDir = await getApplicationDocumentsDirectory();
      final file = File('${tempDir.path}/result.pdf');
      await file.writeAsBytes(widget.pdfBytes);
      setState(() {
        localFilePath = file.path;
      });
    } catch (e) {
      print('Error saving PDF file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Results'),
      ),
      body: localFilePath == null
          ? Center(child: CircularProgressIndicator())
          : PDFView(
              filePath: localFilePath!,
              autoSpacing: true,
              swipeHorizontal: true,
              pageFling: true,
              onError: (error) {
                print('PDFView error: ${error.toString()}');
              },
              onPageError: (page, error) {
                print('Page $page error: ${error.toString()}');
              },
            ),
    );
  }
}
