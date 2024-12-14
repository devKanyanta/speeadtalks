import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speedtalks/models/event_arg.dart';
import 'package:speedtalks/screens/register_event.dart';
import 'package:speedtalks/widgets/drawer.dart';
import '../models/event_model.dart';
import '../services/auth_controller.dart';
import '../widgets/event_card.dart';

class Events extends StatefulWidget {
  const Events({super.key});

  @override
  State<Events> createState() => _EventsState();
}

class _EventsState extends State<Events> {
  final List<Event> events = [
    Event("Business Networking", Icons.business_center, Colors.blueAccent),
    Event("Speed Dating", Icons.favorite, Colors.teal),
    Event("Friendship Connections", Icons.people, Colors.orange),
    Event("Gaming Connections", Icons.videogame_asset, Colors.green),
    Event("Book Hub", Icons.book, Colors.redAccent),
    Event("Growth & Wellness", Icons.fitness_center, Colors.amber),
    Event("Creative Collaboration", Icons.lightbulb, Colors.purple),
    Event("Finance", Icons.account_balance_wallet, Colors.indigo),
    Event("Political Arguments", Icons.gavel, Colors.brown),
    Event("Technology", Icons.memory, Colors.cyan),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Choose Your Event",
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: MyDrawer(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select from our collection of experiences",
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return EventCard(event: event, onPressed: () {
                    Get.toNamed('/registerEvent', arguments: EventArg(events[index].name));
                  },);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
