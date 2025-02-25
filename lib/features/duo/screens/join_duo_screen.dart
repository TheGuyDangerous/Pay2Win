import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/dot_matrix_background.dart';
import '../providers/duo_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';

class JoinDuoScreen extends StatefulWidget {
  const JoinDuoScreen({super.key});

  @override
  State<JoinDuoScreen> createState() => _JoinDuoScreenState();
}

class _JoinDuoScreenState extends State<JoinDuoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isJoining = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  // Join a duo with the entered code
  Future<void> _joinDuo() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isJoining = true;
    });

    try {
      final code = _codeController.text.trim().toUpperCase();
      final duoProvider = Provider.of<DuoProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      if (authProvider.user == null) {
        throw Exception("User is not authenticated");
      }
      
      await duoProvider.joinDuo(
        authProvider.user!.id,
        authProvider.user!.displayName,
        code,
      );
      
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppConstants.routeHome);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error joining duo: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isJoining = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: AppColors.black,
      
      body: Stack(
        children: [
          // Background
          const DotMatrixBackground(),
          
          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.white.withOpacity(0.5), width: 1),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: const Icon(
                          Icons.people_outline,
                          color: AppColors.white,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Title
                      Text(
                        'JOIN AN EXISTING DUO',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Description
                      Text(
                        'Enter the code shared by your friend to join their savings challenge.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.lightGrey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      
                      // Code input field
                      TextFormField(
                        controller: _codeController,
                        decoration: InputDecoration(
                          hintText: 'Enter 6-digit code',
                          hintStyle: TextStyle(color: AppColors.lightGrey),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          border: InputBorder.none,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.lightGrey.withOpacity(0.5)),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.white, width: 2),
                          ),
                          counterStyle: const TextStyle(color: AppColors.lightGrey),
                        ),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: AppColors.white,
                          letterSpacing: 3.0,
                        ),
                        textCapitalization: TextCapitalization.characters,
                        textAlign: TextAlign.center,
                        maxLength: 6,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a code';
                          }
                          if (value.length != 6) {
                            return 'Code must be 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 40),
                      
                      // Join button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isJoining ? null : _joinDuo,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: AppColors.white,
                            side: const BorderSide(color: AppColors.white, width: 1),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: _isJoining
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: AppColors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.check_circle_outline, size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      'JOIN DUO',
                                      style: TextStyle(
                                        fontSize: 14,
                                        letterSpacing: 1.5,
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
          ),
        ],
      ),
    );
  }
} 