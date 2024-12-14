import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speedtalks/widgets/drawer.dart';

import '../models/chat_args.dart';
import '../services/chat_controller.dart';

class ChatPage extends StatefulWidget {

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatController chatController = Get.put(ChatController());
  final TextEditingController _messageController = TextEditingController();
  final chatArgs = Get.arguments as ChatArgs;

  @override
  void initState() {
    super.initState();
    chatController.listenToMessages(chatArgs.senderId, chatArgs.receiverId);
  }

  void sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    chatController.sendMessage(
      chatArgs.senderId,
      chatArgs.receiverId,
      _messageController.text.trim(),
    );

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chat',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      drawer: MyDrawer(),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: Obx(() {
              if (chatController.messages.isEmpty) {
                return Center(child: Text('No messages yet.'));
              }

              return ListView.builder(
                padding: EdgeInsets.all(8.0),
                reverse: true,
                itemCount: chatController.messages.length,
                itemBuilder: (context, index) {
                  final message = chatController.messages[index];
                  final isMe = message.senderId == chatArgs.senderId;

                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 4.0),
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.blueAccent : Colors.grey[200],
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12.0),
                          topRight: Radius.circular(12.0),
                          bottomLeft:
                          isMe ? Radius.circular(12.0) : Radius.circular(0.0),
                          bottomRight:
                          isMe ? Radius.circular(0.0) : Radius.circular(12.0),
                        ),
                      ),
                      child: Text(
                        message.content,
                        style: GoogleFonts.poppins(
                          fontSize: 16.0,
                          color: isMe ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),

          // Message input field
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                          width: 2,
                          color: Colors.black12,
                        ),
                        borderRadius: const BorderRadius.all(Radius.circular(25))),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: GoogleFonts.poppins(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                      ),
                      style: GoogleFonts.poppins(fontSize: 16.0),
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                GestureDetector(
                  onTap: sendMessage,
                  child: CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    radius: 24.0,
                    child: Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
