import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/duo_model.dart';
import '../../../models/expense_model.dart';
import '../../../models/user_model.dart';
import '../../../services/duo_service.dart';
import '../../../services/expense_service.dart';
import '../../../services/auth_service.dart';
import '../../../main.dart'; // Import to access useMockData flag

class DashboardProvider extends ChangeNotifier {
  final DuoService _duoService = DuoService();
  final ExpenseService _expenseService = ExpenseService();
  final AuthService _authService = AuthService();
  
  DuoModel? _currentDuo;
  UserModel? _partner;
  List<ExpenseModel> _recentExpenses = [];
  Map<String, double> _todaySpending = {};
  Map<String, double> _weeklySpending = {};
  Map<String, double> _monthlySpending = {};
  bool _isLoading = false;
  String? _error;
  
  // Additional properties for HomeScreen
  String _user1Name = 'You';
  String _user2Name = 'Partner';
  String _user1Avatar = '';
  String _user2Avatar = '';
  double _user1TodaySpent = 0.0;
  double _user2TodaySpent = 0.0;
  double _user1DailyBudget = AppConstants.defaultDailyBudget;
  double _user2DailyBudget = AppConstants.defaultDailyBudget;
  double _user1Savings = 0.0;
  double _user2Savings = 0.0;
  List<Map<String, dynamic>> _user1SpendingData = [];
  List<Map<String, dynamic>> _user2SpendingData = [];
  String _selectedPeriod = 'Daily';
  
  // Getters
  DuoModel? get currentDuo => _currentDuo;
  UserModel? get partner => _partner;
  List<ExpenseModel> get recentExpenses => _recentExpenses;
  Map<String, double> get todaySpending => _todaySpending;
  Map<String, double> get weeklySpending => _weeklySpending;
  Map<String, double> get monthlySpending => _monthlySpending;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Additional getters for HomeScreen
  String get user1Name => _user1Name;
  String get user2Name => _user2Name;
  String get user1Avatar => _user1Avatar;
  String get user2Avatar => _user2Avatar;
  double get user1TodaySpent => _user1TodaySpent;
  double get user2TodaySpent => _user2TodaySpent;
  double get user1DailyBudget => _user1DailyBudget;
  double get user2DailyBudget => _user2DailyBudget;
  double get user1Savings => _user1Savings;
  double get user2Savings => _user2Savings;
  List<Map<String, dynamic>> get user1SpendingData => _user1SpendingData;
  List<Map<String, dynamic>> get user2SpendingData => _user2SpendingData;
  String get selectedPeriod => _selectedPeriod;
  
  // Initialize the provider
  Future<void> initialize() async {
    _setLoading(true);
    _clearError();
    
    try {
      if (useMockData) {
        await _loadMockData();
        return;
      }
      
      final userId = _authService.currentUserId;
      
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      // Get current duo
      _currentDuo = await _duoService.getCurrentDuo(userId);
      
      if (_currentDuo != null) {
        // Get partner data
        final partnerId = _currentDuo!.user1Id == userId
            ? _currentDuo!.user2Id
            : _currentDuo!.user1Id;
        
        _partner = await _authService.getUserData(partnerId);
        
        // Update user names and avatars
        final currentUser = await _authService.getCurrentUser();
        if (currentUser != null) {
          _user1Name = currentUser.displayName;
          _user1Avatar = currentUser.profilePicture ?? '';
          _user1DailyBudget = _calculateDailyBudget(currentUser.monthlySalary);
        }
        
        if (_partner != null) {
          _user2Name = _partner!.displayName;
          _user2Avatar = _partner!.profilePicture ?? '';
          _user2DailyBudget = _calculateDailyBudget(_partner!.monthlySalary);
        }
        
        // Get recent expenses for both users
        final expenses = await _expenseService.getRecentExpenses(_currentDuo!.id);
        
        _recentExpenses = expenses;
        
        // Calculate spending
        await _calculateSpending(userId, partnerId);
      } else {
        // If no duo found, try to get current user data
        final currentUser = await _authService.getCurrentUser();
        if (currentUser != null) {
          _user1Name = currentUser.displayName;
          _user1Avatar = currentUser.profilePicture ?? '';
          _user1DailyBudget = _calculateDailyBudget(currentUser.monthlySalary);
        }
      }
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error in DashboardProvider.initialize: $e');
      
      // If Firestore is not available, load mock data
      if (e.toString().contains('permission-denied') || 
          e.toString().contains('Cloud Firestore API has not been used')) {
        debugPrint('Firestore unavailable, loading mock data instead');
        await _loadMockData();
      }
    } finally {
      _setLoading(false);
    }
  }
  
