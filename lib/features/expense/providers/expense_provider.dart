import 'package:flutter/material.dart';
import '../../../models/expense_model.dart';
import '../../../services/expense_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final ExpenseService _expenseService = ExpenseService();
  
  List<ExpenseModel> _expenses = [];
  ExpenseModel? _selectedExpense;
  bool _isLoading = false;
  String? _error;
  
  List<ExpenseModel> get expenses => _expenses;
  ExpenseModel? get selectedExpense => _selectedExpense;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Get expenses for a duo
  Future<void> getExpenses(String duoId) async {
    _setLoading(true);
    
    try {
      _expenses = await _expenseService.getExpenses(duoId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  
  // Get expenses by category
  Future<void> getExpensesByCategory(String duoId, String category) async {
    _setLoading(true);
    
    try {
      _expenses = await _expenseService.getExpensesByCategory(duoId, category);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  
  // Get expenses by date range
  Future<void> getExpensesByDateRange(
    String duoId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    _setLoading(true);
    
    try {
      _expenses = await _expenseService.getExpensesByDateRange(
        duoId,
        startDate,
        endDate,
      );
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  
  // Add a new expense
  Future<bool> addExpense(
    String duoId,
    String userId,
    double amount,
    String category,
    String description,
    String? receiptUrl,
    String paymentMethod,
    DateTime timestamp,
  ) async {
    _setLoading(true);
    
    try {
      final expense = ExpenseModel(
        duoId: duoId,
        id: '',
        userId: userId,
        amount: amount,
        category: category,
        description: description,
        timestamp: timestamp,
        receiptUrl: receiptUrl,
        paymentMethod: paymentMethod,
      );
      
      final expenseId = await _expenseService.addExpense(duoId, expense);
      
      if (expenseId.isNotEmpty) {
        final newExpense = expense.copyWith(id: expenseId);
        _expenses.insert(0, newExpense);
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
  
  // Update an existing expense
  Future<bool> updateExpense(
    String duoId,
    ExpenseModel expense,
  ) async {
    _setLoading(true);
    
    try {
      final success = await _expenseService.updateExpense(duoId, expense);
      
      if (success) {
        final index = _expenses.indexWhere((e) => e.id == expense.id);
        
        if (index != -1) {
          _expenses[index] = expense;
          notifyListeners();
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
  
  // Delete an expense
  Future<bool> deleteExpense(String duoId, String expenseId) async {
    _setLoading(true);
    
    try {
      final success = await _expenseService.deleteExpense(duoId, expenseId);
      
      if (success) {
        _expenses.removeWhere((e) => e.id == expenseId);
        
        if (_selectedExpense?.id == expenseId) {
          _selectedExpense = null;
        }
        
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
  
  // Set selected expense
  void setSelectedExpense(ExpenseModel expense) {
    _selectedExpense = expense;
    notifyListeners();
  }
  
  // Clear selected expense
  void clearSelectedExpense() {
    _selectedExpense = null;
    notifyListeners();
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