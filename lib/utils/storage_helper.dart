import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/arc_data.dart';

class StorageHelper {
  static const String _arcDataKey = 'arc_data';

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
}
