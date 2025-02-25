import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../models/expense_model.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart'; // Import to access useMockData

class ExpenseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get all expenses for a duo
  Future<List<ExpenseModel>> getExpenses(String duoId) async {
    try {
      // Check if we're using mock data
      if (useMockData) {
        // Use local storage for mock data
        final prefs = await SharedPreferences.getInstance();
        final expensesJson = prefs.getStringList('expenses_$duoId') ?? [];
        
        // Convert JSON strings to ExpenseModel objects
        return expensesJson
            .map((json) => ExpenseModel.fromJson(jsonDecode(json)))
            .toList()
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Sort by timestamp, newest first
      } else {
        // Use Firestore for real data
        final querySnapshot = await _firestore
            .collection(AppConstants.collectionExpenses)
            .doc(duoId)
            .collection('items')
            .orderBy('timestamp', descending: true)
            .get();
        
        return querySnapshot.docs
            .map((doc) => ExpenseModel.fromJson(doc.data()))
            .toList();
      }
    } catch (e) {
      print('Failed to get expenses: $e');
      throw Exception('Failed to get expenses: ${e.toString()}');
    }
  }
  
  // Get recent expenses for a duo
  Future<List<ExpenseModel>> getRecentExpenses(String duoId) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.collectionExpenses)
          .doc(duoId)
          .collection('items')
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();
      
      return querySnapshot.docs
          .map((doc) => ExpenseModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get recent expenses: ${e.toString()}');
    }
  }
  
  // Get expenses by category
  Future<List<ExpenseModel>> getExpensesByCategory(
    String duoId,
    String category,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.collectionExpenses)
          .doc(duoId)
          .collection('items')
          .where('category', isEqualTo: category)
          .orderBy('timestamp', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => ExpenseModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get expenses by category: ${e.toString()}');
    }
  }
  
  // Get expenses by date range
  Future<List<ExpenseModel>> getExpensesByDateRange(
    String duoId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.collectionExpenses)
          .doc(duoId)
          .collection('items')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('timestamp', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => ExpenseModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get expenses by date range: ${e.toString()}');
    }
  }
  
  // Add a new expense
  Future<String> addExpense(String duoId, ExpenseModel expense) async {
    try {
      // Check if we're using mock data
      if (useMockData) {
        // Use local storage for mock data
        final prefs = await SharedPreferences.getInstance();
        
        // Generate a random ID
        final expenseId = DateTime.now().millisecondsSinceEpoch.toString();
        final expenseWithId = expense.copyWith(id: expenseId);
        
        // Get existing expenses from local storage
        final expensesJson = prefs.getStringList('expenses_$duoId') ?? [];
        
        // Add the new expense
        expensesJson.add(jsonEncode(expenseWithId.toJson()));
        
        // Save back to local storage
        await prefs.setStringList('expenses_$duoId', expensesJson);
        
        print('Added mock expense with ID: $expenseId');
        return expenseId;
      } else {
        // Use Firestore for real data
        final docRef = _firestore
            .collection(AppConstants.collectionExpenses)
            .doc(duoId)
            .collection('items')
            .doc();
        
        final expenseWithId = expense.copyWith(id: docRef.id);
        
        await docRef.set(expenseWithId.toJson());
        
        return docRef.id;
      }
    } catch (e) {
      print('Error adding expense: $e');
      throw Exception('Failed to add expense: ${e.toString()}');
    }
  }
  
  // Update an existing expense
  Future<bool> updateExpense(String duoId, ExpenseModel expense) async {
    try {
      await _firestore
          .collection(AppConstants.collectionExpenses)
          .doc(duoId)
          .collection('items')
          .doc(expense.id)
          .update(expense.toJson());
      
      return true;
    } catch (e) {
      throw Exception('Failed to update expense: ${e.toString()}');
    }
  }
  
  // Delete an expense
  Future<bool> deleteExpense(String duoId, String expenseId) async {
    try {
      await _firestore
          .collection(AppConstants.collectionExpenses)
          .doc(duoId)
          .collection('items')
          .doc(expenseId)
          .delete();
      
      return true;
    } catch (e) {
      throw Exception('Failed to delete expense: ${e.toString()}');
    }
  }
} 