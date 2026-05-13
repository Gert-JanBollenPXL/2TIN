import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:secadvpxl/authentication.dart';
import 'package:secadvpxl/landing_page.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  static const String route = "/";
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() {
    return _LoginScreenState();
  } 
}

class _LoginScreenState extends State<LoginScreen> {

  TextEditingController userNameController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();



  _login() async {
    

      String url = "http://localhost:3000/authenticate/${userNameController.text}/${passwordController.text}";
      print(url);
      var response = await http.get(Uri.parse(url));

      if(response.statusCode == 200)
      {
        final List<dynamic> r = jsonDecode(response.body);
        if(r.isNotEmpty)
        {
          Authentication.user = userNameController.text;
          Navigator.of(context).pushNamed(LandingPage.route);
        }
        else
        {
          await _showDialog("Login failed", "Wrong username or password");
        }
      }
      else
      {
        await _showDialog("Login failed", "Oops! Something went wrong. We can't log you in right now, please try again later");
      }
  }

  Future<void> _showDialog(String header, String content) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(header),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(content)
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
   

  @override
  Widget build(BuildContext ctx) {
    return SafeArea(
        child: Scaffold(
        
      backgroundColor: Colors.white,
      body: Column(
        children: [
        Container(
            width: 150, height: 150, child: Image.asset('lib/images/logo.png')
        ),
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), 
              topRight: Radius.circular(30)
            )
          ),
          child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Username',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    
                    const SizedBox(height: 10),
                    
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: userNameController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(
                            Icons.person,
                            color: Colors.white,
                          ),
                          hintText: 'Username',
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    const Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 15),
                        
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: passwordController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(
                            Icons.lock,
                          ),
                          hintText: 'Password',
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 35),

                    ElevatedButton(
                      onPressed: () => {
                        _login()
                      },
                      child: const Text('Login'),
                    )
                        
                  ],
                ),
              )),
        )
      ]),
    ));
  }
}

