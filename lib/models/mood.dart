
class Mood {
  final DateTime timeStamp;
  final int feeling;
  final int motivation;

  Mood({
    required this.timeStamp,
    required this.feeling,
    required this.motivation
  });

  factory Mood.parse(String data) {
    // Split the string using the '|' delimiter
    final parts = data.split('|');

    // Parse the components
    final timeStamp = DateTime.parse(parts[0]); // Parse the timestamp
    final feeling = int.parse(parts[1]); // Parse the feeling
    final motivation = int.parse(parts[2]); // Parse the motivation

    return Mood(
      timeStamp: timeStamp,
      feeling: feeling,
      motivation: motivation,
    );
  }
}
