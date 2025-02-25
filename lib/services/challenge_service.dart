import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../models/challenge_model.dart';

class ChallengeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get all challenges for a duo
  Future<List<ChallengeModel>> getChallenges(String duoId) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.collectionChallenges)
          .doc(duoId)
          .collection('items')
          .orderBy('startDate', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => ChallengeModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get challenges: ${e.toString()}');
    }
  }
  
  // Get active challenges
  Future<List<ChallengeModel>> getActiveChallenges(String duoId) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.collectionChallenges)
          .doc(duoId)
          .collection('items')
          .where('status', isEqualTo: 'active')
          .orderBy('startDate', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => ChallengeModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get active challenges: ${e.toString()}');
    }
  }
  
  // Get completed challenges
  Future<List<ChallengeModel>> getCompletedChallenges(String duoId) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.collectionChallenges)
          .doc(duoId)
          .collection('items')
          .where('status', isEqualTo: 'completed')
          .orderBy('startDate', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => ChallengeModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get completed challenges: ${e.toString()}');
    }
  }
  
  // Create a new challenge
  Future<String> createChallenge(String duoId, ChallengeModel challenge) async {
    try {
      final docRef = _firestore
          .collection(AppConstants.collectionChallenges)
          .doc(duoId)
          .collection('items')
          .doc();
      
      final challengeWithId = challenge.copyWith(id: docRef.id);
      
      await docRef.set(challengeWithId.toJson());
      
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create challenge: ${e.toString()}');
    }
  }
  
  // Update challenge status
  Future<bool> updateChallengeStatus(
    String duoId,
    String challengeId,
    String status,
  ) async {
    try {
      await _firestore
          .collection(AppConstants.collectionChallenges)
          .doc(duoId)
          .collection('items')
          .doc(challengeId)
          .update({
        'status': status,
      });
      
      return true;
    } catch (e) {
      throw Exception('Failed to update challenge status: ${e.toString()}');
    }
  }
  
  // Complete a challenge for a user
  Future<bool> completeChallenge(
    String duoId,
    String challengeId,
    String userId,
  ) async {
    try {
      // Get the challenge
      final doc = await _firestore
          .collection(AppConstants.collectionChallenges)
          .doc(duoId)
          .collection('items')
          .doc(challengeId)
          .get();
      
      if (!doc.exists) {
        throw Exception('Challenge not found');
      }
      
      final challenge = ChallengeModel.fromJson(doc.data()!);
      
      // Update participants map
      final updatedParticipants = Map<String, bool>.from(challenge.participants);
      updatedParticipants[userId] = true;
      
      // Check if all participants have completed the challenge
      final allCompleted = updatedParticipants.values.every((completed) => completed);
      
      // Update the challenge
      await _firestore
          .collection(AppConstants.collectionChallenges)
          .doc(duoId)
          .collection('items')
          .doc(challengeId)
          .update({
        'participants': updatedParticipants,
        if (allCompleted) 'status': 'completed',
      });
      
      return true;
    } catch (e) {
      throw Exception('Failed to complete challenge: ${e.toString()}');
    }
  }
  
  // Delete a challenge
  Future<bool> deleteChallenge(String duoId, String challengeId) async {
    try {
      await _firestore
          .collection(AppConstants.collectionChallenges)
          .doc(duoId)
          .collection('items')
          .doc(challengeId)
          .delete();
      
      return true;
    } catch (e) {
      throw Exception('Failed to delete challenge: ${e.toString()}');
    }
  }
} 