  // Load mock data for development/demo mode
  Future<void> _loadMockData() async {
    debugPrint('Loading mock data for dashboard');
    
    try {
      // Set mock user data
      _user1Name = 'You';
      _user2Name = 'Partner';
      _user1Avatar = '';
      _user2Avatar = '';
      _user1DailyBudget = 200.0;
      _user2DailyBudget = 180.0;
      _user1TodaySpent = 85.0;
      _user2TodaySpent = 115.0;
      _user1Savings = _user1DailyBudget - _user1TodaySpent;
      _user2Savings = _user2DailyBudget - _user2TodaySpent;
      
      // Create mock spending data for the week
      _user1SpendingData = [
        {'label': 'Mon', 'amount': 95.0},
        {'label': 'Tue', 'amount': 82.0},
        {'label': 'Wed', 'amount': 78.0},
        {'label': 'Thu', 'amount': 85.0},
        {'label': 'Fri', 'amount': 105.0},
        {'label': 'Sat', 'amount': 150.0},
        {'label': 'Sun', 'amount': 120.0},
      ];
      
      _user2SpendingData = [
        {'label': 'Mon', 'amount': 110.0},
        {'label': 'Tue', 'amount': 95.0},
        {'label': 'Wed', 'amount': 105.0},
        {'label': 'Thu', 'amount': 115.0},
        {'label': 'Fri', 'amount': 98.0},
        {'label': 'Sat', 'amount': 160.0},
        {'label': 'Sun', 'amount': 130.0},
      ];
      
      // Create mock categories
      _todaySpending = {
        'Food': 35.0,
        'Transport': 20.0,
        'Entertainment': 15.0,
        'Shopping': 15.0,
        'user': _user1TodaySpent,
        'partner': _user2TodaySpent,
      };
      
      _weeklySpending = {
        'Food': 225.0,
        'Transport': 150.0,
        'Entertainment': 175.0,
        'Shopping': 165.0,
        'user': 715.0,
        'partner': 813.0,
      };
      
      _monthlySpending = {
        'Food': 900.0,
        'Transport': 600.0,
        'Entertainment': 750.0,
        'Shopping': 680.0,
        'user': 2930.0,
        'partner': 3254.0,
      };
      
      // Create mock expenses
      _recentExpenses = [
        ExpenseModel(
          id: 'mock1',
          userId: 'user1',
          duoId: 'duo1',
          amount: 35.0,
          category: 'Food',
          description: 'Lunch at cafe',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          paymentMethod: 'Card',
        ),
        ExpenseModel(
          id: 'mock2',
          userId: 'user1',
          duoId: 'duo1',
          amount: 20.0,
          category: 'Transport',
          description: 'Uber ride',
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          paymentMethod: 'Card',
        ),
        ExpenseModel(
          id: 'mock3',
          userId: 'user2',
          duoId: 'duo1',
          amount: 45.0,
          category: 'Food',
          description: 'Dinner',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          paymentMethod: 'Cash',
        ),
      ];
      
      debugPrint('Mock data loaded successfully');
    } catch (e) {
      debugPrint('Error loading mock data: $e');
    }
  }
  
