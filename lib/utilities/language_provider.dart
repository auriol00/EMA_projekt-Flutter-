import 'package:flutter/material.dart';

class LanguageProvider with ChangeNotifier {
  Locale _currentLocale = const Locale('de', 'DE');

  Locale get currentLocale => _currentLocale;

  void toggleLanguage() {
    if (_currentLocale.languageCode == 'de') {
      _currentLocale = const Locale('en', 'US');
    } else {
      _currentLocale = const Locale('de', 'DE');
    }
    notifyListeners();
  }


 void setLocale(Locale newLocale) {
    if (_currentLocale != newLocale) {
      _currentLocale = newLocale;
      notifyListeners();
    }
  }
}