import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../providers/expense_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../duo/providers/duo_provider.dart';

class ExpenseDetailsScreen extends StatefulWidget {
  const ExpenseDetailsScreen({super.key});

  @override
  State<ExpenseDetailsScreen> createState() => _ExpenseDetailsScreenState();
}

class _ExpenseDetailsScreenState extends State<ExpenseDetailsScreen> {
  bool _isDeleting = false;

  Future<void> _deleteExpense() async {
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    final duoProvider = Provider.of<DuoProvider>(context, listen: false);
    final expense = expenseProvider.selectedExpense;

    if (expense == null || duoProvider.currentDuo == null) {
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    try {
      final success = await expenseProvider.deleteExpense(
        duoProvider.currentDuo!.id,
        expense.id,
      );

      if (!mounted) return;

      if (success) {
        Navigator.of(context).pop();
      } else if (expenseProvider.error != null) {
        _showErrorSnackBar(expenseProvider.error!);
      }
    } catch (e) {
      _showErrorSnackBar(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.red,
      ),
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final textColor = isDarkMode ? AppColors.white : AppColors.black;
        final backgroundColor = isDarkMode ? AppColors.black : AppColors.white;
        
        return AlertDialog(
          backgroundColor: backgroundColor,
          title: Text(
            'Delete Expense',
            style: TextStyle(
              color: textColor,
              fontFamily: 'SpaceMono',
              fontSize: 18,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this expense? This action cannot be undone.',
            style: TextStyle(
              color: textColor,
              fontFamily: 'SpaceMono',
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'CANCEL',
                style: TextStyle(
                  color: textColor,
                  fontFamily: 'SpaceMono',
                  fontSize: 14,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteExpense();
              },
              child: const Text(
                'DELETE',
                style: TextStyle(
                  color: AppColors.red,
                  fontFamily: 'SpaceMono',
                  fontSize: 14,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final expense = expenseProvider.selectedExpense;

    if (expense == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('EXPENSE DETAILS'),
          centerTitle: true,
        ),
        body: const Center(
          child: Text('No expense selected'),
        ),
      );
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.white : AppColors.black;
    final borderColor = isDarkMode ? AppColors.white : AppColors.black;
    final isCurrentUserExpense = expense.userId == authProvider.user?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('EXPENSE DETAILS'),
        centerTitle: true,
        actions: [
          if (isCurrentUserExpense)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _showDeleteConfirmationDialog,
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Amount
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: borderColor.withOpacity(0.3),
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '₹${expense.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'SpaceMono',
                            color: textColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: borderColor.withOpacity(0.3),
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            expense.category.toUpperCase(),
                            style: TextStyle(
                              fontSize: 14,
                              letterSpacing: 1,
                              fontFamily: 'SpaceMono',
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Date and Time
                  _buildDetailRow(
                    Icons.calendar_today_outlined,
                    'DATE',
                    DateFormat('EEEE, MMMM d, y').format(expense.timestamp),
                    textColor,
                    borderColor,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    Icons.access_time_outlined,
                    'TIME',
                    DateFormat('h:mm a').format(expense.timestamp),
                    textColor,
                    borderColor,
                  ),
                  const SizedBox(height: 16),

                  // Payment Method
                  _buildDetailRow(
                    Icons.payment_outlined,
                    'PAYMENT METHOD',
                    expense.paymentMethod,
                    textColor,
                    borderColor,
                  ),
                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'DESCRIPTION',
                    style: TextStyle(
                      fontSize: 14,
                      letterSpacing: 1.2,
                      fontFamily: 'SpaceMono',
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: borderColor.withOpacity(0.3),
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      expense.description,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'SpaceMono',
                        color: textColor,
                      ),
                    ),
                  ),
                  
                  // Receipt Image
                  if (expense.receiptUrl != null) ...[
                    const SizedBox(height: 24),
                    Text(
                      'RECEIPT',
                      style: TextStyle(
                        fontSize: 14,
                        letterSpacing: 1.2,
                        fontFamily: 'SpaceMono',
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 300,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: borderColor.withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          expense.receiptUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_not_supported_outlined,
                                    size: 48,
                                    color: textColor.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Failed to load receipt image',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'SpaceMono',
                                      color: textColor.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: textColor,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 32),
                  
                  // Edit button
                  if (isCurrentUserExpense)
                    CustomButton(
                      text: 'EDIT EXPENSE',
                      onPressed: () {
                        // Navigate to edit expense screen
                        // This will be implemented in a future update
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Edit feature coming soon'),
                          ),
                        );
                      },
                      isLoading: false,
                    ),
                  
                  if (isCurrentUserExpense)
                    const SizedBox(height: 16),
                  
                  // Delete button
                  if (isCurrentUserExpense)
                    CustomButton(
                      text: 'DELETE EXPENSE',
                      onPressed: _showDeleteConfirmationDialog,
                      isLoading: _isDeleting,
                      backgroundColor: Colors.transparent,
                      textColor: AppColors.red,
                      isOutlined: true,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
      IconData icon, String label, String value, Color textColor, Color borderColor) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: textColor,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 1,
                fontFamily: 'SpaceMono',
                color: textColor.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'SpaceMono',
                color: textColor,
              ),
            ),
          ],
        ),
      ],
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