import 'package:flutter/material.dart';
import '../theme/colors.dart';

class DotMatrixBackground extends StatelessWidget {
  final Color? dotColor;
  final double spacing;
  
  const DotMatrixBackground({
    super.key,
    this.dotColor,
    this.spacing = 20,
  });

  @override
  Widget build(BuildContext context) {
    final color = dotColor ?? AppColors.white.withOpacity(0.03);
    
    return Positioned.fill(
      child: CustomPaint(
        painter: DotMatrixPainter(
          dotColor: color,
          spacing: spacing,
        ),
      ),
    );
  }
}

class DotMatrixPainter extends CustomPainter {
  final Color dotColor;
  final double spacing;
  
  DotMatrixPainter({
    required this.dotColor,
    required this.spacing,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dotColor
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;
    
    final double dotSize = 1.0;
    
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotSize, paint);
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant DotMatrixPainter oldDelegate) {
    return oldDelegate.dotColor != dotColor || oldDelegate.spacing != spacing;
  }
} 