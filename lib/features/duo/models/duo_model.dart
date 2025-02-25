import 'package:cloud_firestore/cloud_firestore.dart';

class DuoModel {
  final String id;
  final String code;
  final String user1Id;
  final String user1Name;
  final String? user2Id;
  final String? user2Name;
  final DateTime createdAt;
  final bool isActive;
  
  const DuoModel({
    required this.id,
    required this.code,
    required this.user1Id,
    required this.user1Name,
    this.user2Id,
    this.user2Name,
    required this.createdAt,
    required this.isActive,
  });
  
  factory DuoModel.fromJson(Map<String, dynamic> json) {
    return DuoModel(
      id: json['id'] as String,
      code: json['code'] as String,
      user1Id: json['user1Id'] as String,
      user1Name: json['user1Name'] as String,
      user2Id: json['user2Id'] as String?,
      user2Name: json['user2Name'] as String?,
      createdAt: json['createdAt'] is Timestamp 
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt'].toString()),
      isActive: json['isActive'] as bool,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'user1Id': user1Id,
      'user1Name': user1Name,
      'user2Id': user2Id,
      'user2Name': user2Name,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
    };
  }
  
  // Create a copy of the duo with updated fields
  DuoModel copyWith({
    String? id,
    String? code,
    String? user1Id,
    String? user1Name,
    String? user2Id,
    String? user2Name,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return DuoModel(
      id: id ?? this.id,
      code: code ?? this.code,
      user1Id: user1Id ?? this.user1Id,
      user1Name: user1Name ?? this.user1Name,
      user2Id: user2Id ?? this.user2Id,
      user2Name: user2Name ?? this.user2Name,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
  
  // Check if the duo is complete (has both users)
  bool get isComplete => user2Id != null && user2Name != null;
  
  // Get the partner ID for the given user
  String? getPartnerId(String userId) {
    if (userId == user1Id) {
      return user2Id;
    } else if (userId == user2Id) {
      return user1Id;
    }
    return null;
  }
  
  // Get the partner name for the given user
  String? getPartnerName(String userId) {
    if (userId == user1Id) {
      return user2Name;
    } else if (userId == user2Id) {
      return user1Name;
    }
    return null;
  }
} 