import 'package:flutter/material.dart';

class CallCenterPage extends StatelessWidget {
  const CallCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Call Center'),
      ),
      body: Center(
        child: Text('Contact details for the call center.'),
      ),
    );
  }
}
