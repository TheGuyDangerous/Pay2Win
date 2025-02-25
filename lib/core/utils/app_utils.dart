import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../constants/app_constants.dart';

class AppUtils {
  // Generate a unique ID
  static String generateUniqueId() {
    const uuid = Uuid();
    return uuid.v4();
  }
  
  // Format currency
  static String formatCurrency(double amount, {String symbol = '₹'}) {
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }
  
  // Format date
  static String formatDate(DateTime date, {String format = 'MMM dd, yyyy'}) {
    final formatter = DateFormat(format);
    return formatter.format(date);
  }
  
  // Format time
  static String formatTime(DateTime time, {String format = 'hh:mm a'}) {
    final formatter = DateFormat(format);
    return formatter.format(time);
  }
  
  // Calculate daily budget based on monthly salary
  static double calculateDailyBudget(double monthlySalary) {
    final daysInMonth = DateTime(
      DateTime.now().year,
      DateTime.now().month + 1,
      0,
    ).day;
    
    return monthlySalary / daysInMonth;
  }
  
  // Calculate savings percentage
  static double calculateSavingsPercentage(double spent, double budget) {
    if (budget <= 0) return 0;
    final savings = budget - spent;
    return (savings / budget) * 100;
  }
  
  // Generate a random duo code
  static String generateDuoCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(
      AppConstants.duoCodeLength,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }
  
  // Show a snackbar
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.black,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  // Show a loading dialog
  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
  
  // Dismiss the current dialog
  static void dismissDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
  
  // Check if the device is connected to the internet
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
  
  // Parse expense from message text
  static Map<String, dynamic>? parseExpenseFromMessage(String message) {
    // Simple regex pattern to extract amount and category
    final amountRegex = RegExp(r'(?:spent|paid|bought|cost|₹|Rs|INR)\s*(\d+(?:\.\d+)?)');
    final categoryRegex = RegExp(
      r'(?:on|for)\s+(food|transportation|entertainment|shopping|utilities|housing|health|education|personal)',
      caseSensitive: false,
    );
    
    final amountMatch = amountRegex.firstMatch(message);
    final categoryMatch = categoryRegex.firstMatch(message);
    
    if (amountMatch != null) {
      final amount = double.tryParse(amountMatch.group(1) ?? '0') ?? 0;
      final category = categoryMatch?.group(1)?.capitalize() ?? 'Other';
      
      return {
        'amount': amount,
        'category': category,
        'description': message,
        'timestamp': DateTime.now(),
      };
    }
    
    return null;
  }
}

// Extension to capitalize the first letter of a string
extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
} 