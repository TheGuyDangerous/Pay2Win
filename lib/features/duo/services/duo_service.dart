import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../models/duo_model.dart';
import '../../../main.dart'; // Import to access useMockData
import 'package:flutter/foundation.dart';

class DuoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get duo by ID
  Future<DuoModel> getDuo(String duoId) async {
    try {
      // Check if we're using mock data
      if (useMockData) {
        final prefs = await SharedPreferences.getInstance();
        final duoJson = prefs.getString('duo_$duoId');
        
        if (duoJson == null) {
          throw Exception('Duo not found');
        }
        
        return DuoModel.fromJson(jsonDecode(duoJson));
      } else {
        // Use Firestore
        final docSnapshot = await _firestore
            .collection(AppConstants.collectionDuos)
            .doc(duoId)
            .get();
        
        if (!docSnapshot.exists) {
          throw Exception('Duo not found');
        }
        
        return DuoModel.fromJson(docSnapshot.data()!);
      }
    } catch (e) {
      debugPrint('Error getting duo: $e');
      throw Exception('Failed to get duo: ${e.toString()}');
    }
  }
  
  // Generate a unique code for creating a duo
  Future<String> generateCode() async {
    try {
      // Generate a 6-character code
      // In a real app, you'd check for uniqueness
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final code = timestamp.toString().substring(5, 11).toUpperCase();
      
      return code;
    } catch (e) {
      debugPrint('Error generating code: $e');
      throw Exception('Failed to generate code: ${e.toString()}');
    }
  }
  
  // Create a new duo with the generated code
  Future<DuoModel> createDuo(
    String userId,
    String userName,
    String code,
  ) async {
    try {
      // Check if we're using mock data
      if (useMockData) {
        // Use local storage for mock data
        final prefs = await SharedPreferences.getInstance();
        
        // Generate a random duo ID
        final duoId = 'duo_${DateTime.now().millisecondsSinceEpoch}';
        
        final duo = DuoModel(
          id: duoId,
          code: code,
          user1Id: userId,
          user1Name: userName,
          createdAt: DateTime.now(),
          isActive: true,
        );
        
        // Save to local storage
        await prefs.setString('duo_$duoId', jsonEncode(duo.toJson()));
        
        // Save code mapping
        await prefs.setString('code_$code', duoId);
        
        debugPrint('Created mock duo with ID: $duoId and code: $code');
        return duo;
      } else {
        // Use Firestore
        final docRef = _firestore
            .collection(AppConstants.collectionDuos)
            .doc();
        
        final duo = DuoModel(
          id: docRef.id,
          code: code,
          user1Id: userId,
          user1Name: userName,
          createdAt: DateTime.now(),
          isActive: true,
        );
        
        await docRef.set(duo.toJson());
        
        // Create a code mapping document
        await _firestore
            .collection('duo_codes')
            .doc(code)
            .set({
              'duoId': docRef.id,
              'createdAt': Timestamp.fromDate(DateTime.now()),
            });
        
        return duo;
      }
    } catch (e) {
      debugPrint('Error creating duo: $e');
      throw Exception('Failed to create duo: ${e.toString()}');
    }
  }
  
  // Join an existing duo with a code
  Future<DuoModel> joinDuo(
    String userId,
    String userName,
    String code,
  ) async {
    try {
      // Check if we're using mock data
      if (useMockData) {
        // Use local storage for mock data
        final prefs = await SharedPreferences.getInstance();
        
        // Get duo ID from code mapping
        final duoId = prefs.getString('code_$code');
        
        if (duoId == null) {
          throw Exception('Invalid code');
        }
        
        // Get duo from local storage
        final duoJson = prefs.getString('duo_$duoId');
        
        if (duoJson == null) {
          throw Exception('Duo not found');
        }
        
        // Parse duo
        final duoMap = jsonDecode(duoJson) as Map<String, dynamic>;
        DuoModel duo = DuoModel.fromJson(duoMap);
        
        // Update duo with user 2
        duo = duo.copyWith(
          user2Id: userId,
          user2Name: userName,
        );
        
        // Save updated duo
        await prefs.setString('duo_$duoId', jsonEncode(duo.toJson()));
        
        debugPrint('Joined mock duo with ID: $duoId and code: $code');
        return duo;
      } else {
        // Use Firestore
        // Get duo ID from code mapping
        final codeDoc = await _firestore
            .collection('duo_codes')
            .doc(code)
            .get();
        
        if (!codeDoc.exists) {
          throw Exception('Invalid code');
        }
        
        final duoId = codeDoc.data()!['duoId'] as String;
        
        // Get duo
        final duoDoc = await _firestore
            .collection(AppConstants.collectionDuos)
            .doc(duoId)
            .get();
        
        if (!duoDoc.exists) {
          throw Exception('Duo not found');
        }
        
        // Parse duo
        DuoModel duo = DuoModel.fromJson(duoDoc.data()!);
        
        // Update duo with user 2
        duo = duo.copyWith(
          user2Id: userId,
          user2Name: userName,
        );
        
        // Save updated duo
        await _firestore
            .collection(AppConstants.collectionDuos)
            .doc(duoId)
            .update(duo.toJson());
        
        return duo;
      }
    } catch (e) {
      debugPrint('Error joining duo: $e');
      throw Exception('Failed to join duo: ${e.toString()}');
    }
  }
  
  // Leave current duo
  Future<void> leaveDuo(String duoId) async {
    try {
      // Check if we're using mock data
      if (useMockData) {
        // Use local storage for mock data
        final prefs = await SharedPreferences.getInstance();
        
        // Get duo from local storage
        final duoJson = prefs.getString('duo_$duoId');
        
        if (duoJson == null) {
          throw Exception('Duo not found');
        }
        
        // Parse duo
        final duoMap = jsonDecode(duoJson) as Map<String, dynamic>;
        DuoModel duo = DuoModel.fromJson(duoMap);
        
        // Set duo to inactive
        duo = duo.copyWith(isActive: false);
        
        // Save updated duo
        await prefs.setString('duo_$duoId', jsonEncode(duo.toJson()));
        
        debugPrint('Left mock duo with ID: $duoId');
      } else {
        // Use Firestore
        await _firestore
            .collection(AppConstants.collectionDuos)
            .doc(duoId)
            .update({'isActive': false});
      }
    } catch (e) {
      debugPrint('Error leaving duo: $e');
      throw Exception('Failed to leave duo: ${e.toString()}');
    }
  }
  
  // Check if a code is valid
  Future<bool> isCodeValid(String code) async {
    try {
      // Check if we're using mock data
      if (useMockData) {
        // Use local storage for mock data
        final prefs = await SharedPreferences.getInstance();
        
        // Check if code exists
        final duoId = prefs.getString('code_$code');
        
        return duoId != null;
      } else {
        // Use Firestore
        final codeDoc = await _firestore
            .collection('duo_codes')
            .doc(code)
            .get();
        
        return codeDoc.exists;
      }
    } catch (e) {
      debugPrint('Error checking code validity: $e');
      throw Exception('Failed to check code validity: ${e.toString()}');
    }
  }
} 