import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:speedtalks/screens/add_event.dart';
import 'package:speedtalks/services/event_controller.dart';
import 'package:speedtalks/widgets/drawer.dart';

import '../models/event.dart';
import '../models/event_arg.dart';
import '../services/auth_controller.dart';

class RegisterEvent extends StatelessWidget {
  const RegisterEvent({super.key});

  @override
  Widget build(BuildContext context) {
    bool isLoading = true;
    final EventController eventController = Get.find();
    final AuthController authController = Get.find();
    final event = Get.arguments as EventArg;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Register for event',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      drawer: MyDrawer(),
      body: FutureBuilder(
        future: eventController.getEventByEventType(event.event),
        builder: (BuildContext context, AsyncSnapshot<EventModel?> snapshot) {
          if(snapshot.data == null){
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final eventData = snapshot.data;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        if (isLoading)
                          Text(
                            'Loading...',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                fontSize: 20
                            ),
                          ),
                        const SizedBox(height: 10,),
                        Text(
                          eventData!.description,
                          style: GoogleFonts.poppins(
                              fontSize: 14
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          "Event Details",
                          style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w500
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: Colors.deepPurpleAccent,
                            ),
                            const SizedBox(width: 10.0),
                            Text(
                              eventData.eventDetails,
                              style: GoogleFonts.poppins(
                                  fontSize: 13
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          "Timeline",
                          style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w500
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.warning,
                              color: Colors.redAccent,
                            ),
                            const SizedBox(width: 10.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Registration Closes In:',
                                  style: GoogleFonts.poppins(
                                      fontSize: 14
                                  ),
                                ),
                                Text(
                                  eventData.registrationCloseDate,
                                  style: GoogleFonts.poppins(
                                      color: Colors.redAccent,
                                      fontSize: 13
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        Row(
                          children: [
                            const Icon(
                              Icons.people,
                              color: Colors.deepPurple,
                            ),
                            const SizedBox(width: 10.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Matching Starts:',
                                  style: GoogleFonts.poppins(
                                      fontSize: 14
                                  ),
                                ),
                                Text(
                                  eventData.matchingStartDate,
                                  style: GoogleFonts.poppins(
                                      fontSize: 13
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                SizedBox(
                    width: double.maxFinite,
                    height: 55,
                    child: EasyButton(
                      onPressed: () async {
                        final String? userId = await authController.getUserId(); // Assuming you have an AuthController with a method to get current user ID
                        final eventData = await eventController.getEventByEventType(event.event);

                        if (eventData != null)
                          await eventController.registerUserForEvent(userId!, eventData);
                      },
                      idleStateWidget: Text(
                        'Register Now',
                        style: GoogleFonts.poppins(
                          color: Colors.white, // Text color
                          fontSize: 16, // Font size
                          fontWeight: FontWeight.bold, // Font weight
                        ),
                      ),
                      useWidthAnimation: true,
                      useEqualLoadingStateWidgetDimension: true,
                      contentGap: 6.0,
                      borderRadius: 25.0,
                      loadingStateWidget: const CircularProgressIndicator(
                        strokeWidth: 3.0,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

