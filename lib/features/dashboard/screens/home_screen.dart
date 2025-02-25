import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/dot_matrix_background.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/duo/providers/duo_provider.dart';
import '../../expense/providers/expense_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/expense_comparison_chart.dart';
import '../widgets/savings_progress_bar.dart';
import '../widgets/today_overview_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'Daily';
  bool _isSubmitting = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Fetch data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
      dashboardProvider.fetchDashboardData();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.white : AppColors.black;
    final borderColor = isDarkMode ? AppColors.white : AppColors.black;
    
    return Scaffold(
      body: SafeArea(
        child: dashboardProvider.isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading data...',
                      style: TextStyle(
                        fontFamily: 'SpaceMono',
                        fontSize: 14,
                        letterSpacing: 1.0,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              )
            : Stack(
                children: [
                  // Dot matrix pattern background for entire screen
                  Positioned.fill(
                    child: CustomPaint(
                      painter: DotMatrixPainter(
                        dotColor: borderColor.withOpacity(0.03),
                        spacing: 20,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header section with profile pictures and date
                      _buildHeader(context),
                      
                      // Today's Overview Section
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'TODAY\'S OVERVIEW',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 16,
                            letterSpacing: 1.5,
                            fontFamily: 'SpaceMono',
                            color: textColor,
                          ),
                        ),
                      ),
                      
                      // Today's spending comparison cards
                      TodayOverviewCard(
                        user1Name: dashboardProvider.user1Name,
                        user2Name: dashboardProvider.user2Name,
                        user1SpentToday: dashboardProvider.user1TodaySpent,
                        user2SpentToday: dashboardProvider.user2TodaySpent,
                        user1DailyBudget: dashboardProvider.user1DailyBudget,
                        user2DailyBudget: dashboardProvider.user2DailyBudget,
                      ),
                      
                      // Period selector and Visualization area
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'VISUALIZATION',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 16,
                                letterSpacing: 1.5,
                                fontFamily: 'SpaceMono',
                                color: textColor,
                              ),
                            ),
                            // Time period dropdown
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: borderColor.withOpacity(0.5)),
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.transparent,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedPeriod,
                                  dropdownColor: isDarkMode ? AppColors.black : AppColors.white,
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: textColor,
                                  ),
                                  items: AppConstants.timePeriods.map((period) {
                                    return DropdownMenuItem<String>(
                                      value: period,
                                      child: Text(
                                        period,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'SpaceMono',
                                          letterSpacing: 0.8,
                                          color: textColor,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedPeriod = value;
                                      });
                                      // Update visualization data based on selected period
                                      dashboardProvider.updatePeriod(value);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Custom tab bar for different visualizations
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: borderColor.withOpacity(0.1)),
                            bottom: BorderSide(color: borderColor.withOpacity(0.1)),
                          ),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          tabs: [
                            _buildTab('SPENDING'),
                            _buildTab('SAVINGS'),
                            _buildTab('CATEGORIES'),
                          ],
                          indicatorColor: textColor,
                          indicatorWeight: 1,
                          labelColor: textColor,
                          unselectedLabelColor: textColor.withOpacity(0.5),
                          labelStyle: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'SpaceMono',
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.normal,
                          ),
                          unselectedLabelStyle: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'SpaceMono',
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                      
                      // Tab views with charts
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // Spending patterns chart
                            SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: ExpenseComparisonChart(
                                  user1Data: dashboardProvider.user1SpendingData,
                                  user2Data: dashboardProvider.user2SpendingData,
                                  period: _selectedPeriod,
                                  user1Name: dashboardProvider.user1Name,
                                  user2Name: dashboardProvider.user2Name,
                                ),
                              ),
                            ),
                            
                            // Savings progress chart
                            SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: SavingsProgressBar(
                                  user1Savings: dashboardProvider.user1Savings,
                                  user2Savings: dashboardProvider.user2Savings,
                                  user1Name: dashboardProvider.user1Name,
                                  user2Name: dashboardProvider.user2Name,
                                  period: _selectedPeriod,
                                ),
                              ),
                            ),
                            
                            // Category distribution chart
                            SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Container(
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
                                      Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(24.0),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.pie_chart_outline,
                                                size: 48,
                                                color: textColor,
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                'Category Distribution',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 16,
                                                  letterSpacing: 1.0,
                                                  fontFamily: 'SpaceMono',
                                                  color: textColor,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Coming soon',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  letterSpacing: 0.8,
                                                  fontFamily: 'SpaceMono',
                                                  color: textColor.withOpacity(0.6),
                                                ),
                                              ),
                                            ],
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
                      ),
                      
                      // Quick action buttons
                      _buildQuickActions(context),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
  
  Widget _buildTab(String text) {
    return Tab(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(text),
      ),
    );
  }
  
  Widget _buildHeader(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final duoProvider = Provider.of<DuoProvider>(context);
    final currentUser = authProvider.user;
    final currentDuo = duoProvider.currentDuo;
    
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.white : AppColors.black;
    
    // Get time-based greeting
    final hour = DateTime.now().hour;
    String greeting = 'Hello';
    
    if (hour >= 5 && hour < 12) {
      greeting = 'Good morning';
    } else if (hour >= 12 && hour < 17) {
      greeting = 'Good afternoon';
    } else if (hour >= 17 && hour < 21) {
      greeting = 'Good evening';
    } else {
      greeting = 'Good night';
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Date and greeting
          GestureDetector(
            onTap: () {
              _showLogoutMenu(context, authProvider);
            },
            child: SizedBox(
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE, MMMM d').format(DateTime.now()),
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor.withOpacity(0.7),
                          fontFamily: 'SpaceMono',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '$greeting',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                              fontFamily: 'SpaceMono',
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_drop_down,
                            color: textColor,
                            size: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Single profile icon
          GestureDetector(
            onTap: () {
              // Navigate to profile or duo management
              if (currentDuo != null) {
                Navigator.pushNamed(context, AppConstants.routeDuoManagement);
              } else {
                Navigator.pushNamed(context, AppConstants.routeDuoSelector);
              }
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: textColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: ClipOval(
                child: currentUser?.profilePicture != null && currentUser!.profilePicture!.isNotEmpty
                    ? Image.network(
                        currentUser.profilePicture!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Text(
                              currentUser.displayName?.substring(0, 1).toUpperCase() ?? '?',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Text(
                          currentUser?.displayName?.substring(0, 1).toUpperCase() ?? '?',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showLogoutMenu(BuildContext context, AuthProvider authProvider) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.white : AppColors.black;
    final backgroundColor = isDarkMode ? AppColors.black : AppColors.white;
    final borderColor = isDarkMode ? AppColors.white : AppColors.black;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: borderColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ACCOUNT',
                style: TextStyle(
                  fontFamily: 'SpaceMono',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.of(context).pushNamed(AppConstants.routeProfile);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: borderColor.withOpacity(0.2),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        color: textColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Profile',
                        style: TextStyle(
                          fontFamily: 'SpaceMono',
                          fontSize: 16,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  try {
                    Navigator.of(context).pop(); // Close the dialog
                    await authProvider.signOut(context);
                    if (context.mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        AppConstants.routeLogin,
                        (route) => false,
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error signing out: $e'),
                          backgroundColor: AppColors.red,
                        ),
                      );
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.red.withOpacity(0.5),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.logout,
                        color: AppColors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Log Out',
                        style: TextStyle(
                          fontFamily: 'SpaceMono',
                          fontSize: 16,
                          color: AppColors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: borderColor.withOpacity(0.2),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'CANCEL',
                    style: TextStyle(
                      fontFamily: 'SpaceMono',
                      fontSize: 14,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildQuickActions(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.white : AppColors.black;
    final borderColor = isDarkMode ? AppColors.white : AppColors.black;
    
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: borderColor.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(
              context: context,
              icon: Icons.add_circle_outline,
              label: 'ADD EXPENSE',
              onTap: () => Navigator.pushNamed(context, AppConstants.routeAddExpense),
              textColor: textColor,
            ),
            _buildActionButton(
              context: context,
              icon: Icons.history_outlined,
              label: 'HISTORY',
              onTap: () => Navigator.pushNamed(context, AppConstants.routeExpensesHistory),
              textColor: textColor,
            ),
            _buildActionButton(
              context: context,
              icon: Icons.emoji_events_outlined,
              label: 'CHALLENGE',
              onTap: () => Navigator.pushNamed(context, AppConstants.routeChallenges),
              textColor: textColor,
            ),
            _buildActionButton(
              context: context,
              icon: Icons.chat_bubble_outline,
              label: 'MESSAGES',
              onTap: () => Navigator.pushNamed(context, AppConstants.routeMessages),
              textColor: textColor,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color textColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 24,
            color: textColor,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 0.8,
              fontFamily: 'SpaceMono',
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  void _submitExpense() {
    // Implementation of _submitExpense method
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