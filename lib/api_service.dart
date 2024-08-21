import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';

class ApiService {
  // Base URLs for both servers
  static const String ocularBaseUrl = 'http://35.178.199.186:5000';  // Replace with your EC2 public IP
  static const String octBaseUrl = 'http://35.178.199.186:5002';     // Replace with your EC2 public IP

  // Test connection for ocular model server
  static Future<void> testOcularConnection() async {
    var uri = Uri.parse('$ocularBaseUrl/test');
    try {
      var response = await http.get(uri);
      if (response.statusCode == 200) {
        print('Ocular model test successful: ${response.body}');
      } else {
        print('Ocular model test failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Ocular model network error: $e');
    }
  }

  // Test connection for OCT model server
  static Future<void> testOctConnection() async {
    var uri = Uri.parse('$octBaseUrl/test');
    try {
      var response = await http.get(uri);
      if (response.statusCode == 200) {
        print('OCT model test successful: ${response.body}');
      } else {
        print('OCT model test failed: ${response.statusCode}');
      }
    } catch (e) {
      print('OCT model network error: $e');
    }
  }

  // Upload file to ocular model server
  static Future<Uint8List> uploadFileToOcular(File file) async {
    var uri = Uri.parse('$ocularBaseUrl/predict');
    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: MediaType('image', 'jpeg'),
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

  // Upload file to OCT model server
  static Future<Uint8List> uploadFileToOct(File file) async {
    var uri = Uri.parse('$octBaseUrl/predict');
    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: MediaType('image', 'jpeg'),
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
