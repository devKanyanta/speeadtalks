import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speedtalks/screens/add_event.dart';
import 'package:speedtalks/screens/chat.dart';
import 'package:speedtalks/screens/chat_room.dart';
import 'package:speedtalks/screens/choose_event.dart';
import 'package:speedtalks/screens/matching_page.dart';
import 'package:speedtalks/screens/profile.dart';
import 'package:speedtalks/screens/register_event.dart';
import 'package:speedtalks/screens/register_success.dart';
import 'package:speedtalks/screens/registered_events.dart';
import 'package:speedtalks/screens/sign_up_sign_in.dart';
import 'package:speedtalks/screens/update_user_details.dart';
import 'package:speedtalks/services/auth_controller.dart';
import 'package:speedtalks/services/event_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Supabase.initialize(
    url: 'https://eabgabvegvrldmhktodq.supabase.co', // Replace with your API URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVhYmdhYnZlZ3ZybGRtaGt0b2RxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQxNDIxMDQsImV4cCI6MjA0OTcxODEwNH0.IP1KEjLjJZM8qo2fXnqQ9oM839_cRhpPLBViEC-Qp0U',              // Replace with your anon key
  );
  Get.put(AuthController());
  Get.put(EventController());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: authController.isLoggedIn.value ? '/events' : '/signIn',
      getPages: [
        GetPage(name: '/events', page: () => Events()),
        GetPage(name: '/addEvent', page: () => AddEventPage()),
        GetPage(name: '/signIn', page: () => SignInSignUpPage()),
        GetPage(name: '/messages', page: ()=>ChatPage()),
        GetPage(name: '/profile', page: ()=>UserProfilePage()),
        GetPage(name: '/updateUser', page: ()=>UpdateUserDetailsPage()),
        GetPage(name: '/registerEvent', page: ()=>RegisterEvent()),
        GetPage(name: '/registerSuccess', page: ()=>RegisterSuccess()),
        GetPage(name: '/registeredEvents', page: ()=>RegisteredEventsPage()),
        GetPage(name: '/matching', page: ()=>MatchingPage()),
        GetPage(name: '/chatRoom', page: ()=>ChatRoomPage()),
      ],
    );
  }
}
