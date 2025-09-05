import 'package:flutter/material.dart';
import '../models/note.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  List<Note> notes = [];

  void startGame() {
    // Generate 10 random notes
    setState(() {
      notes = List.generate(1, (_) => Note.random());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Start the Game',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: startGame,
              child: const Text('Start'),
            ),
            const SizedBox(height: 20),
            // Show the generated notes
            ...notes.map((n) => Text(n.toString(), style: const TextStyle(fontSize: 18))),
          ],
        ),
      ),
    );
  }
}
