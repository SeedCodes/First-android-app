class ProgressStats {
  final List<DateTime> completedDates;
  final int currentStreak;
  final int longestStreak;
  final int missedDays;

  ProgressStats({
    required this.completedDates,
    required this.currentStreak,
    required this.longestStreak,
    required this.missedDays,
  });

  // Create empty stats
  factory ProgressStats.create() {
    return ProgressStats(
      completedDates: [],
      currentStreak: 0,
      longestStreak: 0,
      missedDays: 0,
    );
  }

  // Mark a date as completed
  ProgressStats markDateCompleted(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final newCompletedDates = List<DateTime>.from(completedDates);
    
    if (!newCompletedDates.any((d) => 
        d.year == normalizedDate.year && 
        d.month == normalizedDate.month && 
        d.day == normalizedDate.day)) {
      newCompletedDates.add(normalizedDate);
    }

    return ProgressStats(
      completedDates: newCompletedDates,
      currentStreak: _calculateCurrentStreak(newCompletedDates),
      longestStreak: _calculateLongestStreak(newCompletedDates),
      missedDays: missedDays,
    );
  }

  // Mark a day as missed
  ProgressStats markDayMissed() {
    return ProgressStats(
      completedDates: completedDates,
      currentStreak: 0, // Break the streak
      longestStreak: longestStreak,
      missedDays: missedDays + 1,
    );
  }

  // Check if a date is completed
  bool isDateCompleted(DateTime date) {
    return completedDates.any((d) =>
        d.year == date.year && d.month == date.month && d.day == date.day);
  }

  // Calculate success rate
  double getSuccessRate() {
    final totalDays = completedDates.length + missedDays;
    if (totalDays == 0) return 0.0;
    return (completedDates.length / totalDays) * 100;
  }

  // Calculate current streak
  static int _calculateCurrentStreak(List<DateTime> dates) {
    if (dates.isEmpty) return 0;

    final sortedDates = List<DateTime>.from(dates)
      ..sort((a, b) => b.compareTo(a)); // Sort descending

    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);

    int streak = 0;
    DateTime checkDate = todayNormalized;

    for (var date in sortedDates) {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      
      if (normalizedDate.isAtSameMomentAs(checkDate)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (normalizedDate.isBefore(checkDate)) {
        break;
      }
    }

    return streak;
  }

  // Calculate longest streak
  static int _calculateLongestStreak(List<DateTime> dates) {
    if (dates.isEmpty) return 0;

    final sortedDates = List<DateTime>.from(dates)
      ..sort((a, b) => a.compareTo(b)); // Sort ascending

    int longestStreak = 1;
    int currentStreak = 1;

    for (int i = 1; i < sortedDates.length; i++) {
      final prevDate = sortedDates[i - 1];
      final currDate = sortedDates[i];
      
      final dayDifference = currDate.difference(prevDate).inDays;

      if (dayDifference == 1) {
        currentStreak++;
        if (currentStreak > longestStreak) {
          longestStreak = currentStreak;
        }
      } else {
        currentStreak = 1;
      }
    }

    return longestStreak;
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'completedDates': completedDates.map((d) => d.toIso8601String()).toList(),
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'missedDays': missedDays,
    };
  }

  // Create from JSON
  factory ProgressStats.fromJson(Map<String, dynamic> json) {
    return ProgressStats(
      completedDates: (json['completedDates'] as List)
          .map((d) => DateTime.parse(d as String))
          .toList(),
      currentStreak: json['currentStreak'] as int,
      longestStreak: json['longestStreak'] as int,
      missedDays: json['missedDays'] as int,
    );
  }

  // Create a copy with updated values
  ProgressStats copyWith({
    List<DateTime>? completedDates,
    int? currentStreak,
    int? longestStreak,
    int? missedDays,
  }) {
    return ProgressStats(
      completedDates: completedDates ?? List<DateTime>.from(this.completedDates),
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      missedDays: missedDays ?? this.missedDays,
    );
  }
}
