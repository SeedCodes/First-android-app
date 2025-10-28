class ArcData {
  final String arcName;
  final int duration;
  final List<String> goals;
  final DateTime startDate;

  ArcData({
    required this.arcName,
    required this.duration,
    required this.goals,
    required this.startDate,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'arcName': arcName,
      'duration': duration,
      'goals': goals,
      'startDate': startDate.toIso8601String(),
    };
  }

  // Create from JSON
  factory ArcData.fromJson(Map<String, dynamic> json) {
    return ArcData(
      arcName: json['arcName'] as String,
      duration: json['duration'] as int,
      goals: List<String>.from(json['goals'] as List),
      startDate: DateTime.parse(json['startDate'] as String),
    );
  }

  // Calculate days remaining
  int getDaysRemaining() {
    final now = DateTime.now();
    final endDate = startDate.add(Duration(days: duration));
    final daysRemaining = endDate.difference(now).inDays;
    return daysRemaining > 0 ? daysRemaining : 0;
  }

  // Calculate days completed
  int getDaysCompleted() {
    final now = DateTime.now();
    final daysCompleted = now.difference(startDate).inDays;
    return daysCompleted < duration ? daysCompleted : duration;
  }

  // Calculate progress percentage
  double getProgressPercentage() {
    final daysCompleted = getDaysCompleted();
    return (daysCompleted / duration) * 100;
  }
}
