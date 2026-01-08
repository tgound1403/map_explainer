import 'package:flutter/material.dart';
import 'package:ai_map_explainer/core/theme/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _isInitialized = false;

  bool get isDarkMode => _isDarkMode;

  /// Khởi tạo theme từ SharedPreferences
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _isDarkMode = await AppTheme.getThemeMode();
    _isInitialized = true;
    notifyListeners();
  }

  /// Toggle theme
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await AppTheme.saveThemeMode(_isDarkMode);
    notifyListeners();
  }

  /// Set theme mode
  Future<void> setThemeMode(bool isDark) async {
    if (_isDarkMode == isDark) return;
    
    _isDarkMode = isDark;
    await AppTheme.saveThemeMode(_isDarkMode);
    notifyListeners();
  }

  /// Get current theme data
  ThemeData get themeData {
    return _isDarkMode ? AppTheme.getDarkTheme() : AppTheme.getLightTheme();
  }
}
