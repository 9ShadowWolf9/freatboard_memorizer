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
    return Scaffold(
      appBar: AppBar(title: const Text("Guitar Note Game")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Play the Note!', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _gameLogic.isListening ? _gameLogic.stopGame : _gameLogic.startGame,
              child: Text(_gameLogic.isListening ? 'Stop' : 'Start'),
            ),
            const SizedBox(height: 20),
            if (_gameLogic.notes.isNotEmpty)
              Text(
                "Target: ${_gameLogic.notes.last}",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 20),
            Text(
              "You played: ${_gameLogic.detectedNote}",
              style: const TextStyle(fontSize: 20, color: Colors.blue),
            ),
            const SizedBox(height: 20),
            Text(
              "Score: ${_gameLogic.score}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
