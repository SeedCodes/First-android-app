class AppSettings {
  final int themeIndex; // 0: Default Dark, 1: Minimal, 2: Warrior
  final bool notificationsEnabled;
  final int notificationHour;
  final int notificationMinute;
  final int motivationStyle; // 0: Short Tips, 1: Quotes, 2: Custom

  AppSettings({
    required this.themeIndex,
    required this.notificationsEnabled,
    required this.notificationHour,
    required this.notificationMinute,
    required this.motivationStyle,
  });

  // Create default settings
  factory AppSettings.defaultSettings() {
    return AppSettings(
      themeIndex: 0,
      notificationsEnabled: true,
      notificationHour: 9,
      notificationMinute: 0,
      motivationStyle: 0,
    );
  }

  // Get theme name
  String getThemeName() {
    switch (themeIndex) {
      case 0:
        return 'Default Dark';
      case 1:
        return 'Minimal';
      case 2:
        return 'Warrior';
      default:
        return 'Default Dark';
    }
  }

  // Get motivation style name
  String getMotivationStyleName() {
    switch (motivationStyle) {
      case 0:
        return 'Short Tips';
      case 1:
        return 'Quotes';
      case 2:
        return 'Custom';
      default:
        return 'Short Tips';
    }
  }

  // Get formatted notification time
  String getFormattedNotificationTime() {
    final hour = notificationHour.toString().padLeft(2, '0');
    final minute = notificationMinute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'themeIndex': themeIndex,
      'notificationsEnabled': notificationsEnabled,
      'notificationHour': notificationHour,
      'notificationMinute': notificationMinute,
      'motivationStyle': motivationStyle,
    };
  }

  // Create from JSON
  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeIndex: json['themeIndex'] as int? ?? 0,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      notificationHour: json['notificationHour'] as int? ?? 9,
      notificationMinute: json['notificationMinute'] as int? ?? 0,
      motivationStyle: json['motivationStyle'] as int? ?? 0,
    );
  }

  // Create a copy with updated values
  AppSettings copyWith({
    int? themeIndex,
    bool? notificationsEnabled,
    int? notificationHour,
    int? notificationMinute,
    int? motivationStyle,
  }) {
    return AppSettings(
      themeIndex: themeIndex ?? this.themeIndex,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationHour: notificationHour ?? this.notificationHour,
      notificationMinute: notificationMinute ?? this.notificationMinute,
      motivationStyle: motivationStyle ?? this.motivationStyle,
    );
  }
}
