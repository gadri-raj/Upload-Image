import 'package:flutter/material.dart';
import 'app_screens/landing_page.dart';
import 'dart:async';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Dating App",
      home: LandingPage(),
    );
  }
}
