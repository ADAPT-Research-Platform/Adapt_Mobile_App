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

  Future<void> setChapterScore(String key, int value) async {
    await secureStorage.write(key: key, value: value.toString());
    log.info("Setting Key: $key, Score: $value");
  }

  Future<int> getChapterScore(String key) async {
    final value = await secureStorage.read(key: key);
    int score = int.tryParse(value ?? '') ?? 0;

    log.info("Getting Key: $key, Answers: $score");
    return score;
  }

  Future<void> setChapterAnswers(String key, Map<String, Set<int>> answers) async {
    final Map<String, List<int>> jsonCompatibleMap = answers.map((questionId, indexSet) {
      return MapEntry(questionId, indexSet.toList());
    });

    final String value = jsonEncode(jsonCompatibleMap);

    await secureStorage.write(key: key, value: value);
    log.info("Setting Key: $key, Answers: $answers");
  }

  Future<Map<String, Set<int>>> getChapterAnswers(String key) async {
    final String? jsonString = await secureStorage.read(key: key);

    if (jsonString == null) {
      log.info('No saved answers found for key "$key".');
      return {};
    }

    try {
      final Map<String, dynamic> decodedMap = jsonDecode(jsonString);

      final Map<String, Set<int>> answers = decodedMap.map((questionId, indexList) {
        final List<int> intList = (indexList as List).cast<int>();
        return MapEntry(questionId, intList.toSet());
      });

      log.info("Getting Key: $key, Answers: $answers");

      return answers;
    } catch (e) {
      log.severe('Failed to parse answers for key "$key". Error: $e');
      await secureStorage.delete(key: key);
      return {};
    }
  }
}