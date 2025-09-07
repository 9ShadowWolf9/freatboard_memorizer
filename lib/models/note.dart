import 'dart:math';

class Note {
  final String stringName;
  final String noteName;

  Note({
    required this.stringName,
    required this.noteName,
  });

  @override
  String toString() => '$stringName string $noteName';

  // Guitar string names
  static const List<String> strings = [
    '1st',
    '2nd',
    '3rd',
    '4th',
    '5th',
    '6th',
  ];

  // Musical notes
  static const List<String> notes = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
  ];

  /// Picks a random note safely.
  /// Falls back to "?" if no valid strings/notes exist.
  static Note random({List<String>? allowedStrings}) {
    final rand = Random();

    // Use provided list if not empty, otherwise fallback to default strings
    final stringList = (allowedStrings != null && allowedStrings.isNotEmpty)
        ? allowedStrings
        : strings;

    // If no valid strings or notes → fallback note
    if (stringList.isEmpty || notes.isEmpty) {
      return Note(stringName: "?", noteName: "?");
    }

    final string = stringList[rand.nextInt(stringList.length)];
    final note = notes[rand.nextInt(notes.length)];

    return Note(
      stringName: string,
      noteName: note,
    );
  }
}
