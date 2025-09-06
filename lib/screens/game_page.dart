import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/note.dart';
import '../models/note_recognition.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final FlutterAudioCapture _audioCapture = FlutterAudioCapture();
  final NoteRecognition _noteRecognition = NoteRecognition();

  List<Note> notes = [];
  String detectedNote = "-";
  bool _listening = false;
  int score = 0;

  double? _lastFreq;

  final int sampleRate = 44100;
  final int bufferSize = 4096;

  /// Start the game and audio capture
  Future<void> startGame() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) return;

    if (_listening) return;

    final ok = await _audioCapture.init();
    if (ok != true) return;

    // First target note
    setState(() {
      notes = [Note.random()];
      score = 0;
      _lastFreq = null;
    });

    await _audioCapture.start(
          (Float32List floatData) {
        if (floatData.length < 2048) return;

        // Ignore quiet signals
        final amplitude = floatData.map((e) => e.abs()).reduce(max);
        if (amplitude < 0.05) return;

        final f = _noteRecognition.detectPitch(floatData);
        if (f <= 0) return;

        // Only process if frequency changed significantly
        if ((_lastFreq != null) && (f - _lastFreq!).abs() < 0.5) return;
        _lastFreq = f;

        final mapping = _noteRecognition.freqToNote(f);
        final nameWithOctave = mapping['name'] as String;
        final cents = mapping['cents'] as double;
        final detectedNoteLetter = nameWithOctave.replaceAll(RegExp(r'\d'), '');

        setState(() {
          detectedNote = nameWithOctave;
        });

        // Only accept correct note if within cents tolerance
        if (notes.isNotEmpty &&
            detectedNoteLetter == notes.last.noteName &&
            cents.abs() < 10) {
          setState(() {
            notes = [Note.random()];
            score += 1;
          });
        }
      },
          (Object e, StackTrace s) => debugPrint("Audio error: $e"),
      sampleRate: sampleRate,
      bufferSize: bufferSize,
    );

    setState(() {
      _listening = true;
    });
  }

  /// Stop the game and audio capture
  Future<void> stopGame() async {
    if (!_listening) return;
    await _audioCapture.stop();
    setState(() {
      _listening = false;
      detectedNote = "-";
      _lastFreq = null;
    });
  }

  @override
  void dispose() {
    stopGame();
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
              onPressed: _listening ? stopGame : startGame,
              child: Text(_listening ? 'Stop' : 'Start'),
            ),
            const SizedBox(height: 20),
            if (notes.isNotEmpty)
              Text(
                "Target: ${notes.last}",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 20),
            Text(
              "You played: $detectedNote",
              style: const TextStyle(fontSize: 20, color: Colors.blue),
            ),
            const SizedBox(height: 20),
            Text(
              "Score: $score",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
