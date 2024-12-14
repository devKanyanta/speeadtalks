import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/event.dart';
import '../models/registered_events_model.dart';
import '../models/user_model.dart';
import 'auth_controller.dart';

class EventController{

  Future<void> saveEventToFirestore(EventModel event) async {
    try {
      // Reference to Firestore collection
      final CollectionReference eventsCollection =
      FirebaseFirestore.instance.collection('events');

      // Add the event to Firestore
      await eventsCollection.add(event.toMap());

      print("Event saved successfully!");
    } catch (e) {
      print("Error saving event: $e");
    }
  }

  Future<List<EventModel>> getAllEvents() async {
    try {
      final QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('events').get();

      return snapshot.docs
          .map((doc) => EventModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error fetching events: $e");
      return [];
    }
  }

  Future<List<RegisteredEvent>> fetchRegisteredEvents() async {
    final AuthController authController = Get.find();
    final String? userId = await authController.getUserId();

    final QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
        .collection('registeredEvents')
        .where('userId', isEqualTo: userId)
        .get();

    return querySnapshot.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
      return RegisteredEvent.fromFirestore(doc);
    }).toList();
  }

  Future<EventModel?> getEventByEventType(String eventType) async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('eventType', isEqualTo: eventType)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print("No event found for the given eventType.");
        return null;
      }

      final doc = querySnapshot.docs.first; // Get the first document
      return EventModel.fromMap(doc.data() as Map<String, dynamic>);
    } catch (e) {
      print("Error fetching event: $e");
      return null;
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      final DocumentReference eventDoc =
      FirebaseFirestore.instance.collection('events').doc(eventId);

      await eventDoc.delete();
      print("Event deleted successfully!");
    } catch (e) {
      print("Error deleting event: $e");
    }
  }

  Future<void> registerUserForEvent(String userId, EventModel eventData) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Prepare data to be stored
    final registeredEventData = {
      'userId': userId,
      'eventDate': eventData.eventDetails,
      'eventType': eventData.eventType,
      'registrationDate': DateTime.now(),
    };

    try {
      // Check if the user is already registered for the event
      final querySnapshot = await firestore
          .collection('registeredEvents')
          .where('userId', isEqualTo: userId)
          .where('eventDate', isEqualTo: eventData.eventDetails)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // User is already registered
        Get.snackbar("Notice", "You are already registered for this event.");
        return;
      }

      // Add data to Firestore collection
      await firestore.collection('registeredEvents').add(registeredEventData);
      Get.snackbar("Success", "Successfully registered for ${eventData.eventType}");
      Get.toNamed('/registerSuccess');
    } on FirebaseException catch (e) {
      Get.snackbar("Error", "Error registering: $e");
    }
  }

  Future<List<UserModel>> getUsersForEvent(String eventType, String eventDate) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Step 1: Fetch all registrations for the event
      final querySnapshot = await firestore
          .collection('registeredEvents')
          .where('eventType', isEqualTo: eventType)
          .where('eventDate', isEqualTo: eventDate)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return []; // No users registered for this event
      }

      // Step 2: Fetch user details for each registered user
      final List<Future<UserModel>> userFutures = querySnapshot.docs.map((doc) async {
        final userId = doc['userId'] as String;
        return await getUserDetailsById(userId); // Fetch user details using a helper function
      }).toList();

      // Step 3: Wait for all user details to be fetched
      final users = await Future.wait(userFutures);
      return users; // Return the list of UserModel
    } catch (e) {
      throw Exception("Failed to fetch users for event: ${e.toString()}");
    }
  }

// Helper function to fetch user details by ID
  Future<UserModel> getUserDetailsById(String userId) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      final doc = await firestore.collection('users').doc(userId).get();

      if (!doc.exists) {
        throw Exception("User not found");
      }

      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw Exception("Failed to fetch user details: ${e.toString()}");
    }
  }


}
