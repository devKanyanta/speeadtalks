import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:speedtalks/models/args.dart';
import 'package:speedtalks/services/event_controller.dart';
import 'package:speedtalks/widgets/drawer.dart';

import '../models/registered_events_model.dart';

class RegisteredEventsPage extends StatelessWidget {

  const RegisteredEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final EventController eventController = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Registered Events',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w500
          ),
        ),
      ),
      drawer: MyDrawer(),
      body: FutureBuilder<List<RegisteredEvent>>(
        future: eventController.fetchRegisteredEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final registeredEvents = snapshot.data!;
            return ListView.builder(
              itemCount: registeredEvents.length,
              itemBuilder: (context, index) {
                final event = registeredEvents[index];
                return GestureDetector(
                  onTap: () async {
                    // DateFormat format = DateFormat('EEEE, MMMM d, yyyy, h:mm a');
                    //
                    // try {
                    //   DateTime inputDate = format.parse(event.eventDetails);
                    //   DateTime now = DateTime.now();
                    //
                    //   // Compare dates, considering time component
                    //   if (inputDate.isAtSameMomentAs(DateTime(now.weekday, now.month, now.day, inputDate.hour, inputDate.minute)) {
                    //     print("Navigate to '/matching' with arguments.");
                    //   } else {
                    //     print("Event hasn't started yet.");
                    //   }
                    // } catch (e) {
                    //   print("Error parsing date: $e");
                    // }
                    Get.toNamed('/matching', arguments: Args1(registeredEvents[index].eventType, registeredEvents[index].eventDetails));

                  },
                  child: ListTile(
                    title: Text(
                        event.eventType,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(event.eventDetails),
                    trailing: Text(event.registrationDate.toString()),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No registered events found.'));
          }
        },
      ),
    );
  }
}