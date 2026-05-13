import 'package:flutter/material.dart';
import 'package:secadvpxl/authentication.dart';

class LandingPage extends StatelessWidget {

  static const String route = "/main";

  _showContent()
  {
    String c = "Unauthorized";
    if(!Authentication.user.isEmpty)
    {
      c = "Wireless charging is overrated";
    }
    return c;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Center(
            child: Text(
                _showContent(),
                style: TextStyle(fontSize: 38, color: Colors.white),
                textAlign: TextAlign.center,
              )
          ),
        ),
      ),
    );
  }
}
