import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? profilePicture;
  final double monthlySalary;
  final List<String> savingGoals;
  final DateTime createdAt;
  final DateTime lastActive;
  final String? duoId;
  
  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.profilePicture,
    required this.monthlySalary,
    required this.savingGoals,
    required this.createdAt,
    required this.lastActive,
    this.duoId,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      profilePicture: json['profilePicture'] as String?,
      monthlySalary: (json['monthlySalary'] as num).toDouble(),
      savingGoals: List<String>.from(json['savingGoals'] as List),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      lastActive: (json['lastActive'] as Timestamp).toDate(),
      duoId: json['duoId'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'profilePicture': profilePicture,
      'monthlySalary': monthlySalary,
      'savingGoals': savingGoals,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActive': Timestamp.fromDate(lastActive),
      'duoId': duoId,
    };
  }
  
  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? profilePicture,
    double? monthlySalary,
    List<String>? savingGoals,
    DateTime? createdAt,
    DateTime? lastActive,
    String? duoId,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      profilePicture: profilePicture ?? this.profilePicture,
      monthlySalary: monthlySalary ?? this.monthlySalary,
      savingGoals: savingGoals ?? this.savingGoals,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      duoId: duoId ?? this.duoId,
    );
  }
  
  factory UserModel.empty() {
    return UserModel(
      id: '',
      email: '',
      displayName: '',
      profilePicture: null,
      monthlySalary: 0.0,
      savingGoals: [],
      createdAt: DateTime.now(),
      lastActive: DateTime.now(),
      duoId: null,
    );
  }
} 