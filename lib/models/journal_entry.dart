class JournalEntry {
  final DateTime date;
  final String content;
  final String? mood;
  final String? photoPath;
  final String? weeklyReflection;

  JournalEntry({
    required this.date,
    required this.content,
    this.mood,
    this.photoPath,
    this.weeklyReflection,
  });

  // Check if this entry is for today
  bool isToday() {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Check if entry has weekly reflection
  bool get hasWeeklyReflection => 
      weeklyReflection != null && weeklyReflection!.isNotEmpty;

  // Check if entry is empty
  bool get isEmpty => 
      content.isEmpty && mood == null && photoPath == null;

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'content': content,
      'mood': mood,
      'photoPath': photoPath,
      'weeklyReflection': weeklyReflection,
    };
  }

  // Create from JSON
  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      date: DateTime.parse(json['date'] as String),
      content: json['content'] as String? ?? '',
      mood: json['mood'] as String?,
      photoPath: json['photoPath'] as String?,
      weeklyReflection: json['weeklyReflection'] as String?,
    );
  }

  // Create a copy with updated values
  JournalEntry copyWith({
    DateTime? date,
    String? content,
    String? mood,
    String? photoPath,
    String? weeklyReflection,
  }) {
    return JournalEntry(
      date: date ?? this.date,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      photoPath: photoPath ?? this.photoPath,
      weeklyReflection: weeklyReflection ?? this.weeklyReflection,
    );
  }

  // Get formatted date string
  String getFormattedDate() {
    final months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month]} ${date.day}, ${date.year}';
  }

  // Get short date string
  String getShortDate() {
    return '${date.month}/${date.day}/${date.year}';
  }

  // Get day of week
  String getDayOfWeek() {
    const days = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[date.weekday];
  }

  // Get content preview
  String getPreview({int maxLength = 100}) {
    if (content.isEmpty) return 'No entry';
    if (content.length <= maxLength) return content;
    return '${content.substring(0, maxLength)}...';
  }
}
