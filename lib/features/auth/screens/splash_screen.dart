import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/colors.dart';
import '../providers/auth_provider.dart';
import '../../../main.dart'; // Import to access Firebase initialization status
import '../../../models/user_model.dart'; // Correct path to UserModel
import '../../../features/duo/providers/duo_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _showFirebaseError = false;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: AppConstants.animationDurationLong,
    );
    
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _animationController.forward();
    
    _checkAuthStatus();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    // Check if Firebase is initialized
    if (!isFirebaseInitialized) {
      setState(() {
        _showFirebaseError = true;
      });
      // Still continue with app flow after a delay
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
    }
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    try {
      await authProvider.initialize();
    } catch (e) {
      debugPrint('Error initializing auth provider: $e');
      
      // If we have a current Firebase user but Firestore failed, create a minimal user
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        debugPrint('Firebase user exists despite Firestore error, creating minimal user');
        
        // Create a minimal user from Firebase Auth data
        final minimalUser = UserModel(
          id: currentUser.uid,
          email: currentUser.email ?? 'unknown@email.com',
          displayName: currentUser.displayName ?? 'User',
          profilePicture: currentUser.photoURL,
          monthlySalary: 0,  // Default
          savingGoals: [],   // Empty list
          createdAt: DateTime.now(),
          lastActive: DateTime.now(),
        );
        
        // Set the user in the provider
        authProvider.setUser(minimalUser);
      }
    }
    
    final prefs = await SharedPreferences.getInstance();
    final onboardingComplete = prefs.getBool(AppConstants.prefKeyOnboardingComplete) ?? false;
    
    if (!mounted) return;
    
    // Even if auth initialization failed but we have a saved user ID, try to navigate to home
    final savedUserId = prefs.getString(AppConstants.prefKeyUser);
    if (authProvider.isAuthenticated || (savedUserId != null && savedUserId.isNotEmpty)) {
      debugPrint('User is authenticated or has saved ID');
      
      // Check if the user has an active duo
      final duoProvider = Provider.of<DuoProvider>(context, listen: false);
      
      try {
        // Initialize duo provider to load any existing duo
        await duoProvider.initialize();
        
        if (duoProvider.hasDuo) {
          // User has a duo, go to home screen
          debugPrint('User has an active duo, going to home screen');
          if (!mounted) return;
          Navigator.of(context).pushReplacementNamed(AppConstants.routeHome);
        } else {
          // User doesn't have a duo, go to duo selector
          debugPrint('User needs to create or join a duo');
          if (!mounted) return;
          Navigator.of(context).pushReplacementNamed(AppConstants.routeDuoSelector);
        }
      } catch (e) {
        debugPrint('Error checking duo status: $e');
        // In case of error, default to duo selector
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed(AppConstants.routeDuoSelector);
      }
    } else if (!onboardingComplete) {
      debugPrint('Onboarding not complete, going to onboarding screen');
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppConstants.routeOnboarding);
    } else {
      debugPrint('No authenticated user, going to login screen');
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppConstants.routeLogin);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.white, width: 1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'P2W',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // App name
              const Text(
                AppConstants.appName,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              // Tagline
              const Text(
                AppConstants.appTagline,
                style: TextStyle(
                  color: AppColors.lightGrey,
                  fontSize: 16,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 48),
              // Loading indicator or error message
              if (_showFirebaseError)
                Column(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                      size: 36,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Firebase Configuration Issue',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'The app may not function properly. Please check Firebase configuration.\n'
                            'Error: ${firebaseErrorMessage ?? "Unknown error"}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Continuing in demo mode...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: AppColors.white,
                    strokeWidth: 2,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 