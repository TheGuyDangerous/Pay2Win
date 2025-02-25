import 'package:cloud_firestore/cloud_firestore.dart';

class DuoModel {
  final String id;
  final String user1Id;
  final String user2Id;
  final DateTime createdAt;
  final bool isActive;
  final String? duoCode;
  
  DuoModel({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.createdAt,
    required this.isActive,
    this.duoCode,
  });
  
  factory DuoModel.fromJson(Map<String, dynamic> json) {
    return DuoModel(
      id: json['id'] as String,
      user1Id: json['user1Id'] as String,
      user2Id: json['user2Id'] as String,
      createdAt: json['createdAt'] is Timestamp 
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt'].toString()),
      isActive: json['isActive'] as bool,
      duoCode: json['duoCode'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user1Id': user1Id,
      'user2Id': user2Id,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      'duoCode': duoCode,
    };
  }
  
  DuoModel copyWith({
    String? id,
    String? user1Id,
    String? user2Id,
    DateTime? createdAt,
    bool? isActive,
    String? duoCode,
  }) {
    return DuoModel(
      id: id ?? this.id,
      user1Id: user1Id ?? this.user1Id,
      user2Id: user2Id ?? this.user2Id,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      duoCode: duoCode ?? this.duoCode,
    );
  }
  
  String? getPartnerUserId(String userId) {
    if (user1Id == userId) {
      return user2Id;
    } else if (user2Id == userId) {
      return user1Id;
    }
    return null;
  }
}

class DuoUser {
  final String userId;
  final DateTime joinedAt;
  
  DuoUser({
    required this.userId,
    required this.joinedAt,
  });
  
  factory DuoUser.fromJson(Map<String, dynamic> json) {
    return DuoUser(
      userId: json['userId'] as String,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }
} 