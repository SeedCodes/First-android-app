import 'package:flutter/material.dart';
import '../utils/theme_helper.dart';
import '../utils/storage_helper.dart';
import '../models/app_settings.dart';

class ThemeProvider extends ChangeNotifier {
  int _themeIndex = 0;
  AppColors _colors = AppColors.defaultDark();

  int get themeIndex => _themeIndex;
  AppColors get colors => _colors;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final settings = await StorageHelper.loadAppSettings();
    if (settings != null) {
      _themeIndex = settings.themeIndex;
      _colors = ThemeHelper.getColors(_themeIndex);
      notifyListeners();
    }
  }

  Future<void> setTheme(int themeIndex) async {
    _themeIndex = themeIndex;
    _colors = ThemeHelper.getColors(themeIndex);
    
    // Save to settings
    final settings = await StorageHelper.loadAppSettings() ?? AppSettings.defaultSettings();
    final updatedSettings = settings.copyWith(themeIndex: themeIndex);
    await StorageHelper.saveAppSettings(updatedSettings);
    
    notifyListeners();
  }

  ThemeData getThemeData() {
    return ThemeHelper.getTheme(_themeIndex);
  }
}
