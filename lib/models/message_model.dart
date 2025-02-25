import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String duoId;
  final String userId;
  final String text;
  final DateTime timestamp;
  final bool hasExpense;
  final String? expenseId;
  final List<MessageReaction>? reactions;
  
  MessageModel({
    required this.id,
    required this.duoId,
    required this.userId,
    required this.text,
    required this.timestamp,
    required this.hasExpense,
    this.expenseId,
    this.reactions,
  });
  
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      duoId: json['duoId'] as String,
      userId: json['userId'] as String,
      text: json['text'] as String,
      timestamp: json['timestamp'] is Timestamp 
          ? (json['timestamp'] as Timestamp).toDate()
          : DateTime.parse(json['timestamp'].toString()),
      hasExpense: json['hasExpense'] as bool,
      expenseId: json['expenseId'] as String?,
      reactions: json['reactions'] != null
          ? (json['reactions'] as List)
              .map((e) => MessageReaction.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'duoId': duoId,
      'userId': userId,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'hasExpense': hasExpense,
      'expenseId': expenseId,
      'reactions': reactions?.map((e) => e.toJson()).toList(),
    };
  }
  
  MessageModel copyWith({
    String? id,
    String? duoId,
    String? userId,
    String? text,
    DateTime? timestamp,
    bool? hasExpense,
    String? expenseId,
    List<MessageReaction>? reactions,
  }) {
    return MessageModel(
      id: id ?? this.id,
      duoId: duoId ?? this.duoId,
      userId: userId ?? this.userId,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      hasExpense: hasExpense ?? this.hasExpense,
      expenseId: expenseId ?? this.expenseId,
      reactions: reactions ?? this.reactions,
    );
  }
  
  // Helper method to check if message is from today
  bool get isToday {
    final now = DateTime.now();
    return timestamp.year == now.year &&
        timestamp.month == now.month &&
        timestamp.day == now.day;
  }
  
  // Helper method to format time for display
  String get formattedTime {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
  
  // Helper method to format date for display
  String get formattedDate {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    
    if (timestamp.year == now.year &&
        timestamp.month == now.month &&
        timestamp.day == now.day) {
      return 'Today';
    } else if (timestamp.year == yesterday.year &&
        timestamp.month == yesterday.month &&
        timestamp.day == yesterday.day) {
      return 'Yesterday';
    } else {
      final day = timestamp.day.toString().padLeft(2, '0');
      final month = timestamp.month.toString().padLeft(2, '0');
      final year = timestamp.year.toString();
      return '$day/$month/$year';
    }
  }
}

class MessageReaction {
  final String userId;
  final String reaction;
  final DateTime timestamp;
  
  MessageReaction({
    required this.userId,
    required this.reaction,
    required this.timestamp,
  });
  
  factory MessageReaction.fromJson(Map<String, dynamic> json) {
    return MessageReaction(
      userId: json['userId'] as String,
      reaction: json['reaction'] as String,
      timestamp: json['timestamp'] is Timestamp 
          ? (json['timestamp'] as Timestamp).toDate()
          : DateTime.parse(json['timestamp'].toString()),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'reaction': reaction,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
} 