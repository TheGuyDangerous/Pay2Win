import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';

class ExpenseComparisonChart extends StatelessWidget {
  final List<Map<String, dynamic>> user1Data;
  final List<Map<String, dynamic>> user2Data;
  final String period;
  final String user1Name;
  final String user2Name;

  const ExpenseComparisonChart({
    super.key,
    required this.user1Data,
    required this.user2Data,
    required this.period,
    required this.user1Name,
    required this.user2Name,
  });

  @override
  Widget build(BuildContext context) {
    // For simplicity, we're showing a placeholder for the chart
    // In a real app, you would use a charting library like fl_chart
    
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDarkMode ? AppColors.white : AppColors.black;
    final textColor = isDarkMode ? AppColors.white : AppColors.black;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chart title
        Text(
          'Spending Comparison ($period)',
          style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 16,
            letterSpacing: 1.2,
            fontFamily: 'SpaceMono',
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),
        
        // Chart legend
        Row(
          children: [
            _buildLegendItem(context, user1Name, textColor),
            const SizedBox(width: 24),
            _buildLegendItem(context, user2Name, textColor.withOpacity(0.5)),
          ],
        ),
        const SizedBox(height: 24),
        
        // Chart container with fixed height to prevent overflow
        Container(
          height: 250, // Fixed height to prevent overflow
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: borderColor.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(8),
            color: Colors.transparent,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EXPENSE COMPARISON',
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        letterSpacing: 1.2,
                        fontFamily: 'SpaceMono',
                        color: textColor,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Who spent more?',
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 0.8,
                        fontFamily: 'SpaceMono',
                        color: textColor.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    if (user1Data.isNotEmpty && user2Data.isNotEmpty)
                      Expanded(
                        child: BeginnerfriendlyBarChart(
                          user1Data: user1Data,
                          user2Data: user2Data,
                          isDarkMode: isDarkMode,
                          user1Name: user1Name,
                          user2Name: user2Name,
                        ),
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
  
  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            border: Border.all(color: color),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 0.8,
            fontFamily: 'SpaceMono',
            color: color,
          ),
        ),
      ],
    );
  }
}

// A beginner-friendly bar chart implementation with clear labels
class BeginnerfriendlyBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> user1Data;
  final List<Map<String, dynamic>> user2Data;
  final bool isDarkMode;
  final String user1Name;
  final String user2Name;
  
  const BeginnerfriendlyBarChart({
    super.key,
    required this.user1Data,
    required this.user2Data,
    required this.isDarkMode,
    required this.user1Name,
    required this.user2Name,
  });
  
  @override
  Widget build(BuildContext context) {
    // Use a smaller subset of data for clarity - just show 4 data points max
    final displayData = user1Data.length > 4 
      ? user1Data.sublist(user1Data.length - 4) 
      : user1Data;
    
    final displayData2 = user2Data.length > 4 
      ? user2Data.sublist(user2Data.length - 4) 
      : user2Data;
    
    // Find the maximum value for scaling
    double maxValue = 0;
    for (var item in displayData) {
      if ((item['amount'] as double) > maxValue) {
        maxValue = item['amount'] as double;
      }
    }
    for (var item in displayData2) {
      if ((item['amount'] as double) > maxValue) {
        maxValue = item['amount'] as double;
      }
    }
    
    // If no data or max is 0, set a default
    if (maxValue == 0) maxValue = 100;
    
    final barColor = isDarkMode ? AppColors.white : AppColors.black;
    final textColor = isDarkMode ? AppColors.white : AppColors.black;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Safe check for constraints
        if (constraints.maxHeight <= 0) {
          return const SizedBox(); // Return empty widget if no height
        }
        
        return Row(
          children: [
            // Left side labels (Y-axis)
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '₹${maxValue.toInt()}',
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: 'SpaceMono',
                    color: textColor.withOpacity(0.7),
                  ),
                ),
                Text(
                  '₹0',
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: 'SpaceMono',
                    color: textColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            
            const SizedBox(width: 8),
            
            // Bar chart area
            Expanded(
              child: Column(
                children: [
                  // Bars area
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(
                        displayData.length,
                        (index) {
                          final user1Value = displayData[index]['amount'] as double;
                          final user2Value = index < displayData2.length 
                            ? displayData2[index]['amount'] as double 
                            : 0.0;
                          
                          final label = displayData[index]['label'] ?? '';
                          
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: _buildBarPair(
                                user1Value, 
                                user2Value, 
                                maxValue, 
                                constraints.maxHeight - 20, // Leave space for labels
                                barColor,
                                textColor,
                                label,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  
                  // Helper text
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      "Left: $user1Name, Right: $user2Name",
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: 'SpaceMono',
                        color: textColor.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildBarPair(
    double user1Value, 
    double user2Value, 
    double maxValue, 
    double availableHeight,
    Color barColor,
    Color textColor,
    String label,
  ) {
    // Calculate heights as percentage of max value
    final user1Height = (user1Value / maxValue) * availableHeight;
    final user2Height = (user2Value / maxValue) * availableHeight;
    
    return Column(
      children: [
        // Values at the top
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              '${user1Value.toInt()}',
              style: TextStyle(
                fontSize: 9,
                fontFamily: 'SpaceMono',
                color: textColor,
              ),
            ),
            Text(
              '${user2Value.toInt()}',
              style: TextStyle(
                fontSize: 9,
                fontFamily: 'SpaceMono',
                color: textColor.withOpacity(0.7),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 2),
        
        // Bars
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // User 1 bar
              Container(
                width: 12,
                height: user1Height.isFinite && user1Height > 0 ? user1Height : 0,
                decoration: BoxDecoration(
                  color: barColor,
                  border: Border.all(color: barColor),
                ),
                child: CustomPaint(
                  painter: DotMatrixPainter(
                    dotColor: isDarkMode 
                      ? Colors.black.withOpacity(0.2) 
                      : Colors.white.withOpacity(0.3),
                    spacing: 4,
                  ),
                ),
              ),
              // User 2 bar
              Container(
                width: 12,
                height: user2Height.isFinite && user2Height > 0 ? user2Height : 0,
                decoration: BoxDecoration(
                  color: barColor.withOpacity(0.5),
                  border: Border.all(color: barColor.withOpacity(0.5)),
                ),
                child: CustomPaint(
                  painter: DotMatrixPainter(
                    dotColor: isDarkMode 
                      ? Colors.black.withOpacity(0.2) 
                      : Colors.white.withOpacity(0.3),
                    spacing: 4,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Label at the bottom
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontFamily: 'SpaceMono',
            color: textColor.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
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