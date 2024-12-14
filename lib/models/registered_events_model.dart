import 'package:cloud_firestore/cloud_firestore.dart';

class RegisteredEvent {
  final String userId;
  final String eventDetails;
  final String eventType;
  final DateTime registrationDate;

  RegisteredEvent({
    required this.userId,
    required this.eventDetails,
    required this.eventType,
    required this.registrationDate,
  });

  factory RegisteredEvent.fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return RegisteredEvent(
      userId: data['userId'] as String,
      eventDetails: data['eventDate'] as String,
      eventType: data['eventType'] as String,
      registrationDate: (data['registrationDate'] as Timestamp).toDate(),
    );
  }
}
