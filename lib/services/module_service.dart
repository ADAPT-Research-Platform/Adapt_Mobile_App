import 'dart:convert';

import 'package:adapt/services/session_manager.dart';

import '../models/chapter.dart';
import '../models/module.dart';
import '../models/section.dart';
import '../utils/app_config.dart';
import 'auth_service.dart';

class ModuleService {
  final AuthService _authService = AuthService();

  Future<List<String>> fetchModuleIdList() async {
    try {
      final response = await SessionManager().client.get(
        Uri.parse('${AppConfig.baseUrl}/api/modules/ids'),
        headers: SessionManager().getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map<String>((item) => item).toList();
      } else {
        print("Failed to fetch module id list: ${response.statusCode}, ${response.body}");
        _authService.logout();
        throw Exception("Failed to fetch module id list");
      }
    } catch (e) {
      print("Error fetching module id list: $e");
      return [];
    }
  }

  Future<Module> fetchModuleById(String moduleId) async {
    // Add query parameters
    final Map<String, String> queryParams = {};
    queryParams['moduleId'] = moduleId;

    try {
      final response = await SessionManager().client.get(
        Uri.parse('${AppConfig.baseUrl}/api/modules').replace(queryParameters: queryParams),
        headers: SessionManager().getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return parseModule(data);
      } else {
        print("Failed to fetch module: ${response.statusCode}, ${response.body}");
        _authService.logout();
        throw Exception("Failed to fetch module");
      }
    } catch (e) {
      print("Error fetching module: $e");
      rethrow;
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
    int chapterNumOfComments = 0;
    if (sections.isNotEmpty) {
      chapterProgress = sections.fold(0.0, (sum, section) => sum + section.progress) / sections.length;
      chapterNumOfComments = sections.fold(0, (sum, section) => sum + section.numOfComments);
    }

    return Chapter(
      chapterId: json['id'].toString(),
      title: json['title'] ?? '',
      progress: chapterProgress,
      numOfComments: chapterNumOfComments,
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
      numOfComments: (json['numOfComments'] as num).toInt(),
      isExercise: json['isExercise'] ?? false,
    );
  }
}
