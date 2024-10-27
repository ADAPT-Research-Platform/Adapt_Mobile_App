import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseModuleService{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> getModuleById(String documentId) async {
    try {
      // Access the document by ID
      DocumentSnapshot document = await _firestore
          .collection('modules')
          .doc(documentId)
          .get();

      if (document.exists) {
        // Successfully retrieved the document
        print('Module data: ${document.data()}');
      } else {
        print('No Module found with ID: $documentId');
      }
    } catch (e) {
      print('Error fetching Module: $e');
    }
  }

  Future<int> getModuleCount() async {
    try {
      // Access the root-level 'users' collection
      AggregateQuery countQuery = _firestore.collection('modules').count();

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