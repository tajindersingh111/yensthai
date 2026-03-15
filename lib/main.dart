import 'package:flutter/material.dart';
import 'package:yensss/pages/home_page.dart';
import 'package:yensss/pages/signup_page.dart';
import 'package:provider/provider.dart';
import 'controllers/language_controller.dart';

void main() {
  runApp(
    ChangeNotifierProvider(

      create: (_) => LanguageController(),

      child:  MyApp(),

    ),

  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SignupPage(),
    );
  }
}
