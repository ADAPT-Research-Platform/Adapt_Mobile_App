import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/mode.dart';
import '../models/user.dart';
import 'firebase_auth_service.dart';

class FirebaseModeService {
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();

  Future<void> saveMode(int feeling, int motivation) async {
    try {
      User user = await _firebaseAuthService.getLoggedInUser();

      // Reference to the "mode_track" collection within the user's document
      CollectionReference modeTrackCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(user.userId)
          .collection('mode_track');

      // Generate a unique modeId and timestamp
      String modeId = modeTrackCollection.doc().id;

      // Data to be saved
      Map<String, dynamic> modeData = {
        'timestamp': DateTime.now(), // Store as ISO 8601 string
        'feeling': feeling,
        'motivation': motivation,
      };

      // Add the mode document to Firestore
      await modeTrackCollection.doc(modeId).set(modeData);
      print('Mode saved successfully. Feeling: ${feeling} Motivation: ${motivation}');
    } catch (e) {
      print('Failed to save mode: $e');
    }
  }

  Future<List<Mode>> fetchModeList() async {
    try {
      User user = await _firebaseAuthService.getLoggedInUser();

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.userId)
          .collection('mode_track')
          .orderBy('timestamp')
          .get();

      return querySnapshot.docs.map((document) {
        return Mode(
            modeId: document.id,
            timeStamp: (document.get('timestamp') as Timestamp).toDate(),
            feeling: document.get('feeling'),
            motivation: document.get('motivation')
        );
      }).toList();
    } catch (e) {
      print("Error fetching exercises: $e");
      return [];
    }
  }
}
