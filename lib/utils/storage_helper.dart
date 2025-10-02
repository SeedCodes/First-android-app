import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/arc_data.dart';
import '../models/daily_progress.dart';
import '../models/progress_stats.dart';

class StorageHelper {
  static const String _arcDataKey = 'arc_data';
  static const String _dailyProgressKey = 'daily_progress';
  static const String _progressStatsKey = 'progress_stats';

  // Save arc data
  static Future<void> saveArcData(ArcData arcData) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(arcData.toJson());
    await prefs.setString(_arcDataKey, jsonString);
  }

  // Load arc data
  static Future<ArcData?> loadArcData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_arcDataKey);
    
    if (jsonString == null) {
      return null;
    }

    final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
    return ArcData.fromJson(jsonData);
  }

  // Check if arc exists
  static Future<bool> hasArcData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_arcDataKey);
  }

  // Clear arc data
  static Future<void> clearArcData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_arcDataKey);
  }

  // Save daily progress
  static Future<void> saveDailyProgress(DailyProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(progress.toJson());
    await prefs.setString(_dailyProgressKey, jsonString);
  }

  // Load daily progress
  static Future<DailyProgress?> loadDailyProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_dailyProgressKey);
    
    if (jsonString == null) {
      return null;
    }

    final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
    final progress = DailyProgress.fromJson(jsonData);
    
    // If the saved progress is not for today, create a new one
    if (!progress.isToday()) {
      return null;
    }
    
    return progress;
  }

  // Clear daily progress
  static Future<void> clearDailyProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_dailyProgressKey);
  }

  // Save progress stats
  static Future<void> saveProgressStats(ProgressStats stats) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(stats.toJson());
    await prefs.setString(_progressStatsKey, jsonString);
  }

  // Load progress stats
  static Future<ProgressStats?> loadProgressStats() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_progressStatsKey);
    
    if (jsonString == null) {
      return null;
    }

    final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
    return ProgressStats.fromJson(jsonData);
  }

  // Clear progress stats
  static Future<void> clearProgressStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_progressStatsKey);
  }
}
