import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> getOrCreateChatRoom(String userId1, String userId2) async {
    // sort user IDs to ensure consistency
    final participants = [userId1, userId2]..sort();
    final chatId = participants.join('_');

    final chatRef = _firestore.collection('chats').doc(chatId);

    // Check if chat already exists
    final chatSnapshot = await chatRef.get();

    if (!chatSnapshot.exists) {
      // Create new chat
      await chatRef.set({
        'participants': participants,
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    }
    return chatId;
  }

  Stream<QuerySnapshot> getChatMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    final messagesRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages');

    // Add new message
    await messagesRef.add({
      'text': text,
      'senderId': senderId,
      'senderName': senderName,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    });

    // Update last message in chat
    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }
}
