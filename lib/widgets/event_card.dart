import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/event_model.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onPressed;

  const EventCard({Key? key, required this.event, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      color: event.color,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: event.color.withOpacity(0.2),
          child: Icon(event.icon, color: Colors.white),
        ),
        title: Text(
          event.name,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white
          ),
        ),
        onTap: onPressed
      ),
    );
  }
}