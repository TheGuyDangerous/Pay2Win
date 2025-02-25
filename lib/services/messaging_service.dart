import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../models/message_model.dart';

class MessagingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get messages for a duo
  Future<List<MessageModel>> getMessages(String duoId) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.collectionMessages)
          .doc(duoId)
          .collection('items')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();
      
      return querySnapshot.docs
          .map((doc) => MessageModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get messages: ${e.toString()}');
    }
  }
  
  // Send a message
  Future<String> sendMessage(String duoId, MessageModel message) async {
    try {
      final docRef = _firestore
          .collection(AppConstants.collectionMessages)
          .doc(duoId)
          .collection('items')
          .doc();
      
      final messageWithId = message.copyWith(id: docRef.id);
      
      await docRef.set(messageWithId.toJson());
      
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to send message: ${e.toString()}');
    }
  }
  
  // Update a message
  Future<bool> updateMessage(String duoId, MessageModel message) async {
    try {
      await _firestore
          .collection(AppConstants.collectionMessages)
          .doc(duoId)
          .collection('items')
          .doc(message.id)
          .update(message.toJson());
      
      return true;
    } catch (e) {
      throw Exception('Failed to update message: ${e.toString()}');
    }
  }
  
  // Delete a message
  Future<bool> deleteMessage(String duoId, String messageId) async {
    try {
      await _firestore
          .collection(AppConstants.collectionMessages)
          .doc(duoId)
          .collection('items')
          .doc(messageId)
          .delete();
      
      return true;
    } catch (e) {
      throw Exception('Failed to delete message: ${e.toString()}');
    }
  }
} 