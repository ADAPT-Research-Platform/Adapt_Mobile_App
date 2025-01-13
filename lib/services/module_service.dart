import 'dart:convert';

import 'package:adapt/services/session_manager.dart';

import '../models/chapter.dart';
import '../models/module.dart';
import '../models/section.dart';
import '../utils/app_config.dart';

class ModuleService {
  Future<List<Module>> fetchModuleList() async {
    const url = '${AppConfig.baseUrl}/api/modules';

    try {
      final response = await SessionManager().client.get(
        Uri.parse(url),
        headers: SessionManager().getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => parseModule(json)).toList();
      } else {
        print("Failed to fetch modules: ${response.statusCode}, ${response.body}");
        throw Exception("Failed to fetch module list");
      }
    } catch (e) {
      print("Error fetching module list: $e");
      return [];
    }
  }

  Module parseModule(Map<String, dynamic> json) {
    return Module(
      moduleId: json['id'].toString(),
      progress: (json['progress'] as num).toDouble(),
      chapters: (json['chapters'] as List<dynamic>)
          .map((chapterJson) => parseChapter(chapterJson))
          .toList(),
    );
  }

  Chapter parseChapter(Map<String, dynamic> json) {
    return Chapter(
      chapterId: json['id'].toString(),
      title: json['title'] ?? '',
      progress: (json['progress'] as num).toDouble(),
      sections: (json['sections'] as List<dynamic>)
          .map((sectionJson) => parseSection(sectionJson))
          .toList(),
    );
  }

  Section parseSection(Map<String, dynamic> json) {
    return Section(
      sectionId: json['id'].toString(),
      timeStamp: DateTime.parse(json['updatedAt']),
      folderPath: json['folderUrl'] ?? '',
      title: json['title'] ?? '',
      isExercise: json['isExercise'] ?? false,
    );
  }
}
