import 'package:flutter/material.dart';

class LanguageController extends ChangeNotifier {

  bool english = false;

  void toggleLanguage() {
    english = !english;
    notifyListeners();
  }

}