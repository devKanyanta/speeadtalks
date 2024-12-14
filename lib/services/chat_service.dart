import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generate Chat ID
  String _generateChatId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort(); // Sort the IDs to ensure consistency
    return ids.join('_');
  }

  // Send a message
  Future<void> sendMessage(String senderId, String receiverId, String content) async {
    try {
      String chatId = _generateChatId(senderId, receiverId);

      // Create a more efficient document reference
      DocumentReference chatRef = _firestore.collection('chats').doc(chatId);

      // Create message document
      String messageId = chatRef.collection('messages').doc().id;

      // Prepare message data with indexed fields
      Map<String, dynamic> messageData = {
        'id': messageId,
        'senderId': senderId,
        'receiverId': receiverId,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
        'participants': [senderId, receiverId]
      };

      // Batch write to update chat metadata and add message
      WriteBatch batch = _firestore.batch();

      // Update chat document with latest message info
      batch.set(chatRef, {
        'participants': [senderId, receiverId],
        'lastMessage': {
          'content': content,
          'senderId': senderId,
          'timestamp': FieldValue.serverTimestamp()
        }
      }, SetOptions(merge: true));

      // Add message to messages subcollection
      DocumentReference newMessageRef = chatRef.collection('messages').doc(messageId);
      batch.set(newMessageRef, messageData);

      // Commit the batch
      await batch.commit();
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  // Retrieve messages for a chat with pagination and type-safe conversion
  Stream<List<Message>> getMessages(
      String userId1,
      String userId2,
      {int limit = 50,
        DocumentSnapshot? lastDocument}
      ) {
    String chatId = _generateChatId(userId1, userId2);

    Query baseQuery = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(limit);

    // If a last document is provided, use it for pagination
    Query query = lastDocument != null
        ? baseQuery.startAfterDocument(lastDocument)
        : baseQuery;

    return query
        .snapshots()
        .map((snapshot) =>
        snapshot.docs
            .map((doc) {
          // Explicit type casting and null check
          final data = doc.data();
          if (data is Map<String, dynamic>) {
            return Message.fromMap(data);
          }
          // Optionally log or handle unexpected data types
          print('Unexpected data type in message document: ${data.runtimeType}');
          return null;
        })
            .whereType<Message>() // Filter out any null values
            .toList());
  }

// Helper method for loading more messages with type-safe conversion
  Future<List<Message>> loadMoreMessages(
      String userId1,
      String userId2,
      DocumentSnapshot lastDocument
      ) async {
    QuerySnapshot moreMessagesSnapshot = await _firestore
        .collection('chats')
        .doc(_generateChatId(userId1, userId2))
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .startAfterDocument(lastDocument)
        .limit(50)
        .get();

    return moreMessagesSnapshot.docs
        .map((doc) {
      final data = doc.data();
      if (data is Map<String, dynamic>) {
        return Message.fromMap(data);
      }
      // Optionally log unexpected data types
      print('Unexpected data type in message document: ${data.runtimeType}');
      return null;
    })
        .whereType<Message>() // Filter out any null values
        .toList();
  }
}
