import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String eventType;
  final String eventDetails;
  final String registrationCloseDate;
  final String matchingStartDate;
  final String description;
  final Timestamp? createdAt;

  EventModel({
    required this.eventType,
    required this.eventDetails,
    required this.registrationCloseDate,
    required this.matchingStartDate,
    required this.description,
    this.createdAt,
  });

  // Convert an Event instance to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'eventType': eventType,
      'eventDetails': eventDetails,
      'registrationCloseDate': registrationCloseDate,
      'matchingStartDate': matchingStartDate,
      'description': description,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  // Create an Event instance from a Firestore document snapshot
  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      eventType: map['eventType'] ?? '',
      eventDetails: map['eventDetails'] ?? '',
      registrationCloseDate: map['registrationCloseDate'] ?? '',
      matchingStartDate: map['matchingStartDate'] ?? '',
      description: map['description'] ?? '',
      createdAt: map['createdAt'],
    );
  }
}
