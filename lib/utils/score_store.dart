import 'package:flutter/cupertino.dart';

class ScoreStore extends ChangeNotifier {
  // Private constructor
  ScoreStore._();

  // Singleton instance
  static final ScoreStore _instance = ScoreStore._();

  // Factory constructor to return the singleton instance
  factory ScoreStore() => _instance;

  final Map<String, int> _scores = {};

  int? getScore(String key) => _scores[key];

  void setScore(String key, int value) {
    _scores[key] = value;
    notifyListeners();
  }

  void reset() => _scores.clear();
}
