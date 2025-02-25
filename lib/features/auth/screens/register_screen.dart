import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';
import '../screens/saving_goals_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _salaryController = TextEditingController();
  final _customGoalController = TextEditingController();
  final List<String> _savingGoals = [];
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  int _currentStep = 0;
  
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _salaryController.dispose();
    _customGoalController.dispose();
    super.dispose();
  }
  
  void _toggleGoal(String goal) {
    setState(() {
      if (_savingGoals.contains(goal)) {
        _savingGoals.remove(goal);
      } else {
        _savingGoals.add(goal);
      }
    });
  }
  
  void _nextStep() {
    if (_currentStep < 2) {
      if (_validateCurrentStep()) {
        setState(() {
          _currentStep++;
        });
      }
    } else {
      _goToSavingGoalsScreen();
    }
  }
  
  bool _validateCurrentStep() {
    if (_currentStep == 0) {
      // Validate account fields
      return _formKey.currentState?.validate() ?? false;
    } else if (_currentStep == 1) {
      // Validate salary field
      return _formKey.currentState?.validate() ?? false;
    }
    return true;
  }
  
  void _goToSavingGoalsScreen() {
    if (_validateCurrentStep()) {
      // Prepare user data for next screen
      final userData = {
        'email': _emailController.text,
        'password': _passwordController.text,
        'displayName': _nameController.text,
        'monthlySalary': _salaryController.text,
      };
      
      // Navigate to SavingGoalsScreen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SavingGoalsScreen(userData: userData),
        ),
      );
    }
  }
  
  void _previousStep() {
    setState(() {
      if (_currentStep > 0) {
        _currentStep--;
      }
    });
  }
  
  Future<void> _register() async {
    if (!_validateCurrentStep()) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.register(
      _emailController.text.trim(),
      _passwordController.text,
      _nameController.text.trim(),
      double.parse(_salaryController.text),
      _savingGoals,
    );
    
    if (!mounted) return;
    
    if (success) {
      Navigator.of(context).pushReplacementNamed(AppConstants.routeHome);
    } else if (authProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error!),
          backgroundColor: AppColors.red,
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
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousStep,
              )
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pushReplacementNamed(AppConstants.routeLogin),
              ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Stepper indicator
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
                    return Container(
                      width: 80,
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: index <= _currentStep
                            ? (isDarkMode ? AppColors.white : AppColors.black)
                            : (isDarkMode ? AppColors.white.withOpacity(0.3) : AppColors.lightGrey),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                ),
              ),
              
              // Step title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  _currentStep == 0
                      ? 'Account Details'
                      : _currentStep == 1
                          ? 'Monthly Salary'
                          : 'Saving Goals',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.white
                        : AppColors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              
              // Step subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  _currentStep == 0
                      ? 'Create your account to get started'
                      : _currentStep == 1
                          ? 'Enter your monthly salary to track your savings'
                          : 'Select your saving goals',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.lightGrey
                        : AppColors.darkGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              
              // Step content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildCurrentStep(),
                ),
              ),
              
              // Bottom buttons
              Padding(
                padding: const EdgeInsets.all(24),
                child: _currentStep < 2
                    ? CustomButton(
                        text: 'Next',
                        onPressed: _nextStep,
                      )
                    : CustomButton(
                        text: 'Create Account',
                        isLoading: authProvider.isLoading,
                        onPressed: _register,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildAccountDetailsStep();
      case 1:
        return _buildSalaryStep();
      case 2:
        return _buildGoalsStep();
      default:
        return const SizedBox.shrink();
    }
  }
  
  Widget _buildAccountDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Name field
        CustomTextField(
          controller: _nameController,
          labelText: 'Full Name',
          hintText: 'Enter your full name',
          keyboardType: TextInputType.name,
          prefixIcon: const Icon(Icons.person_outline),
          validator: Validators.validateName,
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 16),
        
        // Email field
        CustomTextField(
          controller: _emailController,
          labelText: 'Email',
          hintText: 'Enter your email',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(Icons.email_outlined),
          validator: Validators.validateEmail,
        ),
        const SizedBox(height: 16),
        
        // Password field
        CustomTextField(
          controller: _passwordController,
          labelText: 'Password',
          hintText: 'Enter your password',
          obscureText: !_isPasswordVisible,
          prefixIcon: const Icon(Icons.lock_outlined),
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
          validator: Validators.validatePassword,
        ),
        const SizedBox(height: 16),
        
        // Confirm password field
        CustomTextField(
          controller: _confirmPasswordController,
          labelText: 'Confirm Password',
          hintText: 'Confirm your password',
          obscureText: !_isConfirmPasswordVisible,
          prefixIcon: const Icon(Icons.lock_outlined),
          suffixIcon: IconButton(
            icon: Icon(
              _isConfirmPasswordVisible
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
            onPressed: () {
              setState(() {
                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
              });
            },
          ),
          validator: (value) => Validators.validateConfirmPassword(
            value,
            _passwordController.text,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
  
  Widget _buildSalaryStep() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.white : AppColors.black;
    final subtitleColor = isDarkMode ? AppColors.lightGrey : AppColors.darkGrey;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Salary field
        CustomTextField(
          controller: _salaryController,
          labelText: 'Monthly Salary',
          hintText: 'Enter your monthly salary',
          keyboardType: TextInputType.number,
          prefixIcon: const Icon(Icons.attach_money),
          validator: Validators.validateSalary,
        ),
        const SizedBox(height: 24),
        
        // Salary info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode 
                ? AppColors.darkGrey.withOpacity(0.3) 
                : AppColors.lightGrey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Why do we need this?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your monthly salary helps us calculate your daily budget and track your savings progress. This information is kept private and is only used for comparison with your duo partner.',
                style: TextStyle(
                  fontSize: 14,
                  color: subtitleColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Daily Budget Calculation:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Monthly Salary ÷ Days in Month = Daily Budget',
                style: TextStyle(
                  fontSize: 14,
                  color: subtitleColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildGoalsStep() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.white : AppColors.black;
    
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Select at least one goal:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),
        
        // Goals grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _predefinedGoals.length,
          itemBuilder: (context, index) {
            final goal = _predefinedGoals[index];
            final isSelected = _savingGoals.contains(goal);
            
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
                      ? (isDarkMode ? AppColors.white : AppColors.black)
                      : AppColors.lightGrey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? (isDarkMode ? AppColors.white : AppColors.black)
                        : AppColors.lightGrey,
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
                          ? (isDarkMode ? AppColors.black : AppColors.white)
                          : (isDarkMode ? AppColors.lightGrey : AppColors.darkGrey),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        goal,
                        style: TextStyle(
                          color: isSelected
                              ? (isDarkMode ? AppColors.black : AppColors.white)
                              : textColor,
                          fontSize: 12,
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
        const SizedBox(height: 24),
        
        // Custom goal input
        CustomTextField(
          controller: _customGoalController,
          labelText: 'Add Custom Goal',
          hintText: 'Enter a custom saving goal',
          prefixIcon: const Icon(Icons.add_circle_outline),
          suffixIcon: IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              if (_customGoalController.text.isNotEmpty) {
                setState(() {
                  _savingGoals.add(_customGoalController.text);
                  _customGoalController.clear();
                });
              }
            },
          ),
        ),
      ],
    );
  }
} 