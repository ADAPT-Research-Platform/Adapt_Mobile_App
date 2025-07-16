
class CheckboxQuestion {
  final String id;
  final String question;
  final List<String> answers;
  final List<int> correctIndices;
  final bool multiple; // True if multiple answers can be selected

  CheckboxQuestion({
    required this.id,
    required this.question,
    required this.answers,
    required this.correctIndices,
    required this.multiple,
  });

  factory CheckboxQuestion.fromJson(Map<String, dynamic> json) {
    return CheckboxQuestion(
      id: json['Id'] as String,
      question: json['Question'] as String,
      answers: List<String>.from(json['Answers'] as List),
      correctIndices: List<int>.from(json['Correct'] as List),
      multiple: json['Multiple'] as bool,
    );
  }
}