import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Ensures the scaffold resizes when the keyboard is opened
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height, // Ensures the container takes up full screen height
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  colors: [
                    Color(0xFF3173f6), // Dark shade of blue
                    Color(0xFF718fff), // Medium shade of blue
                    Color(0xFF94a4ff)  // Light shade of blue
                  ]
              )
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              Padding(
                padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    FadeInUp(
                      duration: Duration(milliseconds: 1000),
                      child: Text(
                        "Login",
                        style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.width * 0.1),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    FadeInUp(
                      duration: Duration(milliseconds: 1300),
                      child: Text(
                        "Welcome Back",
                        style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.width * 0.05),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(60), topRight: Radius.circular(60)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.08),
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                        FadeInUp(
                          duration: Duration(milliseconds: 1400),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromRGBO(0, 105, 214, .3), // A blue shade for the shadow
                                  blurRadius: 20,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
                                  decoration: BoxDecoration(
                                      border: Border(bottom: BorderSide(color: Colors.grey.shade200))
                                  ),
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: "Email or Phone number",
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
                                  child: TextField(
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      hintText: "Password",
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                        FadeInUp(
                          duration: Duration(milliseconds: 1500),
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                        FadeInUp(
                          duration: Duration(milliseconds: 1600),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.7,  // Set the desired width of the button here
                            child: MaterialButton(
                              onPressed: () => Navigator.pushNamed(context, '/home'),
                              height: MediaQuery.of(context).size.height * 0.07,
                              color: Color(0xFF407BFF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Center(
                                child: Text(
                                  "Login",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: MediaQuery.of(context).size.width * 0.05),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                        FadeInUp(
                          duration: Duration(milliseconds: 1700),
                          child: Text(
                            "Continue with social media",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,  // Adjust spacing as needed
                          children: <Widget>[
                            FadeInUp(
                              duration: Duration(milliseconds: 1800), 
                              child: MaterialButton(
                                onPressed: () {},
                                height: MediaQuery.of(context).size.width * 0.13,
                                color: Colors.white,  // Facebook color
                                shape: CircleBorder(),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Image.asset('lib/images/facebook_Logo.png', height: MediaQuery.of(context).size.width * 0.1, width: MediaQuery.of(context).size.width * 0.1),  // Adjust size as needed
                                    SizedBox(width: 0),  // Space between icon and text
                                  ],
                                ),
                              ),
                            ),
                            FadeInUp(
                              duration: Duration(milliseconds: 1900),
                              child: MaterialButton(
                                onPressed: () {},
                                height: MediaQuery.of(context).size.width * 0.13,
                                color: Colors.white,  // Google color
                                shape: CircleBorder(),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Image.asset('lib/images/Google_Logo.png', height: MediaQuery.of(context).size.width * 0.13, width: MediaQuery.of(context).size.width * 0.13),  // Google logo
                                    SizedBox(width: 0),
                                  ],
                                ),
                              ),
                            ),
                            FadeInUp(
                              duration: Duration(milliseconds: 2000),
                              child: MaterialButton(
                                onPressed: () {},
                                height: MediaQuery.of(context).size.width * 0.13,
                                color: Colors.white,  // Apple typically uses black
                                shape: CircleBorder(),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Image.asset('lib/images/Apple_logo.png', height: MediaQuery.of(context).size.width * 0.1, width: MediaQuery.of(context).size.width * 0.1),  // Apple logo
                                    SizedBox(width: 0),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
