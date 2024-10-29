
String convertIdToName(String input) {
  // Split the string by underscore
  List<String> parts = input.split('_');

  // Capitalize the first letter of the first word
  String formatted = parts[0][0].toUpperCase() + parts[0].substring(1);

  // Add the rest of the parts separated by spaces
  for (int i = 1; i < parts.length; i++) {
    formatted += ' ' + parts[i];
  }

  return formatted;
}
