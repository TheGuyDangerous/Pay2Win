import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/challenge_model.dart';
import '../../../services/challenge_service.dart';

class ChallengesProvider extends ChangeNotifier {
  final ChallengeService _challengeService = ChallengeService();
  
  List<ChallengeModel> _challenges = [];
  ChallengeModel? _selectedChallenge;
  bool _isLoading = false;
  String? _error;
  
  List<ChallengeModel> get challenges => _challenges;
  ChallengeModel? get selectedChallenge => _selectedChallenge;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Get all challenges for a duo
  Future<void> getChallenges(String duoId) async {
    _setLoading(true);
    
    try {
      _challenges = await _challengeService.getChallenges(duoId);
      
      // Setup real-time listener
      _setupRealTimeListener(duoId);
      
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  
  // Get active challenges
  Future<void> getActiveChallenges(String duoId) async {
    _setLoading(true);
    
    try {
      _challenges = await _challengeService.getActiveChallenges(duoId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  
  // Get completed challenges
  Future<void> getCompletedChallenges(String duoId) async {
    _setLoading(true);
    
    try {
      _challenges = await _challengeService.getCompletedChallenges(duoId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  
  // Create a new challenge
  Future<bool> createChallenge(
    String duoId,
    String createdBy,
    String title,
    String description,
    DateTime startDate,
    DateTime endDate,
  ) async {
    _setLoading(true);
    
    try {
      final challenge = ChallengeModel(
        id: '',
        title: title,
        description: description,
        createdBy: createdBy,
        startDate: startDate,
        endDate: endDate,
        status: 'active',
        participants: {
          createdBy: false,
        },
      );
      
      final challengeId = await _challengeService.createChallenge(duoId, challenge);
      
      if (challengeId.isNotEmpty) {
        final newChallenge = challenge.copyWith(id: challengeId);
        _challenges.insert(0, newChallenge);
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Update challenge status
  Future<bool> updateChallengeStatus(
    String duoId,
    String challengeId,
    String status,
  ) async {
    _setLoading(true);
    
    try {
      final success = await _challengeService.updateChallengeStatus(
        duoId,
        challengeId,
        status,
      );
      
      if (success) {
        final index = _challenges.indexWhere((c) => c.id == challengeId);
        
        if (index != -1) {
          _challenges[index] = _challenges[index].copyWith(status: status);
          
          if (_selectedChallenge?.id == challengeId) {
            _selectedChallenge = _challenges[index];
          }
          
          notifyListeners();
        }
        
        return true;
      }
      
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Complete a challenge for a user
  Future<bool> completeChallenge(
    String duoId,
    String challengeId,
    String userId,
  ) async {
    _setLoading(true);
    
    try {
      final success = await _challengeService.completeChallenge(
        duoId,
        challengeId,
        userId,
      );
      
      if (success) {
        final index = _challenges.indexWhere((c) => c.id == challengeId);
        
        if (index != -1) {
          final updatedParticipants = Map<String, bool>.from(_challenges[index].participants);
          updatedParticipants[userId] = true;
          
          _challenges[index] = _challenges[index].copyWith(
            participants: updatedParticipants,
          );
          
          if (_selectedChallenge?.id == challengeId) {
            _selectedChallenge = _challenges[index];
          }
          
          notifyListeners();
        }
        
        return true;
      }
      
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Delete a challenge
  Future<bool> deleteChallenge(String duoId, String challengeId) async {
    _setLoading(true);
    
    try {
      final success = await _challengeService.deleteChallenge(duoId, challengeId);
      
      if (success) {
        _challenges.removeWhere((c) => c.id == challengeId);
        
        if (_selectedChallenge?.id == challengeId) {
          _selectedChallenge = null;
        }
        
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Set selected challenge
  void setSelectedChallenge(ChallengeModel challenge) {
    _selectedChallenge = challenge;
    notifyListeners();
  }
  
  // Clear selected challenge
  void clearSelectedChallenge() {
    _selectedChallenge = null;
    notifyListeners();
  }
  
  // Setup real-time listener for challenges
  void _setupRealTimeListener(String duoId) {
    FirebaseFirestore.instance
        .collection(AppConstants.collectionChallenges)
        .doc(duoId)
        .collection('items')
        .orderBy('startDate', descending: true)
        .snapshots()
        .listen((snapshot) {
      _challenges = snapshot.docs
          .map((doc) => ChallengeModel.fromJson(doc.data()))
          .toList();
      
      notifyListeners();
    });
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
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
} 