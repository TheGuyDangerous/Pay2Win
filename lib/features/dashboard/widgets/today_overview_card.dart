import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';

class TodayOverviewCard extends StatelessWidget {
  final String user1Name;
  final String user2Name;
  final double user1SpentToday;
  final double user2SpentToday;
  final double user1DailyBudget;
  final double user2DailyBudget;

  const TodayOverviewCard({
    super.key,
    required this.user1Name,
    required this.user2Name,
    required this.user1SpentToday,
    required this.user2SpentToday,
    required this.user1DailyBudget,
    required this.user2DailyBudget,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate percentages
    final user1Percentage = (user1SpentToday / user1DailyBudget).clamp(0.0, 1.0);
    final user2Percentage = (user2SpentToday / user2DailyBudget).clamp(0.0, 1.0);
    
    // Calculate savings
    final user1Savings = user1DailyBudget - user1SpentToday;
    final user2Savings = user2DailyBudget - user2SpentToday;
    final savingsDifference = (user1Savings - user2Savings).abs();
    final isUser1Winning = user1Savings > user2Savings;
    
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDarkMode ? AppColors.white : AppColors.black;
    final textColor = isDarkMode ? AppColors.white : AppColors.black;
    final progressColor = isDarkMode ? AppColors.white : AppColors.black;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Stack(
          children: [
            // Dot matrix pattern background
            Positioned.fill(
              child: CustomPaint(
                painter: DotMatrixPainter(
                  dotColor: borderColor.withOpacity(0.1),
                  spacing: 10,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Users comparison row
                  Row(
                    children: [
                      // User 1
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user1Name.toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 14,
                                letterSpacing: 1.2,
                                color: textColor,
                                fontFamily: 'SpaceMono',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${user1SpentToday.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 28,
                                letterSpacing: 1.5,
                                color: textColor,
                                fontFamily: 'SpaceMono',
                              ),
                            ),
                            Text(
                              'spent today',
                              style: TextStyle(
                                fontSize: 12,
                                letterSpacing: 0.8,
                                color: textColor.withOpacity(0.6),
                                fontFamily: 'SpaceMono',
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Divider
                      Container(
                        height: 60,
                        width: 1,
                        color: borderColor.withOpacity(0.2),
                      ),
                      
                      // User 2
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              user2Name.toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 14,
                                letterSpacing: 1.2,
                                color: textColor,
                                fontFamily: 'SpaceMono',
                              ),
                              textAlign: TextAlign.right,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${user2SpentToday.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 28,
                                letterSpacing: 1.5,
                                color: textColor,
                                fontFamily: 'SpaceMono',
                              ),
                              textAlign: TextAlign.right,
                            ),
                            Text(
                              'spent today',
                              style: TextStyle(
                                fontSize: 12,
                                letterSpacing: 0.8,
                                color: textColor.withOpacity(0.6),
                                fontFamily: 'SpaceMono',
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Progress bars
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User 1 progress
                      Row(
                        children: [
                          SizedBox(
                            width: 60,
                            child: Text(
                              user1Name.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                                letterSpacing: 0.8,
                                color: textColor,
                                fontFamily: 'SpaceMono',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Stack(
                              children: [
                                // Background track with dot matrix pattern
                                Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: borderColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: CustomPaint(
                                    painter: DotMatrixPainter(
                                      dotColor: borderColor.withOpacity(0.2),
                                      spacing: 4,
                                    ),
                                    size: Size.fromHeight(8),
                                  ),
                                ),
                                // Foreground progress
                                Container(
                                  height: 8,
                                  width: MediaQuery.of(context).size.width * 0.6 * user1Percentage,
                                  decoration: BoxDecoration(
                                    color: progressColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${(user1Percentage * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              letterSpacing: 0.5,
                              color: textColor,
                              fontFamily: 'SpaceMono',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // User 2 progress
                      Row(
                        children: [
                          SizedBox(
                            width: 60,
                            child: Text(
                              user2Name.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                                letterSpacing: 0.8,
                                color: textColor,
                                fontFamily: 'SpaceMono',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Stack(
                              children: [
                                // Background track with dot matrix pattern
                                Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: borderColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: CustomPaint(
                                    painter: DotMatrixPainter(
                                      dotColor: borderColor.withOpacity(0.2),
                                      spacing: 4,
                                    ),
                                    size: Size.fromHeight(8),
                                  ),
                                ),
                                // Foreground progress
                                Container(
                                  height: 8,
                                  width: MediaQuery.of(context).size.width * 0.6 * user2Percentage,
                                  decoration: BoxDecoration(
                                    color: progressColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${(user2Percentage * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              letterSpacing: 0.5,
                              color: textColor,
                              fontFamily: 'SpaceMono',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Daily saving badge
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderColor.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.savings_outlined,
                          size: 16,
                          color: textColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isUser1Winning
                              ? '${user1Name.toUpperCase()} IS SAVING ₹${savingsDifference.toStringAsFixed(0)} MORE TODAY!'
                              : '${user2Name.toUpperCase()} IS SAVING ₹${savingsDifference.toStringAsFixed(0)} MORE TODAY!',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            letterSpacing: 1.0,
                            color: isUser1Winning && user1Name.toLowerCase() == 'you' || 
                                  !isUser1Winning && user2Name.toLowerCase() == 'you' 
                                  ? AppColors.red : textColor,
                            fontFamily: 'SpaceMono',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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