import 'dart:convert';

import 'package:adapt/services/session_manager.dart';

import '../models/chapter.dart';
import '../models/module.dart';
import '../models/section.dart';
import '../utils/app_config.dart';
import 'auth_service.dart';

class ModuleService {
  final AuthService _authService = AuthService();

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
        _authService.logout();
        throw Exception("Failed to fetch module list");
      }
    } catch (e) {
      print("Error fetching module list: $e");
      return [];
    }
  }

  Module parseModule(Map<String, dynamic> json) {
    List<Chapter> chapters = (json['chapters'] as List<dynamic>)
        .map((chapterJson) => parseChapter(chapterJson))
        .toList();

    // Calculate the average progress of the module based on its chapters' progress
    double moduleProgress = 0.0;
    if (chapters.isNotEmpty) {
      moduleProgress = chapters.fold(0.0, (sum, chapter) => sum + chapter.progress) / chapters.length;
    }

    return Module(
      moduleId: json['id'].toString(),
      progress: moduleProgress,
      chapters: chapters,
    );
  }

  Chapter parseChapter(Map<String, dynamic> json) {
    List<Section> sections = (json['sections'] as List<dynamic>)
        .map((sectionJson) => parseSection(sectionJson))
        .toList();

    // Calculate the average progress of the chapter based on its sections' progress
    double chapterProgress = 0.0;
    if (sections.isNotEmpty) {
      chapterProgress = sections.fold(0.0, (sum, section) => sum + section.progress) / sections.length;
    }

    return Chapter(
      chapterId: json['id'].toString(),
      title: json['title'] ?? '',
      progress: chapterProgress,
      sections: sections,
    );
  }

  Section parseSection(Map<String, dynamic> json) {
    return Section(
      sectionId: json['id'].toString(),
      timeStamp: DateTime.parse(json['updatedAt']),
      folderPath: json['folderUrl'] ?? '',
      title: json['title'] ?? '',
      progress: (json['progress'] as num).toDouble(),
      isExercise: json['isExercise'] ?? false,
    );
  }
}
