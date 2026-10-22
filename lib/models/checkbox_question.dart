import 'checkbox_answer.dart';

class CheckboxQuestion {
  final String id;
  final String question;
  final List<CheckBoxAnswer> answers;
  Set<int> selectedAnswers; // Selected Answers Indexes
  final bool multiple;

  CheckboxQuestion({
    required this.id,
    required this.question,
    required this.answers,
    Set<int>? selectedAnswers,
    required this.multiple,
  }) : selectedAnswers = selectedAnswers ?? <int>{};

  int get score {
    if (selectedAnswers.isEmpty) {
      return 0;
    }

    int currentScore = 0;
    for (int index in selectedAnswers) {
      // Safety check to prevent range errors
      if (index >= 0 && index < answers.length) {
        currentScore += answers[index].points;
      }
    }
    return currentScore;
  }

  // Handle selection toggling cleanly inside the model
  void toggleSelection(int index, bool isChecked) {
    if (multiple) {
      if (isChecked) {
        selectedAnswers.add(index);
      } else {
        selectedAnswers.remove(index);
      }
    } else {
      selectedAnswers.clear();
      if (isChecked) {
        selectedAnswers.add(index);
      }
    }
  }

  factory CheckboxQuestion.fromJson(Map<String, dynamic> json) {
    final rawAnswers = json['Answers'];
    final List<CheckBoxAnswer> parsedAnswers = [];

    if (rawAnswers is List) {
      parsedAnswers.addAll(rawAnswers.map((e) => CheckBoxAnswer.fromJson(e as Map<String, dynamic>)));
    }

    return CheckboxQuestion(
      id: json['Id'] as String? ?? '',
      question: json['Question'] as String? ?? '',
      answers: parsedAnswers,
      multiple: json['Multiple'] as bool? ?? false,
    );
  }
}