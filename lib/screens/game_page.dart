import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/game_logic.dart';
import '../screens/game_end.dart';
import '../components/score_bar.dart';

class GamePage extends StatefulWidget {
  final int targetScore;
  final List<String>? selectedStrings;

  const GamePage({super.key, this.targetScore = 10, this.selectedStrings});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late GameLogic _gameLogic;
  final FlutterTts _tts = FlutterTts();
  String? _lastSpokenNote;

  @override
  void initState() {
    super.initState();

    _gameLogic = GameLogic(
      targetScore: widget.targetScore,
      allowedStrings: widget.selectedStrings ?? [],
    );

    _gameLogic.onUpdate = () async {
      if (!mounted) return;
      setState(() {});

      final targetNote =
      _gameLogic.notes.isNotEmpty ? _gameLogic.notes.last : null;

      if (targetNote != null &&
          _lastSpokenNote != "${targetNote.stringName}${targetNote.noteName}") {
        _lastSpokenNote = "${targetNote.stringName}${targetNote.noteName}";
        await _tts.speak(
            "${targetNote.stringName} string ${targetNote.noteName}");
      }
    };

    _gameLogic.onError = () => debugPrint("Audio capture error");

    _gameLogic.onGameEnd = () async {
      await _tts.stop();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => EndGamePage(
            finalScore: _gameLogic.score,
            maxScore: widget.targetScore,
          ),
        ),
      );
    };

    _tts.setLanguage("en-US");
    _tts.setPitch(1.0);
    _tts.setSpeechRate(0.5);
    _tts.setVoice({"name": "en-us-x-sfg#male_1-local", "locale": "en-US"});

    _tts.setStartHandler(() => _gameLogic.pauseForTts(true));
    _tts.setCompletionHandler(() => _gameLogic.pauseForTts(false));
    _tts.setCancelHandler(() => _gameLogic.pauseForTts(false));
  }

  @override
  void dispose() {
    _gameLogic.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final targetNote =
    _gameLogic.notes.isNotEmpty ? _gameLogic.notes.last : null;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            ScoreBar(score: _gameLogic.round, maxScore: widget.targetScore),
            const Spacer(),
            if (targetNote != null)
              Column(
                children: [
                  Text(
                    targetNote.noteName,
                    style: TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      color: accent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    targetNote.stringName,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      final active = i < _gameLogic.wrongAttempts;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: active
                                ? accent
                                : theme.colorScheme.surfaceVariant,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            const Spacer(),
            Text(
              "You played: ${_gameLogic.detectedNote}",
              style: TextStyle(fontSize: 24, color: accent),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _gameLogic.isListening
                  ? _gameLogic.stopGame
                  : _gameLogic.startGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
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
