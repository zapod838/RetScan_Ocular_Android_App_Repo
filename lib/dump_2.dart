import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.3:5000';

  static Future<void> testConnection() async {
    var uri = Uri.parse('$baseUrl/test');
    try {
      var response = await http.get(uri);
      if (response.statusCode == 200) {
        print('Test successful: ${response.body}');
      } else {
        print('Test failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Network error: $e');
    }
  }

  static Future<Uint8List> uploadFile(File file) async {
    var uri = Uri.parse('$baseUrl/predict');
    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: MediaType('application', 'pdf'),
      ));

    try {
      print('Sending request to $uri');
      var streamedResponse = await request.send().timeout(Duration(minutes: 5));

      if (streamedResponse.statusCode == 200) {
        final response = await http.Response.fromStream(streamedResponse);
        print('Received response: ${response.bodyBytes.length} bytes');
        return response.bodyBytes;
      } else {
        final errorContent = await streamedResponse.stream.bytesToString();
        print('Failed to upload file with status: ${streamedResponse.statusCode} and error: $errorContent');
        throw Exception('Failed to upload file with status: ${streamedResponse.statusCode} and error: $errorContent');
      }
    } catch (e) {
      print('Unexpected error occurred: $e');
      throw Exception('Unexpected error occurred: $e');
    }
  }
}
