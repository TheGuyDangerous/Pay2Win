import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  ThemeProvider() {
    _loadThemePreference();
  }
  
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(AppConstants.prefKeyTheme) ?? true;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
  
  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefKeyTheme, _themeMode == ThemeMode.dark);
    
    notifyListeners();
  }
  
  Future<void> setTheme(ThemeMode themeMode) async {
    _themeMode = themeMode;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefKeyTheme, _themeMode == ThemeMode.dark);
    
    notifyListeners();
  }
} 