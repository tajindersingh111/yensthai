import 'package:flutter/material.dart';
import 'package:yensss/pages/home_page.dart';
import 'package:yensss/pages/login_page.dart';
import 'package:provider/provider.dart';
import 'controllers/language_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  /// Firebase ke liye zaroori hai
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => LanguageController(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(), // ← pehle login, phir home
    );
  }
}