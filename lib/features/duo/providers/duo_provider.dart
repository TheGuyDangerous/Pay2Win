import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../models/duo_model.dart';
import '../services/duo_service.dart';

class DuoProvider extends ChangeNotifier {
  final DuoService _duoService = DuoService();
  
  DuoModel? _currentDuo;
  bool _isLoading = false;
  String? _error;
  String? _generatedCode;
  
  DuoModel? get currentDuo => _currentDuo;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get generatedCode => _generatedCode;
  bool get hasDuo => _currentDuo != null;
  
  // Load current duo from preferences
  Future<void> initialize() async {
    _setLoading(true);
    
    try {
      // Clear any existing duo data first to prevent data from previous user
      _currentDuo = null;
      _generatedCode = null;
      
      final prefs = await SharedPreferences.getInstance();
      final duoId = prefs.getString(AppConstants.prefKeyDuo);
      
      if (duoId != null) {
        _currentDuo = await _duoService.getDuo(duoId);
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  
  // Generate a unique code for creating a duo
  Future<String> generateCode() async {
    _setLoading(true);
    
    try {
      _generatedCode = await _duoService.generateCode();
      notifyListeners();
      return _generatedCode!;
    } catch (e) {
      _setError(e.toString());
      return '';
    } finally {
      _setLoading(false);
    }
  }
  
  // Create a new duo with the generated code
  Future<bool> createDuo(String userId, String userName) async {
    if (_generatedCode == null) {
      await generateCode();
    }
    
    _setLoading(true);
    
    try {
      _currentDuo = await _duoService.createDuo(
        userId,
        userName,
        _generatedCode!,
      );
      
      // Save duo ID to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.prefKeyDuo, _currentDuo!.id);
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Join an existing duo with a code
  Future<bool> joinDuo(String userId, String userName, String code) async {
    _setLoading(true);
    
    try {
      _currentDuo = await _duoService.joinDuo(userId, userName, code);
      
      // Save duo ID to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.prefKeyDuo, _currentDuo!.id);
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Leave current duo
  Future<bool> leaveDuo() async {
    if (_currentDuo == null) return false;
    
    _setLoading(true);
    
    try {
      await _duoService.leaveDuo(_currentDuo!.id);
      
      // Remove duo ID from shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.prefKeyDuo);
      
      _currentDuo = null;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Check if a code is valid
  Future<bool> isCodeValid(String code) async {
    _setLoading(true);
    
    try {
      final isValid = await _duoService.isCodeValid(code);
      return isValid;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
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
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  // Clear current duo data
  Future<void> clearDuo() async {
    _currentDuo = null;
    _generatedCode = null;
    
    // Remove duo ID from shared preferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.prefKeyDuo);
    } catch (e) {
      debugPrint('Error clearing duo preferences: $e');
    }
    
    notifyListeners();
  }
} 