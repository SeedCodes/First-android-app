import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/arc_data.dart';
import '../models/daily_progress.dart';
import '../models/progress_stats.dart';
import '../models/journal_entry.dart';
import '../models/app_settings.dart';

class StorageHelper {
  static const String _arcDataKey = 'arc_data';
  static const String _dailyProgressKey = 'daily_progress';
  static const String _progressStatsKey = 'progress_stats';
  static const String _journalEntriesKey = 'journal_entries';
  static const String _appSettingsKey = 'app_settings';

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

  // Save journal entries
  static Future<void> saveJournalEntries(List<JournalEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = entries.map((entry) => entry.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await prefs.setString(_journalEntriesKey, jsonString);
  }

  // Load journal entries
  static Future<List<JournalEntry>> loadJournalEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_journalEntriesKey);
    
    if (jsonString == null) {
      return [];
    }

    final jsonList = jsonDecode(jsonString) as List;
    return jsonList
        .map((json) => JournalEntry.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // Clear journal entries
  static Future<void> clearJournalEntries() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_journalEntriesKey);
  }

  // Save app settings
  static Future<void> saveAppSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(settings.toJson());
    await prefs.setString(_appSettingsKey, jsonString);
  }

  // Load app settings
  static Future<AppSettings?> loadAppSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_appSettingsKey);
    
    if (jsonString == null) {
      return null;
    }

    final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
    return AppSettings.fromJson(jsonData);
  }

  // Clear app settings
  static Future<void> clearAppSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_appSettingsKey);
  }
}
