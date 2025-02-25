import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isSubmitting = false;
  bool _isSubmitted = false;
  
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
  
  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.resetPassword(_emailController.text.trim());
      
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _isSubmitted = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send reset email: $e'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.white : AppColors.black;
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _isSubmitted ? _buildSuccessView() : _buildResetForm(),
        ),
      ),
    );
  }
  
  Widget _buildResetForm() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.white : AppColors.black;
    final subtitleColor = isDarkMode ? AppColors.lightGrey : AppColors.darkGrey;
    
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icon
          Icon(
            Icons.lock_reset_outlined,
            size: 72,
            color: textColor,
          ),
          const SizedBox(height: 24),
          
          // Title
          Text(
            'Forgot your password?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          // Description
          Text(
            'Enter the email address associated with your account, and we\'ll send you a link to reset your password.',
            style: TextStyle(
              fontSize: 14,
              color: subtitleColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Email input
          CustomTextField(
            controller: _emailController,
            labelText: 'Email',
            hintText: 'Enter your email address',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined),
            validator: Validators.validateEmail,
          ),
          const SizedBox(height: 32),
          
          // Reset button
          CustomButton(
            text: 'Send Reset Link',
            isLoading: _isSubmitting,
            onPressed: _resetPassword,
          ),
          const SizedBox(height: 16),
          
          // Back to login
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Back to Login',
              style: TextStyle(
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSuccessView() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.white : AppColors.black;
    final subtitleColor = isDarkMode ? AppColors.lightGrey : AppColors.darkGrey;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.mark_email_read_outlined,
          size: 72,
          color: textColor,
        ),
        const SizedBox(height: 24),
        
        Text(
          'Check your inbox',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textColor,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        
        Text(
          'We have sent a password reset link to:\n${_emailController.text}',
          style: TextStyle(
            fontSize: 16,
            color: subtitleColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        
        Text(
          'Didn\'t receive the email? Check your spam folder or try again.',
          style: TextStyle(
            fontSize: 14,
            color: subtitleColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        
        CustomButton(
          text: 'Back to Login',
          onPressed: () {
            Navigator.of(context).pushReplacementNamed(
              AppConstants.routeLogin,
            );
          },
        ),
        const SizedBox(height: 16),
        
        TextButton(
          onPressed: () {
            setState(() {
              _isSubmitted = false;
            });
          },
          child: Text(
            'Try a different email',
            style: TextStyle(
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }
} 