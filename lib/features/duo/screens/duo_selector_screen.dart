import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/constants/app_constants.dart';
import '../providers/duo_provider.dart';
import '../../../core/widgets/dot_matrix_background.dart';

class DuoSelectorScreen extends StatelessWidget {
  const DuoSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          // Background pattern
          const DotMatrixBackground(),
          
          // Main content
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title
                    Text(
                      'FIND YOUR PARTNER',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Subtitle
                    Text(
                      'Save together, compete together',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.lightGrey,
                        letterSpacing: 1.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 64),
                    
                    // Create a new duo option
                    _buildOption(
                      context,
                      title: 'CREATE A NEW DUO',
                      description: 'Start a new saving competition and invite a friend to join',
                      icon: Icons.add_circle_outline,
                      onTap: () {
                        Navigator.pushNamed(context, AppConstants.routeCreateDuo);
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Join existing duo option
                    _buildOption(
                      context,
                      title: 'JOIN AN EXISTING DUO',
                      description: 'Enter an invite code to join a friend\'s saving challenge',
                      icon: Icons.people_outline,
                      onTap: () {
                        Navigator.pushNamed(context, AppConstants.routeJoinDuo);
                      },
                    ),
                    
                    const Spacer(),
                    
                    // Skip for now option
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, AppConstants.routeHome);
                      },
                      child: Text(
                        'SKIP FOR NOW',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: AppColors.lightGrey,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildOption(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: AppColors.white, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.white,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.lightGrey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.white,
              size: 16,
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