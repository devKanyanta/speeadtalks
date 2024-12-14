import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speedtalks/models/chat_args.dart';
import 'package:speedtalks/services/auth_controller.dart';
import '../models/user_model.dart';
import '../services/chat_controller.dart';

class ChatRoomPage extends StatelessWidget {
  final ChatController chatController = Get.put(ChatController());
  final currentUserId = Get.arguments as String;
  final AuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    chatController.fetchUserChats(currentUserId);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chats',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (chatController.userChats.isEmpty) {
          return Center(
            child: Text(
              'No chats yet.',
              style: GoogleFonts.poppins(fontSize: 18.0, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: chatController.userChats.length,
          itemBuilder: (context, index) {
            final chat = chatController.userChats[index];
            final otherUserId = chat.participants
                .firstWhere((id) => id != currentUserId); // Get the other user
            final lastMessage = chat.lastMessage;

            return FutureBuilder(
              future: authController.getUserDetailsById(otherUserId),
              builder: (BuildContext context, AsyncSnapshot<UserModel> snapshot) {
                if(snapshot.data == null){
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                UserModel? userModel = snapshot.data;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                        userModel!.profilePictureUrl == '' ? "http://placebeard.it/250/250" : userModel!.profilePictureUrl
                    ),
                  ),
                  title: Text(
                    userModel.fullName, // Replace with the other user's name if available
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    lastMessage?['content'] ?? '',
                    style: GoogleFonts.poppins(color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    // Navigate to Chat Page
                    Get.toNamed('/messages', arguments: ChatArgs(currentUserId, otherUserId));
                  },
                );
              },
            );
          },
        );
      }),
    );
  }
}
