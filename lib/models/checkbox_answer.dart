class CheckBoxAnswer {
  final String text;
  final int points;

  CheckBoxAnswer({
    required this.text,
    required this.points
  });

  factory CheckBoxAnswer.fromJson(Map<String, dynamic> json) {
    return CheckBoxAnswer(
      text: json['text'] as String? ?? '',
      points: json['points'] as int? ?? 0,
    );
  }
}