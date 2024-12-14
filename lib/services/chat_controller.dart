import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import 'chat_service.dart';

class ChatController extends GetxController {
  final ChatService _chatService = ChatService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // List of chats for the current user
  final RxList<Chat> userChats = <Chat>[].obs;

  // Observable list of messages
  final RxList<Message> messages = <Message>[].obs;

  // Stream subscription for messages
  StreamSubscription? _messagesSubscription;

  // Fetch all chats for the current user
  Future<void> fetchUserChats(String userId) async {
    try {
      // Find all chats where the user is a participant
      QuerySnapshot chatSnapshot = await _firestore
          .collection('chats')
          .where('participants', arrayContains: userId)
          .get();

      // Process chats and fetch the last message for each
      List<Chat> fetchedChats = [];

      for (var chatDoc in chatSnapshot.docs) {
        // Get the chat ID
        String chatId = chatDoc.id;

        // Fetch the most recent message for this chat
        QuerySnapshot lastMessageSnapshot = await _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        // Determine the other participant
        List<String> participants = List<String>.from(chatDoc['participants'] ?? []);
        String otherParticipant = participants.firstWhere(
              (participant) => participant != userId,
          orElse: () => '',
        );

        // Prepare last message data
        Map<String, dynamic>? lastMessage;
        if (lastMessageSnapshot.docs.isNotEmpty) {
          final data = lastMessageSnapshot.docs.first.data();
          if (data is Map<String, dynamic>) {
            lastMessage = data;
          }
        }

        // Create Chat object
        Chat chat = Chat(
          chatId: chatId,
          participants: participants,
          lastMessage: lastMessage,
        );

        fetchedChats.add(chat);
      }

      // Sort chats by the timestamp of the last message (most recent first)
      fetchedChats.sort((a, b) {
        if (a.lastMessage == null && b.lastMessage == null) return 0;
        if (a.lastMessage == null) return 1;
        if (b.lastMessage == null) return -1;

        try {
          DateTime aTimestamp = (a.lastMessage!['timestamp'] as Timestamp).toDate();
          DateTime bTimestamp = (b.lastMessage!['timestamp'] as Timestamp).toDate();
          return bTimestamp.compareTo(aTimestamp);
        } catch (e) {
          print('Error sorting chats: $e');
          return 0;
        }
      });

      // Update observable list
      userChats.assignAll(fetchedChats);

      print(userChats);
    } catch (e) {
      print('Error retrieving user chats: $e');
      userChats.clear();
    }
  }

  // Send a message
  Future<void> sendMessage(String senderId, String receiverId, String content) async {
    try {
      await _chatService.sendMessage(senderId, receiverId, content);
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  // Listen to messages
  void listenToMessages(String userId1, String userId2) {
    // Cancel any existing subscription
    _messagesSubscription?.cancel();

    // Start new message listener
    _messagesSubscription = _chatService
        .getMessages(userId1, userId2)
        .listen(
          (messageList) {
        messages.assignAll(messageList);
      },
      onError: (error) {
        print('Error listening to messages: $error');
        messages.clear();
      },
    );
  }

  // Cleanup method to cancel subscriptions
  @override
  void onClose() {
    _messagesSubscription?.cancel();
    super.onClose();
  }

  // Method to get chat by ID
  Chat? getChatById(String chatId) {
    try {
      return userChats.firstWhere((chat) => chat.chatId == chatId);
    } catch (e) {
      return null;
    }
  }

  // Method to clear messages
  void clearMessages() {
    messages.clear();
  }
}