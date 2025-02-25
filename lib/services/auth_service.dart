import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';
import '../main.dart'; // Import for useMockData

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get current user
  User? get currentUser => _auth.currentUser;
  
  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;
  
  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Get current user data from Firestore
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      
      if (user != null) {
        return await getUserData(user.uid);
      }
      
      return null;
    } catch (e) {
      throw Exception('Failed to get current user: ${e.toString()}');
    }
  }
  
  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Check if user document exists in Firestore
      try {
        final docSnapshot = await _firestore
            .collection(AppConstants.collectionUsers)
            .doc(userCredential.user!.uid)
            .get();
        
        if (!docSnapshot.exists) {
          // Create a basic user document if it doesn't exist
          debugPrint('User document not found in Firestore. Creating a new one.');
          final newUser = UserModel(
            id: userCredential.user!.uid,
            email: userCredential.user!.email ?? email,
            displayName: userCredential.user!.displayName ?? email.split('@')[0],
            profilePicture: userCredential.user!.photoURL,
            monthlySalary: AppConstants.defaultMonthlySalary,
            savingGoals: AppConstants.defaultSavingGoals,
            createdAt: DateTime.now(),
            lastActive: DateTime.now(),
          );
          
          await _firestore
              .collection(AppConstants.collectionUsers)
              .doc(newUser.id)
              .set(newUser.toJson());
          
          debugPrint('Created new user document in Firestore');
        } else {
          // Update last active timestamp
          await _firestore
              .collection(AppConstants.collectionUsers)
              .doc(userCredential.user!.uid)
              .update({
            'lastActive': FieldValue.serverTimestamp(),
          });
        }
      } catch (firestoreError) {
        debugPrint('Error checking/creating Firestore document: $firestoreError');
        // Don't fail the sign-in process if Firestore operations fail
      }
      
      return userCredential;
    } catch (e) {
      throw Exception('Failed to sign in: ${e.toString()}');
    }
  }
  
  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword(
    String email,
    String password,
    String displayName,
    double monthlySalary,
    List<String> savingGoals,
  ) async {
    debugPrint('AuthService.registerWithEmailAndPassword called with savingGoals: $savingGoals');
    
    UserCredential userCredential;
    
    // First step: Create Firebase Auth account - this is critical and must succeed
    try {
      userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      debugPrint('Firebase Auth account created for uid: ${userCredential.user?.uid}');
    } catch (authError) {
      debugPrint('Critical error in Firebase auth registration: $authError');
      throw Exception('Failed to register authentication: ${authError.toString()}');
    }
    
    // Second step: Try to create Firestore document - this can fail and we'll still proceed
    if (userCredential.user != null) {
      try {
        // Create user document in Firestore
        final user = UserModel(
          id: userCredential.user!.uid,
          email: email,
          displayName: displayName,
          profilePicture: null,
          monthlySalary: monthlySalary,
          savingGoals: savingGoals,
          createdAt: DateTime.now(),
          lastActive: DateTime.now(),
        );
        
        debugPrint('Attempting to save user data to Firestore: ${user.toJson()}');
        
        await _firestore
            .collection(AppConstants.collectionUsers)
            .doc(user.id)
            .set(user.toJson())
            .timeout(
              const Duration(seconds: 5), 
              onTimeout: () {
                throw TimeoutException('Firestore operation timed out');
              }
            );
        
        debugPrint('User data saved to Firestore successfully');
      } catch (firestoreError) {
        // Log but don't fail the whole registration process
        debugPrint('Non-critical error saving to Firestore: $firestoreError');
        debugPrint('Continuing with auth-only registration');
      }
    }
    
    return userCredential;
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      
      // Clear shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.prefKeyUser);
      await prefs.remove(AppConstants.prefKeyDuo);
    } catch (e) {
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }
  
  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Failed to reset password: ${e.toString()}');
    }
  }
  
  // Get user data from Firestore
  Future<UserModel> getUserData(String userId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.collectionUsers)
          .doc(userId)
          .get();
      
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      } else {
        // If document doesn't exist, create a basic one
        debugPrint('User document not found in Firestore. Creating a new one from getUserData.');
        
        // Get basic info from Firebase Auth
        User? authUser = _auth.currentUser;
        String email = authUser?.email ?? 'user@example.com';
        String displayName = authUser?.displayName ?? email.split('@')[0];
        
        final newUser = UserModel(
          id: userId,
          email: email,
          displayName: displayName,
          profilePicture: authUser?.photoURL,
          monthlySalary: AppConstants.defaultMonthlySalary,
          savingGoals: AppConstants.defaultSavingGoals,
          createdAt: DateTime.now(),
          lastActive: DateTime.now(),
        );
        
        // Save to Firestore
        await _firestore
            .collection(AppConstants.collectionUsers)
            .doc(userId)
            .set(newUser.toJson());
        
        debugPrint('Created new user document in Firestore from getUserData');
        return newUser;
      }
    } catch (e) {
      throw Exception('Failed to get user data: ${e.toString()}');
    }
  }
  
  // Update user data in Firestore
  Future<void> updateUserData(UserModel user) async {
    try {
      await _firestore
          .collection(AppConstants.collectionUsers)
          .doc(user.id)
          .update(user.toJson());
    } catch (e) {
      throw Exception('Failed to update user data: ${e.toString()}');
    }
  }
  
  // Update profile picture
  Future<void> updateProfilePicture(String userId, String? profilePictureUrl) async {
    try {
      if (useMockData) {
        // In mock mode, just pretend the update succeeded
        debugPrint('Mock profile picture updated to: $profilePictureUrl');
        return;
      }
      
      // For real mode, update in Firestore
      await _firestore
          .collection(AppConstants.collectionUsers)
          .doc(userId)
          .update({'profilePicture': profilePictureUrl});
      
      // Update photo URL in Firebase Auth
      if (currentUser != null) {
        await currentUser!.updatePhotoURL(profilePictureUrl);
      }
    } catch (e) {
      debugPrint('Error updating profile picture: $e');
      throw Exception('Failed to update profile picture: ${e.toString()}');
    }
  }
  
  // Check if email is already in use
  Future<bool> isEmailInUse(String email) async {
    try {
      // Instead of checking beforehand, we'll return false and let the registration attempt handle any conflicts
      return false;
    } catch (e) {
      return false;
    }
  }
} 