import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';

class ScoreStore extends ChangeNotifier {
  static final log = Logger('ScoreStore');

  // Private constructor
  ScoreStore._();

  // Singleton instance
  static final ScoreStore _instance = ScoreStore._();

  // Factory constructor to return the singleton instance
  factory ScoreStore() => _instance;

  static const secureStorage = FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      )
  );

  //-------------------------- Secure Storage Operations ----------------------//

  //Get total score of a given chapter
  Future<int> getChapterScore(String key) async {
    final answers = await getChapterAnswers(key);
    int totalScore = 0;

    answers.forEach((questionId, indexPointMap) {
      indexPointMap.forEach((index, points) {
        totalScore += points;
      });
    });

    return totalScore;
  }

  // Save all answers as Map of Question ID -> Map of {selectedIndex -> answerPoints}
  Future<void> setChapterAnswers(String key, Map<String, Map<int, int>> answers) async {
    final Map<String, Map<String, dynamic>> jsonCompatibleMap = answers.map((questionId, indexPointMap) {

      final stringKeyMap = indexPointMap.map((index, points) => MapEntry(index.toString(), points));
      return MapEntry(questionId, stringKeyMap);
    });

    final String value = jsonEncode(jsonCompatibleMap);
    await secureStorage.write(key: key, value: value);
    log.info("Setting Key: $key, Answers with Points: $answers");
  }

  // Get all answers as Map of Question ID -> Map of {selectedIndex: answerPoints}
  Future<Map<String, Map<int, int>>> getChapterAnswers(String key) async {
    final String? jsonString = await secureStorage.read(key: key);

    if (jsonString == null) {
      log.info('No saved answers found for key "$key".');
      return {};
    }

    try {
      final Map<String, dynamic> decodedMap = jsonDecode(jsonString);

      final Map<String, Map<int, int>> answers = decodedMap.map((questionId, innerMap) {
        final Map<int, int> indexPointMap = (innerMap as Map<String, dynamic>).map((indexStr, points) {
          return MapEntry(int.parse(indexStr), points as int);
        });
        return MapEntry(questionId, indexPointMap);
      });

      log.info("Getting Key: $key, Answers with Points: $answers");
      return answers;
    } catch (e) {
      log.severe('Failed to parse answers for key "$key". Error: $e');
      await secureStorage.delete(key: key);
      return {};
    }
  }
}