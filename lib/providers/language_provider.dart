import 'package:flutter/material.dart';
import 'package:shop/services/auth_service.dart';

class LanguageProvider extends ChangeNotifier {
  String _currentLanguage = 'fr'; // Default to French
  final AuthService _authService = AuthService();

  String get currentLanguage => _currentLanguage;

  Locale get currentLocale {
    switch (_currentLanguage) {
      case 'ar':
        return const Locale('ar', 'SA');
      case 'en':
        return const Locale('en', 'US');
      case 'fr':
      default:
        return const Locale('fr', 'FR');
    }
  }

  Future<void> loadLanguage() async {
    final savedLanguage = await _authService.getLanguage();
    if (savedLanguage != null) {
      _currentLanguage = savedLanguage;
      notifyListeners();
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    if (_currentLanguage != languageCode) {
      _currentLanguage = languageCode;
      await _authService.saveLanguage(languageCode);
      notifyListeners();
    }
  }

  bool get isRTL => _currentLanguage == 'ar';
}
