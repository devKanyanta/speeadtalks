class Chat {
  final String chatId;
  final List<String> participants;
  final Map<String, dynamic>? lastMessage;

  Chat({
    required this.chatId,
    required this.participants,
    required this.lastMessage,
  });
}