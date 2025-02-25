class AchievementModel {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String description;
  final DateTime earnedAt;
  final String? iconPath;
  final int points;
  
  AchievementModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.description,
    required this.earnedAt,
    this.iconPath,
    required this.points,
  });
  
  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      earnedAt: DateTime.parse(json['earnedAt'] as String),
      iconPath: json['iconPath'] as String?,
      points: json['points'] as int,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'title': title,
      'description': description,
      'earnedAt': earnedAt.toIso8601String(),
      'iconPath': iconPath,
      'points': points,
    };
  }
  
  AchievementModel copyWith({
    String? id,
    String? userId,
    String? type,
    String? title,
    String? description,
    DateTime? earnedAt,
    String? iconPath,
    int? points,
  }) {
    return AchievementModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      earnedAt: earnedAt ?? this.earnedAt,
      iconPath: iconPath ?? this.iconPath,
      points: points ?? this.points,
    );
  }
  
  // Helper method to check if achievement is recent (earned in the last 7 days)
  bool get isRecent {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    return earnedAt.isAfter(sevenDaysAgo);
  }
  
  // Helper method to get formatted earned date
  String get formattedEarnedDate {
    final day = earnedAt.day.toString().padLeft(2, '0');
    final month = earnedAt.month.toString().padLeft(2, '0');
    final year = earnedAt.year.toString();
    return '$day/$month/$year';
  }
}

// Achievement Types
class AchievementTypes {
  static const String savingsMilestone = 'Savings Milestone';
  static const String streak = 'Streak';
  static const String challengeCompletion = 'Challenge Completion';
  static const String budgetAdherence = 'Budget Adherence';
  static const String appUsage = 'App Usage';
}

// Predefined Achievements
class PredefinedAchievements {
  static AchievementModel firstSaving({required String userId}) {
    return AchievementModel(
      id: 'first_saving_$userId',
      userId: userId,
      type: AchievementTypes.savingsMilestone,
      title: 'First Saving',
      description: 'Made your first saving by spending less than your daily budget.',
      earnedAt: DateTime.now(),
      iconPath: 'assets/images/achievements/first_saving.png',
      points: 10,
    );
  }
  
  static AchievementModel threeDayStreak({required String userId}) {
    return AchievementModel(
      id: 'three_day_streak_$userId',
      userId: userId,
      type: AchievementTypes.streak,
      title: '3-Day Streak',
      description: 'Stayed under budget for 3 consecutive days.',
      earnedAt: DateTime.now(),
      iconPath: 'assets/images/achievements/three_day_streak.png',
      points: 20,
    );
  }
  
  static AchievementModel sevenDayStreak({required String userId}) {
    return AchievementModel(
      id: 'seven_day_streak_$userId',
      userId: userId,
      type: AchievementTypes.streak,
      title: '7-Day Streak',
      description: 'Stayed under budget for a full week.',
      earnedAt: DateTime.now(),
      iconPath: 'assets/images/achievements/seven_day_streak.png',
      points: 50,
    );
  }
  
  static AchievementModel firstChallengeCompleted({required String userId}) {
    return AchievementModel(
      id: 'first_challenge_completed_$userId',
      userId: userId,
      type: AchievementTypes.challengeCompletion,
      title: 'Challenge Champion',
      description: 'Successfully completed your first saving challenge.',
      earnedAt: DateTime.now(),
      iconPath: 'assets/images/achievements/first_challenge.png',
      points: 30,
    );
  }
  
  static AchievementModel perfectMonth({required String userId}) {
    return AchievementModel(
      id: 'perfect_month_$userId',
      userId: userId,
      type: AchievementTypes.budgetAdherence,
      title: 'Perfect Month',
      description: 'Stayed under budget for an entire month.',
      earnedAt: DateTime.now(),
      iconPath: 'assets/images/achievements/perfect_month.png',
      points: 100,
    );
  }
} 