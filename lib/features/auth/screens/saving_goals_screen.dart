import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavingGoalsScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const SavingGoalsScreen({
    Key? key,
    required this.userData,
  }) : super(key: key);

  @override
  State<SavingGoalsScreen> createState() => _SavingGoalsScreenState();
}

class _SavingGoalsScreenState extends State<SavingGoalsScreen> {
  final TextEditingController _customGoalController = TextEditingController();
  final List<String> _selectedGoals = [];
  
  final List<String> _predefinedGoals = [
    'Save for vacation',
    'Buy a new gadget',
    'Emergency fund',
    'Pay off debt',
    'Save for a car',
    'Save for a home',
    'Retirement',
    'Education',
  ];

  @override
  void dispose() {
    _customGoalController.dispose();
    super.dispose();
  }

  void _toggleGoal(String goal) {
    setState(() {
      if (_selectedGoals.contains(goal)) {
        _selectedGoals.remove(goal);
      } else {
        _selectedGoals.add(goal);
      }
    });
    
    // Debug print to verify goal selection is working
    print('Selected goals: $_selectedGoals');
  }

  void _addCustomGoal() {
    if (_customGoalController.text.trim().isNotEmpty) {
      setState(() {
        _selectedGoals.add(_customGoalController.text.trim());
        _customGoalController.clear();
      });
      
      // Debug print to verify custom goal is added
      print('Added custom goal. Selected goals: $_selectedGoals');
    }
  }

  void _completeRegistration() async {
    if (_selectedGoals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one saving goal'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Show loading indicator immediately
    setState(() {});
    
    try {
      print('Starting registration with goals: $_selectedGoals');
      
      // Add selected goals to user data
      final userData = {
        ...widget.userData,
        'savingGoals': _selectedGoals,
      };
      
      print('Calling authProvider.register with data: $userData');
      
      // Register the user
      final success = await authProvider.register(
        userData['email'],
        userData['password'],
        userData['displayName'],
        double.parse(userData['monthlySalary']),
        _selectedGoals, // Pass _selectedGoals directly to ensure it's not lost
      );
      
      print('Registration result: $success');
      
      if (!mounted) return;
      
      // FORCE NAVIGATION: Even if there are Firestore errors, if Firebase Auth created the account, proceed
      if (success || authProvider.user != null) {
        print('Registration successful or user object exists, navigating to home screen');
        
        // Save any necessary data to shared preferences before navigation
        try {
          final prefs = await SharedPreferences.getInstance();
          if (authProvider.user != null) {
            await prefs.setString(AppConstants.prefKeyUser, authProvider.user!.id);
          }
        } catch (e) {
          print('Error saving to shared preferences: $e');
        }
        
        // Navigate to home screen - using pushReplacementNamed as a fallback if pushNamedAndRemoveUntil fails
        try {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppConstants.routeHome, 
            (route) => false
          );
        } catch (navError) {
          print('Navigation error: $navError, trying alternative method');
          Navigator.of(context).pushReplacementNamed(AppConstants.routeHome);
        }
      } else {
        print('Registration failed with error: ${authProvider.error}');
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Registration failed. Please check your Firebase configuration.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      print('Exception during registration: $e');
      
      // Even if there's an exception, check if the user was created
      if (authProvider.user != null) {
        print('User exists despite exception, navigating to home screen');
        Navigator.of(context).pushReplacementNamed(AppConstants.routeHome);
        return;
      }
      
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 4,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 4,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 4,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Text(
                'Saving Goals',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Select your saving goals',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.darkGrey,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 24),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select at least one goal:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Goals grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _predefinedGoals.length,
                  itemBuilder: (context, index) {
                    final goal = _predefinedGoals[index];
                    final isSelected = _selectedGoals.contains(goal);
                    
                    return InkWell(
                      onTap: () => _toggleGoal(goal),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.black
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.black,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.black,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                goal,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Show selected goals as chips
            if (_selectedGoals.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Goals:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedGoals.map((goal) => Chip(
                        label: Text(goal),
                        deleteIcon: Icon(Icons.close, size: 16),
                        onDeleted: () {
                          setState(() {
                            _selectedGoals.remove(goal);
                          });
                        },
                      )).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            
            // Custom goal input
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: Colors.black),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    const Icon(Icons.add_circle_outline),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _customGoalController,
                        decoration: const InputDecoration(
                          hintText: 'Enter a custom saving goal',
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _addCustomGoal(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _addCustomGoal,
                    ),
                  ],
                ),
              ),
            ),
            
            // Next button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: authProvider.isLoading
                  ? const Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            'Creating your account...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'This may take a moment',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : CustomButton(
                      text: 'Finish',
                      onPressed: _completeRegistration,
                    ),
            ),
          ],
        ),
      ),
    );
  }
} 