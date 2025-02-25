import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/duo_model.dart';
import '../models/user_model.dart';

class DuoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get current duo for a user
  Future<DuoModel?> getCurrentDuo(String userId) async {
    try {
      // Check if user has a duo in shared preferences
      final prefs = await SharedPreferences.getInstance();
      final duoId = prefs.getString(AppConstants.prefKeyDuo);
      
      if (duoId != null) {
        // Get duo from Firestore
        final doc = await _firestore
            .collection(AppConstants.collectionDuos)
            .doc(duoId)
            .get();
        
        if (doc.exists) {
          return DuoModel.fromJson(doc.data()!);
        }
      }
      
      // If no duo in shared preferences, check Firestore
      final querySnapshot = await _firestore
          .collection(AppConstants.collectionDuos)
          .where('user1Id', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        final duo = DuoModel.fromJson(querySnapshot.docs.first.data());
        
        // Save duo ID to shared preferences
        await prefs.setString(AppConstants.prefKeyDuo, duo.id);
        
        return duo;
      }
      
      // Check if user is user2
      final querySnapshot2 = await _firestore
          .collection(AppConstants.collectionDuos)
          .where('user2Id', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();
      
      if (querySnapshot2.docs.isNotEmpty) {
        final duo = DuoModel.fromJson(querySnapshot2.docs.first.data());
        
        // Save duo ID to shared preferences
        await prefs.setString(AppConstants.prefKeyDuo, duo.id);
        
        return duo;
      }
      
      return null;
    } catch (e) {
      throw Exception('Failed to get current duo: ${e.toString()}');
    }
  }
  
  // Get partner data
  Future<UserModel> getPartnerData(String partnerId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.collectionUsers)
          .doc(partnerId)
          .get();
      
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      } else {
        throw Exception('Partner not found');
      }
    } catch (e) {
      throw Exception('Failed to get partner data: ${e.toString()}');
    }
  }
  
  // Create a new duo
  Future<String> createDuo(String userId) async {
    try {
      // Generate a unique duo code
      final duoCode = _generateDuoCode();
      
      // Create duo document in Firestore
      final duoRef = _firestore.collection(AppConstants.collectionDuos).doc();
      
      final duo = {
        'id': duoRef.id,
        'user1Id': userId,
        'user2Id': '', // Will be filled when someone joins
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'isActive': false, // Will be set to true when someone joins
        'duoCode': duoCode,
      };
      
      await duoRef.set(duo);
      
      return duoCode;
    } catch (e) {
      throw Exception('Failed to create duo: ${e.toString()}');
    }
  }
  
  // Join an existing duo
  Future<bool> joinDuo(String userId, String duoCode) async {
    try {
      // Find duo with the given code
      final querySnapshot = await _firestore
          .collection(AppConstants.collectionDuos)
          .where('duoCode', isEqualTo: duoCode)
          .where('isActive', isEqualTo: false)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isEmpty) {
        throw Exception('Invalid duo code or duo already has a partner');
      }
      
      final duoDoc = querySnapshot.docs.first;
      final duoData = duoDoc.data();
      
      // Check if user is trying to join their own duo
      if (duoData['user1Id'] == userId) {
        throw Exception('You cannot join your own duo');
      }
      
      // Update duo with user2 and set to active
      await _firestore
          .collection(AppConstants.collectionDuos)
          .doc(duoData['id'])
          .update({
        'user2Id': userId,
        'isActive': true,
        'duoCode': null, // Remove the code once joined
      });
      
      // Save duo ID to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.prefKeyDuo, duoData['id']);
      
      return true;
    } catch (e) {
      throw Exception('Failed to join duo: ${e.toString()}');
    }
  }
  
  // Leave a duo
  Future<bool> leaveDuo(String userId, String duoId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.collectionDuos)
          .doc(duoId)
          .get();
      
      if (!doc.exists) {
        throw Exception('Duo not found');
      }
      
      final duoData = doc.data()!;
      
      // Check if user is part of the duo
      if (duoData['user1Id'] != userId && duoData['user2Id'] != userId) {
        throw Exception('You are not part of this duo');
      }
      
      // Delete the duo
      await _firestore
          .collection(AppConstants.collectionDuos)
          .doc(duoId)
          .delete();
      
      // Remove duo ID from shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.prefKeyDuo);
      
      return true;
    } catch (e) {
      throw Exception('Failed to leave duo: ${e.toString()}');
    }
  }
  
  // Generate a random duo code
  String _generateDuoCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }
  
  // Get duo by ID
  Future<DuoModel> getDuoById(String duoId) async {
    try {
      final duoDoc = await _firestore.collection(AppConstants.collectionDuos).doc(duoId).get();
      
      if (!duoDoc.exists) {
        throw Exception('Duo not found');
      }
      
      final duoData = duoDoc.data() as Map<String, dynamic>;
      return DuoModel.fromJson(duoData);
    } catch (e) {
      rethrow;
    }
  }
  
  // Get duo by user ID
  Future<DuoModel?> getDuoByUserId(String userId) async {
    try {
      // Query duos where user1.userId or user2.userId equals userId
      final query1 = await _firestore
          .collection(AppConstants.collectionDuos)
          .where('user1.userId', isEqualTo: userId)
          .get();
      
      if (query1.docs.isNotEmpty) {
        final duoData = query1.docs.first.data();
        return DuoModel.fromJson(duoData);
      }
      
      final query2 = await _firestore
          .collection(AppConstants.collectionDuos)
          .where('user2.userId', isEqualTo: userId)
          .get();
      
      if (query2.docs.isNotEmpty) {
        final duoData = query2.docs.first.data();
        return DuoModel.fromJson(duoData);
      }
      
      return null;
    } catch (e) {
      rethrow;
    }
  }
  
  // Delete duo
  Future<void> deleteDuo(String duoId) async {
    try {
      // Get duo document
      final duoDoc = await _firestore.collection(AppConstants.collectionDuos).doc(duoId).get();
      
      if (!duoDoc.exists) {
        throw Exception('Duo not found');
      }
      
      final duoData = duoDoc.data() as Map<String, dynamic>;
      
      // Delete duo document
      await _firestore.collection(AppConstants.collectionDuos).doc(duoId).delete();
    } catch (e) {
      rethrow;
    }
  }
} 