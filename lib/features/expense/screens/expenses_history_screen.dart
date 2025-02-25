import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/colors.dart';
import '../providers/expense_provider.dart';
import '../../../models/expense_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../features/duo/providers/duo_provider.dart';

class ExpensesHistoryScreen extends StatefulWidget {
  const ExpensesHistoryScreen({super.key});

  @override
  State<ExpensesHistoryScreen> createState() => _ExpensesHistoryScreenState();
}

class _ExpensesHistoryScreenState extends State<ExpensesHistoryScreen> {
  String _selectedFilter = 'All'; // Default filter
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    setState(() {
      _isLoading = true;
    });

    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    
    try {
      // In a real app, you'd get the actual duo ID from a provider or service
      await expenseProvider.getExpenses("current_duo_id");
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load expenses: $e'),
          backgroundColor: AppColors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildFilterButton(String filter) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.white : AppColors.black;
    final borderColor = isDarkMode ? AppColors.white : AppColors.black;
    final isSelected = _selectedFilter == filter;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = filter;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected 
                ? borderColor 
                : borderColor.withOpacity(0.3),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(4),
          color: isSelected 
              ? (isDarkMode ? AppColors.white.withOpacity(0.1) : AppColors.black.withOpacity(0.1))
              : Colors.transparent,
        ),
        child: Text(
          filter,
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 0.8,
            fontFamily: 'SpaceMono',
            color: isSelected 
                ? textColor 
                : textColor.withOpacity(0.7),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final duoProvider = Provider.of<DuoProvider>(context);
    final expenses = expenseProvider.expenses;
    
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.white : AppColors.black;
    final borderColor = isDarkMode ? AppColors.white : AppColors.black;

    // Check if user has an active duo
    if (!duoProvider.hasDuo) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('EXPENSES', style: TextStyle(fontSize: 18, letterSpacing: 1.5),),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            // Dot matrix pattern background
            Positioned.fill(
              child: CustomPaint(
                painter: DotMatrixPainter(
                  dotColor: borderColor.withOpacity(0.03),
                  spacing: 20,
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.group_off_outlined,
                      size: 64,
                      color: textColor.withOpacity(0.5),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No Active Duo',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        fontFamily: 'SpaceMono',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'You need to join or create a duo to track and view expenses.',
                      style: TextStyle(
                        fontSize: 16,
                        color: textColor.withOpacity(0.7),
                        fontFamily: 'SpaceMono',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    CustomButton(
                      text: 'JOIN OR CREATE DUO',
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                          context, 
                          AppConstants.routeDuoSelector,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Filter expenses based on selected filter
    final filteredExpenses = _selectedFilter == 'All'
        ? expenses
        : expenses.where((e) => e.category == _selectedFilter).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('EXPENSES', style: TextStyle(fontSize: 18, letterSpacing: 1.5),),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadExpenses,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Dot matrix pattern background
          Positioned.fill(
            child: CustomPaint(
              painter: DotMatrixPainter(
                dotColor: borderColor.withOpacity(0.03),
                spacing: 20,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category filter
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
                  child: Text(
                    'FILTER BY CATEGORY',
                    style: TextStyle(
                      fontSize: 14,
                      letterSpacing: 1.2,
                      fontFamily: 'SpaceMono',
                      color: textColor,
                    ),
                  ),
                ),
                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildFilterButton('All'),
                      const SizedBox(width: 8),
                      ...AppConstants.expenseCategories.map((category) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildFilterButton(category),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Expense list
                Expanded(
                  child: _isLoading
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Loading expenses...',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'SpaceMono',
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        )
                      : filteredExpenses.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.receipt_long_outlined,
                                    size: 48,
                                    color: textColor.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No expenses found',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'SpaceMono',
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Add your first expense to get started',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'SpaceMono',
                                      color: textColor.withOpacity(0.7),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  CustomButton(
                                    text: 'ADD EXPENSE',
                                    onPressed: () {
                                      Navigator.pushNamed(context, AppConstants.routeAddExpense);
                                    },
                                    borderRadius: 4,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: filteredExpenses.length,
                              itemBuilder: (context, index) {
                                final expense = filteredExpenses[index];
                                return _buildExpenseCard(expense, textColor, borderColor);
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: filteredExpenses.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, AppConstants.routeAddExpense);
              },
              backgroundColor: isDarkMode ? AppColors.white : AppColors.black,
              foregroundColor: isDarkMode ? AppColors.black : AppColors.white,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildExpenseCard(ExpenseModel expense, Color textColor, Color borderColor) {
    return InkWell(
      onTap: () {
        // Show expense details or push to details screen
        final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
        expenseProvider.setSelectedExpense(expense);
        Navigator.pushNamed(context, AppConstants.routeExpenseDetails);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category and amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: borderColor.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    expense.category.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 0.5,
                      fontFamily: 'SpaceMono',
                      color: textColor.withOpacity(0.7),
                    ),
                  ),
                ),
                Text(
                  '₹${expense.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'SpaceMono',
                    letterSpacing: 0.5,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Description
            Text(
              expense.description,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'SpaceMono',
                color: textColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            
            // Date and payment method
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 12,
                      color: textColor.withOpacity(0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd/MM/yyyy').format(expense.timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'SpaceMono',
                        color: textColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.payment_outlined,
                      size: 12,
                      color: textColor.withOpacity(0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      expense.paymentMethod,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'SpaceMono',
                        color: textColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for dot matrix pattern
class DotMatrixPainter extends CustomPainter {
  final Color dotColor;
  final double spacing;

  DotMatrixPainter({
    required this.dotColor,
    required this.spacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double dotSize = 1.0;
    
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        final paint = Paint()
          ..color = dotColor
          ..style = PaintingStyle.fill;
        
        canvas.drawCircle(Offset(x, y), dotSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
} 