class CheckBoxAnswer {
  final String text;
  final int points;

  CheckBoxAnswer({required this.text, required this.points});

  factory CheckBoxAnswer.fromJson(Map<String, dynamic> json) {
    return CheckBoxAnswer(
      text: json['text'] as String? ?? '',
      points: json['points'] as int? ?? 0,
    );
  }
}

class CheckboxQuestion {
  final String id;
  final String question;
  final List<CheckBoxAnswer> answers;  // <-- change here
  final List<int> correctIndices;
  final bool multiple;

  CheckboxQuestion({
    required this.id,
    required this.question,
    required this.answers,
    required this.correctIndices,
    required this.multiple,
  });

  factory CheckboxQuestion.fromJson(Map<String, dynamic> json) {
    return CheckboxQuestion(
      id: json['Id'] as String? ?? '',
      question: json['Question'] as String? ?? '',
      answers: (json['Answers'] as List<dynamic>?)
          ?.map((e) => CheckBoxAnswer.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      correctIndices: (json['Correct'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList() ??
          [],
      multiple: json['Multiple'] as bool? ?? false,
    );
  }
}
