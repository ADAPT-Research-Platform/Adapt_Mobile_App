import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/exercise.dart';
import '../models/module.dart';
import 'firebase_exercise_service.dart';

class FirebaseModuleService {
  final FirebaseExerciseService _firebaseExerciseService = FirebaseExerciseService();

  Future<Module?> getModuleById(String moduleId) async {
    try {
      // Access the document by ID
      DocumentSnapshot document = await FirebaseFirestore.instance
          .collection('modules')
          .doc(moduleId)
          .get();

      if (document.exists) {
        return Module(
          moduleId: document.id,
          title: document.get('title'),
          exercises: await _firebaseExerciseService.fetchExerciseList(document.id),
        );
      } else {
        print('No Module found with ID: $moduleId');
      }
    } catch (e) {
      print('Error fetching Module: $e');
    }
    return null;
  }

  Future<List<Module>> fetchModuleList() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('modules')
          .get();

      // Use Future.wait to handle multiple asynchronous fetches
      return await Future.wait(querySnapshot.docs.map((document) async {
        // Call your async function to fetch exercises for each module document
        List<Exercise> exercises = await _firebaseExerciseService.fetchExerciseList(document.id);

        return Module(
          moduleId: document.id,
          title: document.get('title'),
          exercises: exercises, // Set exercises fetched from Firestore
        );
      }).toList());
    } catch (e) {
      print("Error fetching exercises: $e");
    }

    return [];
  }

  Future<int> getModuleCount() async {
    try {
      // Access the root-level 'users' collection
      AggregateQuery countQuery = FirebaseFirestore.instance
          .collection('modules')
          .count();

      // Get the count
      AggregateQuerySnapshot countSnapshot = await countQuery.get();
      int count = countSnapshot.count ?? 0;

      print("Module count using aggregation: $count");
      return count;
    } catch (e) {
      print("Error getting Module count: $e");
      return 0;
    }
  }
}
