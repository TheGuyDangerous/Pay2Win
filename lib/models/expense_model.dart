import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  final String id;
  final String duoId;
  final String userId;
  final double amount;
  final String category;
  final String description;
  final DateTime timestamp;
  final String? receiptUrl;
  final String paymentMethod;
  
  ExpenseModel({
    required this.id,
    required this.duoId,
    required this.userId,
    required this.amount,
    required this.category,
    required this.description,
    required this.timestamp,
    this.receiptUrl,
    required this.paymentMethod,
  });
  
  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as String,
      duoId: json['duoId'] as String,
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      description: json['description'] as String,
      timestamp: json['timestamp'] is Timestamp 
          ? (json['timestamp'] as Timestamp).toDate()
          : DateTime.parse(json['timestamp'].toString()),
      receiptUrl: json['receiptUrl'] as String?,
      paymentMethod: json['paymentMethod'] as String,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'duoId': duoId,
      'userId': userId,
      'amount': amount,
      'category': category,
      'description': description,
      'timestamp': Timestamp.fromDate(timestamp),
      'receiptUrl': receiptUrl,
      'paymentMethod': paymentMethod,
    };
  }
  
  ExpenseModel copyWith({
    String? id,
    String? duoId,
    String? userId,
    double? amount,
    String? category,
    String? description,
    DateTime? timestamp,
    String? receiptUrl,
    String? paymentMethod,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      duoId: duoId ?? this.duoId,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
  
  // Helper method to check if expense is from today
  bool get isToday {
    final now = DateTime.now();
    return timestamp.year == now.year &&
        timestamp.month == now.month &&
        timestamp.day == now.day;
  }
  
  // Helper method to check if expense is from this week
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return timestamp.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        timestamp.isBefore(endOfWeek.add(const Duration(days: 1)));
  }
  
  // Helper method to check if expense is from this month
  bool get isThisMonth {
    final now = DateTime.now();
    return timestamp.year == now.year && timestamp.month == now.month;
  }
} 