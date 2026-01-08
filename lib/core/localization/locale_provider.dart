import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'app_locale';
  Locale _locale = const Locale('vi'); // Default to Vietnamese
  bool _isInitialized = false;

  Locale get locale => _locale;
  bool get isVietnamese => _locale.languageCode == 'vi';
  bool get isEnglish => _locale.languageCode == 'en';

  /// Khởi tạo locale từ SharedPreferences
  Future<void> initialize() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(_localeKey);
    
    if (localeCode != null) {
      _locale = Locale(localeCode);
    } else {
      // Default to system locale or Vietnamese
      _locale = const Locale('vi');
    }
    
    _isInitialized = true;
    notifyListeners();
  }

  /// Set locale
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
    notifyListeners();
  }

  /// Toggle between Vietnamese and English
  Future<void> toggleLocale() async {
    final newLocale = _locale.languageCode == 'vi' 
        ? const Locale('en') 
        : const Locale('vi');
    await setLocale(newLocale);
  }

  /// Set to Vietnamese
  Future<void> setVietnamese() async {
    await setLocale(const Locale('vi'));
  }

  /// Set to English
  Future<void> setEnglish() async {
    await setLocale(const Locale('en'));
  }
}
