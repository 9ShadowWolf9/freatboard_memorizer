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

  static const List<String> strings = ['1st', '2nd', '3rd', '4th', '5th', '6th'];
  static const List<String> notes = ['A', 'B', 'C', 'D', 'E', 'F', 'G'];

  static Note random({List<String>? allowedStrings}) {
    final rand = Random();
    final stringList = allowedStrings ?? strings;
    final string = stringList[rand.nextInt(stringList.length)];
    final note = notes[rand.nextInt(notes.length)];
    return Note(stringName: string, noteName: note);
  }
}
