import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:speedtalks/services/event_controller.dart';

import '../models/event.dart';

class AddEventPage extends StatefulWidget {
  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _eventDetailsController = TextEditingController();
  final TextEditingController _registrationCloseDateController = TextEditingController();
  final TextEditingController _matchingStartDateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final EventController eventController = EventController();

  String _selectedEventType = 'Business Networking';

  // List of event types
  final List<String> eventTypes = [
    'Business Networking',
    'Speed Dating',
    'Friendship Connections',
    'Gaming Connections',
    'Book Hub',
    'Growth & Wellness',
    'Creative Collaboration',
    'Finance',
    'Political Arguments',
    'Technology',
  ];

  // Date format object
  final DateFormat _dateFormat = DateFormat('EEEE, MMMM d, yyyy, h:mm a'); // Customize format here

  // Helper method to show date picker
  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final DateTime combinedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          controller.text = _dateFormat.format(combinedDateTime); // Format date and time
        });
      }
    }
  }


  void saveEvent() {
    // Create an Event instance from controller values
    final event = EventModel(
      eventType: _selectedEventType,
      eventDetails: _eventDetailsController.text,
      registrationCloseDate: _registrationCloseDateController.text,
      matchingStartDate: _matchingStartDateController.text,
      description: _descriptionController.text,
    );

    // Save the event to Firestore
    eventController.saveEventToFirestore(event);

    // Clear the controllers (optional)
    _eventDetailsController.clear();
    _registrationCloseDateController.clear();
    _matchingStartDateController.clear();
    _descriptionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add New Event',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [

              // Event Type Dropdown
              DropdownButtonFormField<String>(
                value: _selectedEventType,
                decoration: const InputDecoration(
                  labelText: 'Event Type',
                  border: OutlineInputBorder(),
                ),
                items: eventTypes.map((eventType) {
                  return DropdownMenuItem<String>(
                    value: eventType,
                    child: Text(eventType),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedEventType = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an event type';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0,),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description for the event.';
                  }
                  return null;
                },
                minLines: 4,
                maxLines: 6, // Allows the field to expand vertically for multiline input
              ),
              SizedBox(height: 16.0),
              // Event Details
              TextFormField(
                controller: _eventDetailsController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date of Event',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context, _eventDetailsController),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a registration close date';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              // Registration Close Date
              TextFormField(
                controller: _registrationCloseDateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Registration Close Date',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context, _registrationCloseDateController),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a registration close date';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              // Matching Start Date
              TextFormField(
                controller: _matchingStartDateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Matching Start Date',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context, _matchingStartDateController),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a matching start date';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24.0),

              // Submit Button
              EasyButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {

                    Future.delayed(const Duration(seconds: 2), (){
                      saveEvent();
                    });

                    Get.snackbar("Success", "Event has been saved to database");
                  }
                },
                idleStateWidget: Text(
                  'Add Event',
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                  ),
                ),
                useWidthAnimation: true,
                useEqualLoadingStateWidgetDimension: true,
                width: 80.0,
                height: 50.0,
                contentGap: 6.0,
                borderRadius: 25.0,
                loadingStateWidget: const CircularProgressIndicator(
                  strokeWidth: 3.0,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
