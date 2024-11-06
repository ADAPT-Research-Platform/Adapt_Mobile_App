import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/mode.dart';

class FirebaseModeService {

  Future<void> saveMode(String userId, int feeling, int motivation) async {
    try {
      // Reference to the "mode_track" collection within the user's document
      CollectionReference modeTrackCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
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
      print('Mode saved successfully.');
    } catch (e) {
      print('Failed to save mode: $e');
    }
  }

  Future<List<Mode>> fetchModeList(String userId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('mode_track')
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
