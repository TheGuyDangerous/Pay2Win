import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:csv/csv.dart';
import '../models/expense_model.dart';
import '../models/user_model.dart';

class ReportsService {
  // Generate daily comparison
  Future<Map<String, dynamic>> generateDailyComparison(
    List<ExpenseModel> expenses,
    String userId,
    String partnerId,
  ) async {
    // Group expenses by day
    final Map<String, Map<String, double>> dailyExpenses = {};
    
    for (final expense in expenses) {
      final day = _formatDate(expense.timestamp);
      
      if (!dailyExpenses.containsKey(day)) {
        dailyExpenses[day] = {
          'user': 0.0,
          'partner': 0.0,
        };
      }
      
      if (expense.userId == userId) {
        dailyExpenses[day]!['user'] = dailyExpenses[day]!['user']! + expense.amount;
      } else if (expense.userId == partnerId) {
        dailyExpenses[day]!['partner'] = dailyExpenses[day]!['partner']! + expense.amount;
      }
    }
    
    // Convert to list for chart data
    final List<Map<String, dynamic>> chartData = [];
    
    dailyExpenses.forEach((day, data) {
      chartData.add({
        'day': day,
        'user': data['user'],
        'partner': data['partner'],
      });
    });
    
    // Sort by date
    chartData.sort((a, b) => a['day'].compareTo(b['day']));
    
    return {
      'chartData': chartData,
      'totalDays': dailyExpenses.length,
    };
  }
  
  // Generate weekly comparison
  Future<Map<String, dynamic>> generateWeeklyComparison(
    List<ExpenseModel> expenses,
    String userId,
    String partnerId,
  ) async {
    // Group expenses by week
    final Map<String, Map<String, double>> weeklyExpenses = {};
    
    for (final expense in expenses) {
      final week = _getWeekNumber(expense.timestamp);
      final weekLabel = 'Week $week';
      
      if (!weeklyExpenses.containsKey(weekLabel)) {
        weeklyExpenses[weekLabel] = {
          'user': 0.0,
          'partner': 0.0,
        };
      }
      
      if (expense.userId == userId) {
        weeklyExpenses[weekLabel]!['user'] = weeklyExpenses[weekLabel]!['user']! + expense.amount;
      } else if (expense.userId == partnerId) {
        weeklyExpenses[weekLabel]!['partner'] = weeklyExpenses[weekLabel]!['partner']! + expense.amount;
      }
    }
    
    // Convert to list for chart data
    final List<Map<String, dynamic>> chartData = [];
    
    weeklyExpenses.forEach((week, data) {
      chartData.add({
        'week': week,
        'user': data['user'],
        'partner': data['partner'],
      });
    });
    
    // Sort by week number
    chartData.sort((a, b) => a['week'].compareTo(b['week']));
    
    return {
      'chartData': chartData,
      'totalWeeks': weeklyExpenses.length,
    };
  }
  
  // Generate monthly comparison
  Future<Map<String, dynamic>> generateMonthlyComparison(
    List<ExpenseModel> expenses,
    String userId,
    String partnerId,
  ) async {
    // Group expenses by month
    final Map<String, Map<String, double>> monthlyExpenses = {};
    
    for (final expense in expenses) {
      final month = _formatMonth(expense.timestamp);
      
      if (!monthlyExpenses.containsKey(month)) {
        monthlyExpenses[month] = {
          'user': 0.0,
          'partner': 0.0,
        };
      }
      
      if (expense.userId == userId) {
        monthlyExpenses[month]!['user'] = monthlyExpenses[month]!['user']! + expense.amount;
      } else if (expense.userId == partnerId) {
        monthlyExpenses[month]!['partner'] = monthlyExpenses[month]!['partner']! + expense.amount;
      }
    }
    
    // Convert to list for chart data
    final List<Map<String, dynamic>> chartData = [];
    
    monthlyExpenses.forEach((month, data) {
      chartData.add({
        'month': month,
        'user': data['user'],
        'partner': data['partner'],
      });
    });
    
    // Sort by month
    chartData.sort((a, b) => a['month'].compareTo(b['month']));
    
    return {
      'chartData': chartData,
      'totalMonths': monthlyExpenses.length,
    };
  }
  
