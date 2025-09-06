// screens/game_page.dart
import 'package:flutter/material.dart';
import '../models/game_logic.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late GameLogic _gameLogic;

  @override
  void initState() {
    super.initState();
    _gameLogic = GameLogic();
    _gameLogic.onUpdate = () => setState(() {});
    _gameLogic.onError = () => debugPrint("Audio capture error");
  }

  @override
  void dispose() {
    _gameLogic.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final targetNote = _gameLogic.notes.isNotEmpty ? _gameLogic.notes.last : null;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Score bar at the top
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  const Text(
                    "Score",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (_gameLogic.score.clamp(0, 10)) / 10,
                      minHeight: 20,
                      backgroundColor: Colors.grey[300],
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "${_gameLogic.score}/10",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Big target note in the center
            if (targetNote != null)
              Column(
                children: [
                  Text(
                    targetNote.noteName,
                    style: const TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    targetNote.stringName, // e.g., "4th string"
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),

            const Spacer(),

            // Detected note smaller at the bottom
            Text(
              "You played: ${_gameLogic.detectedNote}",
              style: const TextStyle(fontSize: 24, color: Colors.blue),
            ),

            const SizedBox(height: 40),

            // Start/Stop button
            ElevatedButton(
              onPressed: _gameLogic.isListening
                  ? _gameLogic.stopGame
                  : _gameLogic.startGame,
              style: ElevatedButton.styleFrom(
                padding:
                const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                textStyle:
                const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              child: Text(_gameLogic.isListening ? 'Stop' : 'Start'),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
