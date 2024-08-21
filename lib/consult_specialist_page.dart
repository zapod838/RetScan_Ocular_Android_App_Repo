import 'package:flutter/material.dart';

class ConsultSpecialistPage extends StatelessWidget {
  const ConsultSpecialistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Consult a Specialist'),
      ),
      body: Center(
        child: Text('Details to contact and consult a specialist.'),
      ),
    );
  }
}