  // Generate category comparison
  Future<Map<String, dynamic>> generateCategoryComparison(
    List<ExpenseModel> expenses,
    String userId,
    String partnerId,
  ) async {
    // Group expenses by category
    final Map<String, Map<String, double>> categoryExpenses = {};
    
    for (final expense in expenses) {
      final category = expense.category;
      
      if (!categoryExpenses.containsKey(category)) {
        categoryExpenses[category] = {
          'user': 0.0,
          'partner': 0.0,
        };
      }
      
      if (expense.userId == userId) {
        categoryExpenses[category]!['user'] = categoryExpenses[category]!['user']! + expense.amount;
      } else if (expense.userId == partnerId) {
        categoryExpenses[category]!['partner'] = categoryExpenses[category]!['partner']! + expense.amount;
      }
    }
    
    // Convert to list for chart data
    final List<Map<String, dynamic>> chartData = [];
    
    categoryExpenses.forEach((category, data) {
      chartData.add({
        'category': category,
        'user': data['user'],
        'partner': data['partner'],
      });
    });
    
    // Sort by category name
    chartData.sort((a, b) => a['category'].compareTo(b['category']));
    
    return {
      'chartData': chartData,
      'totalCategories': categoryExpenses.length,
    };
  }
  
  // Export reports as PDF
  Future<String> exportReportsPDF(
    String duoId,
    UserModel user,
    UserModel partner,
    Map<String, dynamic> dailyComparison,
    Map<String, dynamic> weeklyComparison,
    Map<String, dynamic> monthlyComparison,
    Map<String, dynamic> categoryComparison,
    Map<String, dynamic> savingsRate,
    String currentWinner,
  ) async {
    final pdf = pw.Document();
    
    // Add title page
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Center(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text(
                'Financial Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                '${user.displayName} vs ${partner.displayName}',
                style: const pw.TextStyle(fontSize: 18),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Generated on ${_formatDate(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
    
    // Add summary page
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Summary',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text('Current Winner: ${currentWinner == user.id ? user.displayName : partner.displayName}'),
            pw.SizedBox(height: 10),
            pw.Text('User Savings Rate: ${savingsRate['user']['savingsRate'].toStringAsFixed(2)}%'),
            pw.Text('Partner Savings Rate: ${savingsRate['partner']['savingsRate'].toStringAsFixed(2)}%'),
            pw.SizedBox(height: 20),
            pw.Text('User Total Expenses: \$${savingsRate['user']['expenses'].toStringAsFixed(2)}'),
            pw.Text('Partner Total Expenses: \$${savingsRate['partner']['expenses'].toStringAsFixed(2)}'),
            pw.SizedBox(height: 20),
            pw.Text('User Expected Spending: \$${savingsRate['user']['expectedSpending'].toStringAsFixed(2)}'),
            pw.Text('Partner Expected Spending: \$${savingsRate['partner']['expectedSpending'].toStringAsFixed(2)}'),
            pw.SizedBox(height: 20),
            pw.Text('User Savings: \$${savingsRate['user']['savings'].toStringAsFixed(2)}'),
            pw.Text('Partner Savings: \$${savingsRate['partner']['savings'].toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
    
    // Save the PDF
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/financial_report.pdf');
    await file.writeAsBytes(await pdf.save());
    
    return file.path;
  }
  
  // Export data as CSV
  Future<String> exportDataCSV(List<ExpenseModel> expenses) async {
    // Prepare CSV data
    final List<List<dynamic>> csvData = [
      ['ID', 'User ID', 'Amount', 'Category', 'Description', 'Date', 'Payment Method'],
    ];
    
    for (final expense in expenses) {
      csvData.add([
        expense.id,
        expense.userId,
        expense.amount,
        expense.category,
        expense.description,
        _formatDate(expense.timestamp),
        expense.paymentMethod,
      ]);
    }
    
    // Convert to CSV string
    final csvString = const ListToCsvConverter().convert(csvData);
    
    // Save the CSV
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/expenses.csv');
    await file.writeAsString(csvString);
    
    return file.path;
  }
  
  // Helper methods
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  String _formatMonth(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    return '${months[date.month - 1]} ${date.year}';
  }
  
  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final dayOfYear = date.difference(firstDayOfYear).inDays;
    
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }
} 