import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 1.7,
                  decoration: BoxDecoration(
                    color: Colors.white,  // Top container with white color
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 1.7,
                  decoration: BoxDecoration(
                    color: Color(0xFF407BFF),  // Bottom container with a purple color
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                  child: Center(
                    child: Image.asset(
                      "lib/images/Ophthalmologist-pana.png",
                      width: MediaQuery.of(context).size.width * 0.8,
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 2.4,
                decoration: BoxDecoration(
                  color: Color(0xFF407BFF),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 2.4,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.05),
                      child: Text(
                        "Your Vision First",
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.065,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                          wordSpacing: 2,
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.2),
                      child: Text(
                        "Empowering eye care with precision diagnostics anywhere, anytime.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.045,
                          color: Colors.black.withOpacity(0.8),
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                    Material(
                      color: Color(0xFF407BFF),
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed('/login');  // Navigate to the LoginPage
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: MediaQuery.of(context).size.height * 0.02,
                            horizontal: MediaQuery.of(context).size.width * 0.2,
                          ),
                          child: Text(
                            "Get Started",
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width * 0.055,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
