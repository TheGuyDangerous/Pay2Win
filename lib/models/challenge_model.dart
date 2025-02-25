import 'package:cloud_firestore/cloud_firestore.dart';

class ChallengeModel {
  final String id;
  final String title;
  final String description;
  final String createdBy;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // 'active', 'completed', 'failed'
  final Map<String, bool> participants; // userId: hasCompleted
  
  ChallengeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdBy,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.participants,
  });
  
  // Create a copy of the challenge with updated fields
  ChallengeModel copyWith({
    String? id,
    String? title,
    String? description,
    String? createdBy,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    Map<String, bool>? participants,
  }) {
    return ChallengeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      participants: participants ?? this.participants,
    );
  }
  
  // Convert challenge to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdBy': createdBy,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'status': status,
      'participants': participants,
    };
  }
  
  // Create challenge from JSON
  factory ChallengeModel.fromJson(Map<String, dynamic> json) {
    return ChallengeModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      createdBy: json['createdBy'] as String,
      startDate: (json['startDate'] as Timestamp).toDate(),
      endDate: (json['endDate'] as Timestamp).toDate(),
      status: json['status'] as String,
      participants: Map<String, bool>.from(json['participants'] as Map),
    );
  }
  
  // Create empty challenge
  factory ChallengeModel.empty() {
    return ChallengeModel(
      id: '',
      title: '',
      description: '',
      createdBy: '',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 7)),
      status: 'active',
      participants: {},
    );
  }
  
  // Helper method to check if challenge is active
  bool get isActive => status == 'active';
  
  // Helper method to check if challenge is completed
  bool get isCompleted => status == 'completed';
  
  // Helper method to check if challenge is failed
  bool get isFailed => status == 'failed';
  
  // Helper method to check if challenge is in progress
  bool get isInProgress {
    final now = DateTime.now();
    return isActive && now.isAfter(startDate) && now.isBefore(endDate);
  }
  
  // Helper method to check if challenge is upcoming
  bool get isUpcoming {
    final now = DateTime.now();
    return isActive && now.isBefore(startDate);
  }
  
  // Helper method to check if challenge is expired
  bool get isExpired {
    final now = DateTime.now();
    return isActive && now.isAfter(endDate);
  }
  
  // Helper method to get duration in days
  int get durationInDays {
    return endDate.difference(startDate).inDays;
  }
  
  // Helper method to get remaining days
  int get remainingDays {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }
  
  // Helper method to get progress percentage
  double get progressPercentage {
    final now = DateTime.now();
    if (now.isBefore(startDate)) return 0;
    if (now.isAfter(endDate)) return 100;
    
    final totalDuration = endDate.difference(startDate).inSeconds;
    final elapsedDuration = now.difference(startDate).inSeconds;
    
    return (elapsedDuration / totalDuration) * 100;
  }
} 