import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

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
          exerciseId: document.id,
          timeStamp: (document.get('timestamp') as Timestamp).toDate(),
          url: document.get('url'),
          title: document.get('title'),
          progress: 0.0 //TODO: Need to Get Later
        );
      }).toList();
    } catch (e) {
      print("Error fetching exercises: $e");
      return [];
    }
  }

  Future<String> fetchExerciseFile(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return utf8.decode(response.bodyBytes, allowMalformed: true);
      } else {
        throw Exception("Failed to load markdown content");
      }
    } catch (e) {
      print("Error fetching markdown content: $e");
    }

    return "";
  }
}
