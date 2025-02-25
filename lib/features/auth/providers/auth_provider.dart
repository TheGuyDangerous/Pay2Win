import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../main.dart'; // Import for useMockData and GlobalProviderResets

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  
  // Initialize the provider
  Future<void> initialize() async {
    _setLoading(true);
    
    try {
      // Check if user is already logged in
      final currentUser = _authService.currentUser;
      
      if (currentUser != null) {
        // Get user data from Firestore
        _user = await _authService.getUserData(currentUser.uid);
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  
  // Sign in with email and password
  Future<bool> signIn(String email, String password, [BuildContext? context]) async {
    _setLoading(true);
    _clearError();
    
    try {
      final userCredential = await _authService.signInWithEmailAndPassword(
        email,
        password,
      );
      
      // Get user data from Firestore
      try {
        _user = await _authService.getUserData(userCredential.user!.uid);
      } catch (firestoreError) {
        debugPrint('Error retrieving user data from Firestore: $firestoreError');
        
        // Create a minimal user object with auth data if Firestore fails
        _user = UserModel(
          id: userCredential.user!.uid,
          email: email,
          displayName: userCredential.user!.displayName ?? email.split('@')[0],
          profilePicture: userCredential.user!.photoURL,
          monthlySalary: 0.0,
          savingGoals: [],
          createdAt: DateTime.now(),
          lastActive: DateTime.now(),
        );
        
        // Non-fatal error, continue with login
        _setError('Signed in, but data retrieval is currently unavailable. Some features may be limited.');
      }
      
      // Save user ID to shared preferences
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.prefKeyUser, _user!.id);
      } catch (prefsError) {
        debugPrint('Error saving to shared preferences: $prefsError');
        // Non-fatal error, continue
      }
      
      // If context is provided and widget is still mounted, reset any existing data from previous users
      if (context != null && context.mounted) {
        // Reset all providers to clear previous user data
        GlobalProviderResets.resetAllProviders(context);
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Register with email and password
  Future<bool> register(
    String email,
    String password,
    String displayName,
    double monthlySalary,
    List<String> savingGoals,
  ) async {
    _setLoading(true);
    _clearError();
    
    try {
      debugPrint('AuthProvider.register called with savingGoals: $savingGoals');
      UserCredential? userCredential;
      
      try {
        userCredential = await _authService.registerWithEmailAndPassword(
          email,
          password,
          displayName,
          monthlySalary,
          savingGoals,
        );
        debugPrint('User registered successfully with uid: ${userCredential.user?.uid}');
      } catch (authError) {
        debugPrint('Error in Firebase Auth registration: $authError');
        // Rethrow authentication errors
        rethrow;
      }
      
      if (userCredential.user != null) {
        try {
          // Try to get user data from Firestore
          _user = await _authService.getUserData(userCredential.user!.uid);
          debugPrint('User data retrieved: ${_user?.displayName}');
        } catch (firestoreError) {
          // If Firestore fails, create a minimal user object with auth data
          debugPrint('Error retrieving user data from Firestore: $firestoreError');
          _user = UserModel(
            id: userCredential.user!.uid,
            email: email,
            displayName: displayName,
            profilePicture: null,
            monthlySalary: monthlySalary,
            savingGoals: savingGoals,
            createdAt: DateTime.now(),
            lastActive: DateTime.now(),
          );
          debugPrint('Created minimal user object from auth data');
          
          // Log but don't fail if Firestore is unavailable
          _setError('Account created, but data storage is currently unavailable. Some features may be limited.');
        }
        
        // Save user ID to shared preferences
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(AppConstants.prefKeyUser, _user!.id);
          debugPrint('User ID saved to shared preferences');
        } catch (prefsError) {
          debugPrint('Error saving to shared preferences: $prefsError');
          // Non-fatal error, continue
        }
        
        notifyListeners();
        debugPrint('Returning true from register method despite possible Firestore errors');
        return true;
      } else {
        throw Exception('User registration failed: No user credential returned');
      }
    } catch (e) {
      debugPrint('Critical error in register method: $e');
      _setError(e.toString());
      return false;
    } finally {
      debugPrint('Setting loading to false');
      _setLoading(false);
    }
  }
  
  // Sign out
  Future<bool> signOut(BuildContext context) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _authService.signOut();
      
      // Clear local user data
      _user = null;
      
      // Reset all providers to clear their data if widget is still mounted
      if (context.mounted) {
        GlobalProviderResets.resetAllProviders(context);
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Reset password
  Future<void> resetPassword(String email) async {
    _setLoading(true);
    _setError(null);
    
    try {
      if (useMockData) {
        // Simulate network delay for mock data
        await Future.delayed(const Duration(seconds: 1));
        debugPrint('Mock password reset for email: $email');
      } else {
        // Use Firebase Auth
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      }
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  // Update user profile
  Future<bool> updateProfile(
    String displayName,
    double monthlySalary,
    List<String> savingGoals,
  ) async {
    _setLoading(true);
    _clearError();
    
    try {
      if (_user == null) {
        throw Exception('User not authenticated');
      }
      
      final updatedUser = _user!.copyWith(
        displayName: displayName,
        monthlySalary: monthlySalary,
        savingGoals: savingGoals,
      );
      
      await _authService.updateUserData(updatedUser);
      
      _user = updatedUser;
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Update profile picture
  Future<bool> updateProfilePicture(String profilePictureUrl) async {
    _setLoading(true);
    _clearError();
    
    try {
      if (_user == null) {
        throw Exception('User not authenticated');
      }
      
      // If empty string is passed, treat it as removing the profile picture
      final String? finalUrl = profilePictureUrl.trim().isEmpty ? null : profilePictureUrl;
      
      // Call the auth service to update the profile picture
      await _authService.updateProfilePicture(_user!.id, finalUrl);
      
      // Update local user object
      _user = _user!.copyWith(profilePicture: finalUrl);
      
      // Force update UI
      notifyListeners();
      
      // Add a small delay and notify again to ensure UI updates
      await Future.delayed(const Duration(milliseconds: 100));
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Check if email is already in use
  Future<bool> isEmailInUse(String email) async {
    try {
      return await _authService.isEmailInUse(email);
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }
  
  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
    notifyListeners();
  }
  
  // Public method to set user directly (useful for recovery when Firestore is down)
  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
    debugPrint('User set manually: ${user.displayName}');
  }
} 