  // Fetch dashboard data
  Future<void> fetchDashboardData() async {
    _setLoading(true);
    
    try {
      // Get current user
      final currentUser = await _authService.getCurrentUser();
      
      if (currentUser != null) {
        // Initialize dashboard
        await initialize();
        
        // Set user names
        _user1Name = 'You';
        _user2Name = _partner?.displayName ?? 'Partner';
        
        // Set user avatars
        _user1Avatar = currentUser.profilePicture ?? '';
        _user2Avatar = _partner?.profilePicture ?? '';
        
        // Set spending data
        _user1TodaySpent = _todaySpending['user'] ?? 0.0;
        _user2TodaySpent = _todaySpending['partner'] ?? 0.0;
        
        // Set budgets (calculate from monthly salary)
        final DateTime now = DateTime.now();
        final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
        
        // Use either real values or defaults
        final user1MonthlySalary = currentUser.monthlySalary;
        final user2MonthlySalary = _partner?.monthlySalary ?? AppConstants.defaultMonthlySalary;
        
        _user1DailyBudget = user1MonthlySalary / daysInMonth;
        _user2DailyBudget = user2MonthlySalary / daysInMonth;
        
        // Calculate savings
        _user1Savings = _user1DailyBudget - _user1TodaySpent;
        _user2Savings = _user2DailyBudget - _user2TodaySpent;
        
        // Generate spending data for charts
        _generateSpendingData();
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  
  // Update time period for visualization
  void updatePeriod(String period) {
    _selectedPeriod = period;
    _generateSpendingData();
    notifyListeners();
  }
  
  // Generate spending data for charts based on selected period
  void _generateSpendingData() {
    // This would typically fetch data from the database
    // For now we'll generate placeholder data
    
    _user1SpendingData = [];
    _user2SpendingData = [];
    
    if (_selectedPeriod == 'Daily') {
      // Generate hourly data for today
      for (int i = 0; i < 24; i += 2) { // Using fewer data points for clarity
        final hour = i.toString().padLeft(2, '0');
        
        _user1SpendingData.add({
          'label': '$hour:00',
          'amount': _getRandomAmount(20, 80),
        });
        
        _user2SpendingData.add({
          'label': '$hour:00',
          'amount': _getRandomAmount(30, 100),
        });
      }
    } else if (_selectedPeriod == 'Weekly') {
      // Generate daily data for the week
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      
      for (final day in days) {
        _user1SpendingData.add({
          'label': day,
          'amount': _getRandomAmount(50, 150),
        });
        
        _user2SpendingData.add({
          'label': day,
          'amount': _getRandomAmount(70, 200),
        });
      }
    } else if (_selectedPeriod == 'Monthly') {
      // Generate data for each week of the month (instead of each day for clarity)
      final weeks = ['Week 1', 'Week 2', 'Week 3', 'Week 4'];
      
      for (final week in weeks) {
        _user1SpendingData.add({
          'label': week,
          'amount': _getRandomAmount(300, 600),
        });
        
        _user2SpendingData.add({
          'label': week,
          'amount': _getRandomAmount(400, 700),
        });
      }
    } else if (_selectedPeriod == 'Trimester') {
      // Generate data for each month in a trimester (3 months)
      final now = DateTime.now();
      final months = [];
      
      // Get the current month and the two previous months
      for (int i = 2; i >= 0; i--) {
        final month = now.month - i;
        final adjustedMonth = month <= 0 ? month + 12 : month;
        
        final monthNames = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        
        months.add(monthNames[adjustedMonth - 1]);
      }
      
      for (final month in months) {
        _user1SpendingData.add({
          'label': month,
          'amount': _getRandomAmount(1500, 3000),
        });
        
        _user2SpendingData.add({
          'label': month,
          'amount': _getRandomAmount(2000, 3500),
        });
      }

      // Update savings for trimester view to be consistent with the chart
      _user1Savings = _getRandomAmount(1500, 3000);
      _user2Savings = _getRandomAmount(1000, 2500);
      
    } else if (_selectedPeriod == 'Yearly') {
      // Generate data for each quarter instead of each month for clarity
      final quarters = ['Q1', 'Q2', 'Q3', 'Q4'];
      
      for (final quarter in quarters) {
        _user1SpendingData.add({
          'label': quarter,
          'amount': _getRandomAmount(4000, 6000),
        });
        
        _user2SpendingData.add({
          'label': quarter,
          'amount': _getRandomAmount(5000, 7000),
        });
      }
    }

    // Update savings based on the selected period to make the comparison consistent
    if (_selectedPeriod != 'Trimester') { // For Trimester, we already set specific values above
      // Calculate savings as the difference between budget and spending
      final user1AvgSpending = _user1SpendingData.isEmpty 
        ? 0.0 
        : _user1SpendingData.map((d) => d['amount'] as double).reduce((a, b) => a + b) / _user1SpendingData.length;
      
      final user2AvgSpending = _user2SpendingData.isEmpty 
        ? 0.0 
        : _user2SpendingData.map((d) => d['amount'] as double).reduce((a, b) => a + b) / _user2SpendingData.length;
      
      // Set the savings values based on the selected period
      if (_selectedPeriod == 'Daily') {
        _user1Savings = _user1DailyBudget - user1AvgSpending;
        _user2Savings = _user2DailyBudget - user2AvgSpending;
      } else if (_selectedPeriod == 'Weekly') {
        _user1Savings = _user1DailyBudget * 7 - user1AvgSpending * 7;
        _user2Savings = _user2DailyBudget * 7 - user2AvgSpending * 7;
      } else if (_selectedPeriod == 'Monthly') {
        _user1Savings = _user1DailyBudget * 30 - user1AvgSpending * 4;
        _user2Savings = _user2DailyBudget * 30 - user2AvgSpending * 4;
      } else if (_selectedPeriod == 'Yearly') {
        _user1Savings = _user1DailyBudget * 365 - user1AvgSpending * 4;
        _user2Savings = _user2DailyBudget * 365 - user2AvgSpending * 4;
      }
    }
    
    notifyListeners();
  }
  
  // Helper to generate random amounts in a range
  double _getRandomAmount(double min, double max) {
    return min + (max - min) * (DateTime.now().microsecondsSinceEpoch % 1000) / 1000;
  }
  
  // Calculate daily budget
  double _calculateDailyBudget(double monthlySalary) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    return monthlySalary / daysInMonth;
  }
  
  // Calculate spending
  Future<void> _calculateSpending(String userId, String partnerId) async {
    try {
      // Today's spending
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      
      final todayExpenses = await _expenseService.getExpensesByDateRange(
        _currentDuo!.id,
        startOfDay,
        today,
      );
      
      _todaySpending = _calculateUserSpending(todayExpenses, userId);
      
      // Weekly spending
      final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
      final startOfWeekDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
      
      final weeklyExpenses = await _expenseService.getExpensesByDateRange(
        _currentDuo!.id,
        startOfWeekDate,
        today,
      );
      
      _weeklySpending = _calculateUserSpending(weeklyExpenses, userId);
      
      // Monthly spending
      final startOfMonth = DateTime(today.year, today.month, 1);
      
      final monthlyExpenses = await _expenseService.getExpensesByDateRange(
        _currentDuo!.id,
        startOfMonth,
        today,
      );
      
      _monthlySpending = _calculateUserSpending(monthlyExpenses, userId);
      
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }
  
  // Calculate user spending from expenses
  Map<String, double> _calculateUserSpending(List<ExpenseModel> expenses, String userId) {
    final result = <String, double>{};
    
    // User's total
    final userExpenses = expenses.where((e) => e.userId == userId);
    result['user'] = userExpenses.fold(0, (total, expense) => total + expense.amount);
    
    // Partner's total
    final partnerExpenses = expenses.where((e) => e.userId != userId);
    result['partner'] = partnerExpenses.fold(0, (total, expense) => total + expense.amount);
    
    return result;
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
  
  void _clearError() {
    _error = null;
    notifyListeners();
  }
} 