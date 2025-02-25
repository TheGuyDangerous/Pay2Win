import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/message_model.dart';
import '../../../services/messaging_service.dart';
import '../../../services/expense_service.dart';
import '../../../models/expense_model.dart';

class MessagingProvider extends ChangeNotifier {
  final MessagingService _messagingService = MessagingService();
  final ExpenseService _expenseService = ExpenseService();
  
  List<MessageModel> _messages = [];
  bool _isLoading = false;
  String? _error;
  
  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Get messages for a duo
  Future<void> getMessages(String duoId) async {
    _setLoading(true);
    
    try {
      _messages = await _messagingService.getMessages(duoId);
      
      // Setup real-time listener
      _setupRealTimeListener(duoId);
      
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  
  // Send a message
  Future<bool> sendMessage(
    String duoId,
    String userId,
    String text,
  ) async {
    _setLoading(true);
    
    try {
      final message = MessageModel(
        id: '',
        duoId: duoId,
        userId: userId,
        text: text,
        timestamp: DateTime.now(),
        hasExpense: false,
        expenseId: null,
      );
      
      final messageId = await _messagingService.sendMessage(duoId, message);
      
      if (messageId.isNotEmpty) {
        // Check if message contains expense information
        final expenseInfo = _parseExpenseFromMessage(text);
        
        if (expenseInfo != null) {
          // Create expense from message
          final expense = ExpenseModel(
            id: '',
            duoId: duoId,
            userId: userId,
            amount: expenseInfo['amount']!,
            category: expenseInfo['category']!,
            description: expenseInfo['description'] ?? text,
            timestamp: DateTime.now(),
            receiptUrl: null,
            paymentMethod: 'Other',
          );
          
          final expenseId = await _expenseService.addExpense(duoId, expense);
          
          if (expenseId.isNotEmpty) {
            // Update message with expense reference
            final updatedMessage = message.copyWith(
              id: messageId,
              hasExpense: true,
              expenseId: expenseId,
            );
            
            await _messagingService.updateMessage(duoId, updatedMessage);
          }
        }
        
        return true;
      }
      
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Delete a message
  Future<bool> deleteMessage(String duoId, String messageId) async {
    _setLoading(true);
    
    try {
      final success = await _messagingService.deleteMessage(duoId, messageId);
      
      if (success) {
        _messages.removeWhere((m) => m.id == messageId);
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Parse expense information from message text
  Map<String, dynamic>? _parseExpenseFromMessage(String text) {
    // Convert text to lowercase for case-insensitive comparison
    final lowercaseText = text.toLowerCase();
    
    // Define patterns for different types of expense mentions
    final List<RegExp> expensePatterns = [
      // Pattern: "Spent $X on Y"
      RegExp(r'(?:spent|paid|bought)\s+(?:[₹\$£€])?\s*(\d+(?:\.\d+)?)\s+(?:on|for)\s+(\w+[\s\w]*)', caseSensitive: false),
      
      // Pattern: "$X for Y"
      RegExp(r'(?:[₹\$£€])?\s*(\d+(?:\.\d+)?)\s+(?:on|for)\s+(\w+[\s\w]*)', caseSensitive: false),
      
      // Pattern: "Y expense $X"
      RegExp(r'(\w+[\s\w]*)\s+(?:expense|cost|bill|payment)\s+(?:is|was|of)?\s+(?:[₹\$£€])?\s*(\d+(?:\.\d+)?)', caseSensitive: false),
      
      // Pattern: "Y for $X"
      RegExp(r'(\w+[\s\w]*)\s+for\s+(?:[₹\$£€])?\s*(\d+(?:\.\d+)?)', caseSensitive: false),
    ];
    
    // Try each pattern
    for (final pattern in expensePatterns) {
      final match = pattern.firstMatch(lowercaseText);
      
      if (match != null) {
        double amount;
        String category;
        
        // Different patterns have different group order
        if (pattern.pattern.startsWith(r'(\w+')) {
          // Category is first, amount is second
          category = match.group(1) ?? 'Other';
          amount = double.tryParse(match.group(2) ?? '0') ?? 0.0;
        } else {
          // Amount is first, category is second
          amount = double.tryParse(match.group(1) ?? '0') ?? 0.0;
          category = match.group(2) ?? 'Other';
        }
        
        // Skip if amount is zero
        if (amount <= 0) continue;
        
        // Clean and capitalize the category
        category = category.trim();
        
        // Map common categories to standard ones
        final standardCategory = _mapToStandardCategory(category);
        
        return {
          'amount': amount,
          'category': standardCategory,
          'description': text,
        };
      }
    }
    
    return null;
  }
  
  // Map detected category text to standard categories
  String _mapToStandardCategory(String detectedCategory) {
    // Convert to lowercase and remove trailing punctuation
    final normalized = detectedCategory.toLowerCase().replaceAll(RegExp(r'[,.!?]$'), '');
    
    // Map of common terms to standard categories
    final Map<String, List<String>> categoryMapping = {
      'Food': ['food', 'lunch', 'dinner', 'breakfast', 'meal', 'restaurant', 'eating', 'eat', 'takeout', 'takeaway', 'groceries', 'grocery'],
      'Transportation': ['transport', 'uber', 'taxi', 'cab', 'ride', 'bus', 'train', 'metro', 'subway', 'travel', 'gas', 'petrol', 'fuel'],
      'Shopping': ['shopping', 'clothes', 'clothing', 'shoes', 'accessory', 'accessories', 'purchase', 'bought', 'mall', 'store', 'shop'],
      'Entertainment': ['movie', 'cinema', 'theatre', 'show', 'concert', 'game', 'entertainment', 'fun', 'party', 'club'],
      'Bills': ['bill', 'utility', 'electricity', 'water', 'gas', 'internet', 'phone', 'mobile', 'subscription', 'rent'],
      'Health': ['medicine', 'medical', 'doctor', 'healthcare', 'health', 'hospital', 'clinic', 'drug', 'pharmacy'],
      'Education': ['education', 'school', 'college', 'university', 'course', 'class', 'lecture', 'tuition', 'book', 'stationery'],
      'Personal': ['haircut', 'salon', 'spa', 'massage', 'personal', 'self-care', 'beauty'],
    };
    
    // Check if the normalized text contains any of the category keywords
    for (final entry in categoryMapping.entries) {
      for (final keyword in entry.value) {
        if (normalized.contains(keyword)) {
          return entry.key;
        }
      }
    }
    
    // If no match found, capitalize first letter of each word
    return normalized.split(' ').map((word) => 
      word.isNotEmpty 
        ? word[0].toUpperCase() + word.substring(1) 
        : '').join(' ');
  }
  
  // Setup real-time listener for messages
  void _setupRealTimeListener(String duoId) {
    FirebaseFirestore.instance
        .collection(AppConstants.collectionMessages)
        .doc(duoId)
        .collection('items')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .listen((snapshot) {
      _messages = snapshot.docs
          .map((doc) => MessageModel.fromJson(doc.data()))
          .toList();
      
      notifyListeners();
    });
  }
  
  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
} 