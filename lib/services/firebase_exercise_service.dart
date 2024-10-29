import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/exercise.dart';

class FirebaseExerciseService {

  Future<List<Exercise>> fetchExerciseList(String moduleId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('modules')
          .doc(moduleId)
          .collection('exercises')
          .get();

      return querySnapshot.docs.map((document) {
        return Exercise(
          id: document.id,
          timeStamp: (document.get('timestamp') as Timestamp).toDate(),
          content: document.get('content'),
          title: document.get('title'),
        );
      }).toList();
    } catch (e) {
      print("Error fetching exercises: $e");
      return [];
    }
  }
}
