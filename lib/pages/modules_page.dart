import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ModuleDetailPage extends StatelessWidget {
  final String moduleId;

  ModuleDetailPage({required this.moduleId});

  Future<Map<String, dynamic>?> fetchModuleDetails() async {
    final DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
        .instance
        .collection('modules')
        .doc(moduleId)
        .get();
    return doc.data();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Module Details"),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchModuleDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading module details"));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text("Module not found"));
          }

          final module = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Title: ${module['title']}",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text("Total Exercises: ${module['num_of_exes']}"),
                SizedBox(height: 16),
                Text(
                  "Published Date: ${module['date'].toDate()}",
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
