import 'package:flutter/foundation.dart';

/// Drives bottom navigation and deep links from Home → Menu tab.
class MainNavController extends ChangeNotifier {
  int _index = 0;
  String? _menuCategoryId;

  int get index => _index;
  String? get menuCategoryId => _menuCategoryId;

  void goToTab(int i, {String? menuCategoryId}) {
    _index = i;
    if (menuCategoryId != null) {
      _menuCategoryId = menuCategoryId;
    }
    notifyListeners();
  }

  void clearMenuCategory() {
    _menuCategoryId = null;
    notifyListeners();
  }
}
