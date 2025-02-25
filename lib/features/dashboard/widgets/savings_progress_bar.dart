import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import 'dart:math' as Math;

class SavingsProgressBar extends StatelessWidget {
  final double user1Savings;
  final double user2Savings;
  final String user1Name;
  final String user2Name;
  final String period;

  const SavingsProgressBar({
    super.key,
    required this.user1Savings,
    required this.user2Savings,
    required this.user1Name,
    required this.user2Name,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    final winner = user1Savings > user2Savings ? user1Name : user2Name;
    final winnerSavings = user1Savings > user2Savings ? user1Savings : user2Savings;
    final loserSavings = user1Savings > user2Savings ? user2Savings : user1Savings;
    final savingsDifference = (user1Savings - user2Savings).abs();
    
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDarkMode ? AppColors.white : AppColors.black;
    final textColor = isDarkMode ? AppColors.white : AppColors.black;
    
    // Compact version of the savings progress bar for use in a scrollable tab view
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // Don't take more space than needed
      children: [
        // Chart title
        Text(
          'Savings Comparison ($period)',
          style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 16,
            letterSpacing: 1.2,
            fontFamily: 'SpaceMono',
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),
        
        // User 1 savings
        _buildSavingsBar(
          context,
          user1Name,
          user1Savings,
          textColor,
          borderColor,
          isDarkMode,
        ),
        const SizedBox(height: 12),
        
        // User 2 savings
        _buildSavingsBar(
          context,
          user2Name,
          user2Savings,
          textColor.withOpacity(0.7),
          borderColor,
          isDarkMode,
        ),
        const SizedBox(height: 16),
        
        // Winner announcement
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor.withOpacity(0.5)),
          ),
          child: Stack(
            children: [
              // Dot matrix pattern background
              Positioned.fill(
                child: CustomPaint(
                  painter: DotMatrixPainter(
                    dotColor: borderColor.withOpacity(0.1),
                    spacing: 8,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    winner.toLowerCase() == 'you' 
                        ? 'You are winning by ₹${savingsDifference.toStringAsFixed(0)}'
                        : '$winner is winning by ₹${savingsDifference.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                      letterSpacing: 1.0,
                      fontFamily: 'SpaceMono',
                      color: winner.toLowerCase() == 'you' ? AppColors.red : textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Keep saving to maintain your lead!',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 0.8,
                      fontFamily: 'SpaceMono',
                      color: textColor.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Savings trend visualization - compact version
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: borderColor.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SAVINGS TREND',
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  letterSpacing: 1.2,
                  fontFamily: 'SpaceMono',
                  color: textColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Who saved more?',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 0.8,
                  fontFamily: 'SpaceMono',
                  color: textColor.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 12),
              
              // Fixed-height chart that won't cause overflow
              SizedBox(
                height: 120,
                child: Stack(
                  children: [
                    // Dot matrix pattern background
                    Positioned.fill(
                      child: CustomPaint(
                        painter: DotMatrixPainter(
                          dotColor: borderColor.withOpacity(0.05),
                          spacing: 10,
                        ),
                      ),
                    ),
                    
                    if (user1Savings != 0 || user2Savings != 0)
                      MonochromeSavingsChart(
                        user1Savings: user1Savings,
                        user2Savings: user2Savings,
                        isDarkMode: isDarkMode,
                        user1Name: user1Name,
                        user2Name: user2Name,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildSavingsBar(
    BuildContext context,
    String name,
    double savings,
    Color color,
    Color borderColor,
    bool isDarkMode,
  ) {
    // Calculate progress - assume max is 1000 for now
    // Use absolute value to ensure progress is always positive
    final progress = (savings.abs() / 1000).clamp(0.0, 1.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Name and amount
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 13,
                letterSpacing: 1.0,
                fontFamily: 'SpaceMono',
                color: color,
              ),
            ),
            Text(
              '₹${savings.toStringAsFixed(0)}',
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
                letterSpacing: 1.0,
                fontFamily: 'SpaceMono',
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Progress bar with dot matrix pattern
        Container(
          height: 10,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.transparent,
            border: Border.all(color: borderColor.withOpacity(0.3)),
          ),
          child: Stack(
            children: [
              // Dot matrix pattern for background
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: CustomPaint(
                  painter: DotMatrixPainter(
                    dotColor: borderColor.withOpacity(0.1),
                    spacing: 4,
                  ),
                  size: const Size.fromHeight(10),
                ),
              ),
              // Progress indicator
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: color,
                  ),
                ),
              ),
              // Dot grid pattern overlay on progress bar (for visual texture)
              ClipRect(
                child: Align(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: CustomPaint(
                      painter: DotMatrixPainter(
                        dotColor: isDarkMode ? Colors.black.withOpacity(0.1) : Colors.white.withOpacity(0.3),
                        spacing: 4,
                      ),
                      size: const Size.fromHeight(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Simplified chart for savings visualization that won't cause overflow
class MonochromeSavingsChart extends StatelessWidget {
  final double user1Savings;
  final double user2Savings;
  final bool isDarkMode;
  final String user1Name;
  final String user2Name;
  
  const MonochromeSavingsChart({
    super.key, 
    required this.user1Savings, 
    required this.user2Savings,
    required this.isDarkMode,
    required this.user1Name,
    required this.user2Name,
  });
  
  @override
  Widget build(BuildContext context) {
    final barColor = isDarkMode ? AppColors.white : AppColors.black;
    final textColor = isDarkMode ? AppColors.white : AppColors.black;
    
    // Create comparison data - ensure we use absolute values to prevent negative heights
    final double maxSavings = Math.max(user1Savings.abs(), user2Savings.abs());
    final double user1Percentage = maxSavings > 0 ? user1Savings.abs() / maxSavings : 0;
    final double user2Percentage = maxSavings > 0 ? user2Savings.abs() / maxSavings : 0;
    
    // Ensure we have a minimum height for visual purposes
    final double user1BarHeight = Math.max(10.0, 50.0 * user1Percentage);
    final double user2BarHeight = Math.max(10.0, 50.0 * user2Percentage);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // User 1 bar and label
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '₹${user1Savings.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 14,
                  letterSpacing: 0.5,
                  fontFamily: 'SpaceMono',
                  color: textColor,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                height: user1BarHeight, // Using calculated safe height
                width: 32, // Smaller width for bars
                decoration: BoxDecoration(
                  color: barColor,
                  border: Border.all(color: barColor),
                ),
                child: CustomPaint(
                  painter: DotMatrixPainter(
                    dotColor: isDarkMode 
                      ? Colors.black.withOpacity(0.2) 
                      : Colors.white.withOpacity(0.3),
                    spacing: 6,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                user1Name,
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 0.8,
                  fontFamily: 'SpaceMono',
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
        
        // vs divider
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20), // Offset to align with bars
              Container(
                height: 30,
                width: 1,
                color: barColor.withOpacity(0.3),
              ),
              const SizedBox(height: 6),
              Text(
                'VS',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 1.0,
                  fontFamily: 'SpaceMono',
                  color: textColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        
        // User 2 bar and label
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '₹${user2Savings.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 14,
                  letterSpacing: 0.5,
                  fontFamily: 'SpaceMono',
                  color: textColor.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                height: user2BarHeight, // Using calculated safe height
                width: 32, // Smaller width for bars
                decoration: BoxDecoration(
                  color: barColor.withOpacity(0.6),
                  border: Border.all(color: barColor.withOpacity(0.6)),
                ),
                child: CustomPaint(
                  painter: DotMatrixPainter(
                    dotColor: isDarkMode 
                      ? Colors.black.withOpacity(0.2) 
                      : Colors.white.withOpacity(0.3),
                    spacing: 6,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                user2Name,
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 0.8,
                  fontFamily: 'SpaceMono',
                  color: textColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
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