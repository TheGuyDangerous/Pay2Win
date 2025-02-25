import 'package:flutter/material.dart';
import '../../../models/expense_model.dart';
import '../../../models/user_model.dart';
import '../../../services/expense_service.dart';
import '../../../services/reports_service.dart';

class ReportsProvider extends ChangeNotifier {
  final ExpenseService _expenseService = ExpenseService();
  final ReportsService _reportsService = ReportsService();
  
  Map<String, dynamic> _dailyComparison = {};
  Map<String, dynamic> _weeklyComparison = {};
  Map<String, dynamic> _monthlyComparison = {};
  Map<String, dynamic> _categoryComparison = {};
  Map<String, dynamic> _savingsRate = {};
  String _currentWinner = '';
  int _userWinStreak = 0;
  int _partnerWinStreak = 0;
  bool _isLoading = false;
  String? _error;
  
  Map<String, dynamic> get dailyComparison => _dailyComparison;
  Map<String, dynamic> get weeklyComparison => _weeklyComparison;
  Map<String, dynamic> get monthlyComparison => _monthlyComparison;
  Map<String, dynamic> get categoryComparison => _categoryComparison;
  Map<String, dynamic> get savingsRate => _savingsRate;
  String get currentWinner => _currentWinner;
  int get userWinStreak => _userWinStreak;
  int get partnerWinStreak => _partnerWinStreak;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Generate reports for a duo
  Future<void> generateReports(
    String duoId,
    UserModel user,
    UserModel partner,
  ) async {
    _setLoading(true);
    
    try {
      // Get all expenses for the current month
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      
      final expenses = await _expenseService.getExpensesByDateRange(
        duoId,
        startOfMonth,
        now,
      );
      
      // Generate daily comparison
      _dailyComparison = await _reportsService.generateDailyComparison(
        expenses,
        user.id,
        partner.id,
      );
      
      // Generate weekly comparison
      _weeklyComparison = await _reportsService.generateWeeklyComparison(
        expenses,
        user.id,
        partner.id,
      );
      
      // Generate monthly comparison
      _monthlyComparison = await _reportsService.generateMonthlyComparison(
        expenses,
        user.id,
        partner.id,
      );
      
      // Generate category comparison
      _categoryComparison = await _reportsService.generateCategoryComparison(
        expenses,
        user.id,
        partner.id,
      );
      
      // Calculate savings rate
      _savingsRate = _calculateSavingsRate(
        expenses,
        user,
        partner,
      );
      
      // Determine current winner
      _determineWinner(
        expenses,
        user,
        partner,
      );
      
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  
  // Export reports as PDF
  Future<String?> exportReportsPDF(
    String duoId,
    UserModel user,
    UserModel partner,
  ) async {
    _setLoading(true);
    
    try {
      final pdfPath = await _reportsService.exportReportsPDF(
        duoId,
        user,
        partner,
        _dailyComparison,
        _weeklyComparison,
        _monthlyComparison,
        _categoryComparison,
        _savingsRate,
        _currentWinner,
      );
      
      return pdfPath;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  // Export data as CSV
  Future<String?> exportDataCSV(
    String duoId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    _setLoading(true);
    
    try {
      final expenses = await _expenseService.getExpensesByDateRange(
        duoId,
        startDate,
        endDate,
      );
      
      final csvPath = await _reportsService.exportDataCSV(expenses);
      
      return csvPath;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  // Calculate savings rate
  Map<String, dynamic> _calculateSavingsRate(
    List<ExpenseModel> expenses,
    UserModel user,
    UserModel partner,
  ) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysPassed = now.day;
    
    // Calculate total expenses for each user
    final userExpenses = expenses
        .where((e) => e.userId == user.id)
        .fold(0.0, (sum, e) => sum + e.amount);
    
    final partnerExpenses = expenses
        .where((e) => e.userId == partner.id)
        .fold(0.0, (sum, e) => sum + e.amount);
    
    // Calculate daily budget for each user
    final userDailyBudget = user.monthlySalary / daysInMonth;
    final partnerDailyBudget = partner.monthlySalary / daysInMonth;
    
    // Calculate expected spending so far
    final userExpectedSpending = userDailyBudget * daysPassed;
    final partnerExpectedSpending = partnerDailyBudget * daysPassed;
    
    // Calculate savings
    final userSavings = userExpectedSpending - userExpenses;
    final partnerSavings = partnerExpectedSpending - partnerExpenses;
    
    // Calculate savings rate
    final userSavingsRate = (userSavings / userExpectedSpending) * 100;
    final partnerSavingsRate = (partnerSavings / partnerExpectedSpending) * 100;
    
    return {
      'user': {
        'expenses': userExpenses,
        'expectedSpending': userExpectedSpending,
        'savings': userSavings,
        'savingsRate': userSavingsRate,
      },
      'partner': {
        'expenses': partnerExpenses,
        'expectedSpending': partnerExpectedSpending,
        'savings': partnerSavings,
        'savingsRate': partnerSavingsRate,
      },
    };
  }
  
  // Determine the current winner
  void _determineWinner(
    List<ExpenseModel> expenses,
    UserModel user,
    UserModel partner,
  ) {
    final userSavingsRate = _savingsRate['user']['savingsRate'] as double;
    final partnerSavingsRate = _savingsRate['partner']['savingsRate'] as double;
    
    if (userSavingsRate > partnerSavingsRate) {
      _currentWinner = user.id;
      _userWinStreak++;
      _partnerWinStreak = 0;
    } else if (partnerSavingsRate > userSavingsRate) {
      _currentWinner = partner.id;
      _partnerWinStreak++;
      _userWinStreak = 0;
    } else {
      _currentWinner = 'tie';
      // Streaks remain unchanged in case of a tie
    }
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