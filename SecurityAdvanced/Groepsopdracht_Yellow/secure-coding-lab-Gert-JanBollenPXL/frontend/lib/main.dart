// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:developer';
import 'dart:js';

import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import 'package:secadvpxl/landing_page.dart';
import 'package:secadvpxl/login_screen.dart';

import 'database_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //select * from users where user_name = 'pxl-admin' and password = crypt('secureandlovinit', password);
  runApp(MaterialApp(
      routes: {
        LoginScreen.route :(context) => LoginScreen(),
        LandingPage.route: (context) => LandingPage()
      },
      initialRoute: LoginScreen.route,
      debugShowCheckedModeBanner: false,
      title: "Super Secret PXL Mainframe",
  ));
}
