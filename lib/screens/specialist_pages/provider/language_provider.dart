// import 'package:flutter/material.dart';

// class LanguageProvider extends ChangeNotifier {
//   String _currentLanguage = 'en';

//   String get currentLanguage => _currentLanguage;

//   void setLanguage(String languageCode) {
//     _currentLanguage = languageCode;
//     notifyListeners();
//   }
// }
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  String _currentLanguage = 'en';

  String get currentLanguage => _currentLanguage;

  LanguageProvider() {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentLanguage = prefs.getString('app_language') ?? 'en';
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading language: $e');
    }
  }

  Future<void> setLanguage(String languageCode) async {
    if (languageCode == _currentLanguage) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_language', languageCode);
      _currentLanguage = languageCode;
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving language: $e');
      rethrow;
    }
  }

  bool get isEnglish => _currentLanguage == 'en';
  bool get isRussian => _currentLanguage == 'ru';
}
