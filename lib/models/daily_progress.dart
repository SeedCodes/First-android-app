class DailyProgress {
  final Map<String, bool> goals;
  final DateTime date;

  DailyProgress({
    required this.goals,
    required this.date,
  });

  // Create new daily progress from goals list
  factory DailyProgress.create(List<String> goalsList) {
    final goals = <String, bool>{};
    for (final goal in goalsList) {
      goals[goal] = false;
    }
    return DailyProgress(
      goals: goals,
      date: DateTime.now(),
    );
  }

  // Toggle goal completion
  void toggleGoal(String goalName) {
    if (goals.containsKey(goalName)) {
      goals[goalName] = !goals[goalName]!;
    }
  }

  // Get number of completed goals
  int getCompletedCount() {
    return goals.values.where((completed) => completed).length;
  }

  // Get completion percentage
  double getCompletionPercentage() {
    if (goals.isEmpty) return 0.0;
    return (getCompletedCount() / goals.length) * 100;
  }

  // Check if all goals are completed
  bool isFullyCompleted() {
    return goals.isNotEmpty && goals.values.every((completed) => completed);
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'goals': goals,
      'date': date.toIso8601String(),
    };
  }

  // Create from JSON
  factory DailyProgress.fromJson(Map<String, dynamic> json) {
    return DailyProgress(
      goals: Map<String, bool>.from(json['goals'] as Map),
      date: DateTime.parse(json['date'] as String),
    );
  }

  // Check if this progress is for today
  bool isToday() {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Create a copy with updated values
  DailyProgress copyWith({
    Map<String, bool>? goals,
    DateTime? date,
  }) {
    return DailyProgress(
      goals: goals ?? Map<String, bool>.from(this.goals),
      date: date ?? this.date,
    );
  }
}
