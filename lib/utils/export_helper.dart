import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/arc_data.dart';
import '../models/progress_stats.dart';
import '../models/journal_entry.dart';
import '../models/app_settings.dart';
import '../utils/storage_helper.dart';

class ExportHelper {
  // Export all data as JSON
  static Future<void> exportAllData() async {
    try {
      // Load all data
      final arcData = await StorageHelper.loadArcData();
      final progressStats = await StorageHelper.loadProgressStats();
      final journalEntries = await StorageHelper.loadJournalEntries();
      final settings = await StorageHelper.loadAppSettings();

      // Create export object
      final exportData = {
        'export_date': DateTime.now().toIso8601String(),
        'app_version': '1.0.0',
        'arc_data': arcData?.toJson(),
        'progress_stats': progressStats?.toJson(),
        'journal_entries': journalEntries.map((e) => e.toJson()).toList(),
        'settings': settings?.toJson(),
      };

      // Convert to JSON string
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/winter_arc_backup_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(jsonString);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Winter Arc Data Export',
        text: 'Your Winter Arc data backup',
      );
    } catch (e) {
      throw Exception('Failed to export data: $e');
    }
  }

  // Export as readable text summary
  static Future<void> exportSummary() async {
    try {
      final arcData = await StorageHelper.loadArcData();
      final progressStats = await StorageHelper.loadProgressStats();
      final journalEntries = await StorageHelper.loadJournalEntries();

      if (arcData == null) {
        throw Exception('No arc data found');
      }

      final summary = StringBuffer();
      summary.writeln('═══════════════════════════════');
      summary.writeln('   WINTER ARC SUMMARY');
      summary.writeln('═══════════════════════════════\n');

      // Arc Info
      summary.writeln('📊 ARC DETAILS');
      summary.writeln('Name: ${arcData.arcName}');
      summary.writeln('Duration: ${arcData.duration} days');
      summary.writeln('Started: ${arcData.startDate.toString().split(' ')[0]}');
      summary.writeln('Day: ${arcData.getDaysCompleted()}/${arcData.duration}');
      summary.writeln('Progress: ${arcData.getProgressPercentage().toStringAsFixed(1)}%\n');

      // Goals
      summary.writeln('🎯 GOALS');
      for (final goal in arcData.goals) {
        summary.writeln('  • $goal');
      }
      summary.writeln();

      // Progress Stats
      if (progressStats != null) {
        summary.writeln('📈 STATISTICS');
        summary.writeln('Current Streak: ${progressStats.currentStreak} days');
        summary.writeln('Best Streak: ${progressStats.longestStreak} days');
        summary.writeln('Success Rate: ${progressStats.getSuccessRate().toStringAsFixed(1)}%');
        summary.writeln('Missed Days: ${progressStats.missedDays}\n');
      }

      // Journal Summary
      if (journalEntries.isNotEmpty) {
        summary.writeln('📔 JOURNAL ENTRIES');
        summary.writeln('Total Entries: ${journalEntries.length}');
        
        final moodCounts = <String, int>{};
        for (final entry in journalEntries) {
          if (entry.mood != null) {
            moodCounts[entry.mood!] = (moodCounts[entry.mood!] ?? 0) + 1;
          }
        }
        
        if (moodCounts.isNotEmpty) {
          summary.writeln('\nMood Distribution:');
          moodCounts.forEach((mood, count) {
            summary.writeln('  $mood: $count times');
          });
        }
        summary.writeln();
      }

      summary.writeln('═══════════════════════════════');
      summary.writeln('Generated: ${DateTime.now()}');
      summary.writeln('Stay locked in! 💪❄️');

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/winter_arc_summary_${DateTime.now().millisecondsSinceEpoch}.txt');
      await file.writeAsString(summary.toString());

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Winter Arc Summary',
        text: 'My Winter Arc journey summary',
      );
    } catch (e) {
      throw Exception('Failed to export summary: $e');
    }
  }

  // Export journal as text
  static Future<void> exportJournal() async {
    try {
      final journalEntries = await StorageHelper.loadJournalEntries();

      if (journalEntries.isEmpty) {
        throw Exception('No journal entries found');
      }

      final journal = StringBuffer();
      journal.writeln('═══════════════════════════════');
      journal.writeln('   WINTER ARC JOURNAL');
      journal.writeln('═══════════════════════════════\n');

      for (final entry in journalEntries) {
        journal.writeln('─────────────────────────────');
        journal.writeln(entry.getFormattedDate());
        if (entry.mood != null) {
          journal.writeln('Mood: ${entry.mood}');
        }
        journal.writeln();
        journal.writeln(entry.content);
        
        if (entry.hasWeeklyReflection) {
          journal.writeln();
          journal.writeln('✨ WEEKLY REFLECTION:');
          journal.writeln(entry.weeklyReflection);
        }
        
        journal.writeln();
      }

      journal.writeln('═══════════════════════════════');
      journal.writeln('Total Entries: ${journalEntries.length}');
      journal.writeln('Stay locked in! 💪❄️');

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/winter_arc_journal_${DateTime.now().millisecondsSinceEpoch}.txt');
      await file.writeAsString(journal.toString());

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Winter Arc Journal',
        text: 'My Winter Arc journal entries',
      );
    } catch (e) {
      throw Exception('Failed to export journal: $e');
    }
  }
}
