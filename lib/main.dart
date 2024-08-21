import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'upload_scans_page.dart';
import 'consult_specialist_page.dart';
import 'call_center_page.dart';
import 'welcome_screen.dart';
import 'results_page.dart';
import 'upload_oct_scans.dart';
import 'dart:typed_data';
import 'api_service.dart';  // Ensure this import is present

void main() {
  runApp(MyApp());
  testConnections();
}

void testConnections() async {
  await ApiService.testOcularConnection();
  await ApiService.testOctConnection();
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppState>(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'Ocular Diagnosis App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        initialRoute: '/welcome',
        onGenerateRoute: (settings) {
          if (settings.name == '/results') {
            final args = settings.arguments as Uint8List;
            return MaterialPageRoute(
              builder: (context) {
                return ResultsPage(pdfBytes: args);
              },  
            );
          }
          // Define other routes here if needed
          switch (settings.name) {
            case '/welcome':
              return MaterialPageRoute(builder: (context) => WelcomeScreen());
            case '/login':
              return MaterialPageRoute(builder: (context) => LoginPage());
            case '/home':
              return MaterialPageRoute(builder: (context) => HomePage());
            case '/uploadScans':
              return MaterialPageRoute(builder: (context) => UploadScansPage());
            case '/uploadOCTScan':
              return MaterialPageRoute(builder: (context) => UploadOCTPage());
            case '/consultSpecialist':
              return MaterialPageRoute(builder: (context) => ConsultSpecialistPage());
            case '/callCenter':
              return MaterialPageRoute(builder: (context) => CallCenterPage());
            default:
              return null;
          }
        },
      ),
    );
  }
}
