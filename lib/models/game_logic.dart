import 'dart:typed_data';
import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import 'note.dart';
import 'note_recognition.dart';

class GameLogic {
  final FlutterAudioCapture _audioCapture = FlutterAudioCapture();
  final NoteRecognition _noteRecognition = NoteRecognition();
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<Note> notes = [];
  String detectedNote = "-";
  bool _listening = false;
  int score = 0;
  int round = 0;
  double? _lastFreq;
  int wrongAttempts = 0;
  int _lastAttemptMs = 0;
  final int attemptCooldownMs = 800;

  final int sampleRate;
  final int bufferSize;
  final int targetScore;
  final List<String> allowedStrings;

  GameLogic({
    this.sampleRate = 44100,
    this.bufferSize = 4096,
    this.targetScore = 10,
    List<String>? allowedStrings,
  }) : allowedStrings = allowedStrings ?? Note.strings;

  bool get isListening => _listening;

  Function()? onUpdate;
  Function()? onError;
  Function()? onGameEnd;

  Future<void> startGame() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) return;
    if (_listening) return;

    final ok = await _audioCapture.init();
    if (ok != true) return;

    notes = [Note.random(allowedStrings: allowedStrings)];
    score = 0;
    round = 1;
    _lastFreq = null;
    wrongAttempts = 0;
    _lastAttemptMs = 0;

    await _audioCapture.start(
      _audioCallback,
          (Object e, StackTrace s) => onError?.call(),
      sampleRate: sampleRate,
      bufferSize: bufferSize,
    );

    _listening = true;
    onUpdate?.call();
  }

  void _audioCallback(Float32List floatData) {
    if (floatData.length < 2048) return;

    final amplitude = floatData.map((e) => e.abs()).reduce((a, b) => a > b ? a : b);
    if (amplitude < 0.05) return;

    final f = _noteRecognition.detectPitch(floatData);
    if (f <= 0) return;

    if ((_lastFreq != null) && (f - _lastFreq!).abs() < 0.5) return;
    _lastFreq = f;

    final mapping = _noteRecognition.freqToNote(f);
    final nameWithOctave = mapping['name'] as String;
    final cents = mapping['cents'] as double;
    final detectedNoteLetter = nameWithOctave.replaceAll(RegExp(r'\d'), '');

    detectedNote = nameWithOctave;

    if (notes.isNotEmpty &&
        detectedNoteLetter == notes.last.noteName &&
        cents.abs() < 20) {
      _playSound("correct.mp3");
      score += 1;
      wrongAttempts = 0;
      _lastAttemptMs = 0;
      if (round >= targetScore) {
        stopGame();
        onGameEnd?.call();
        return;
      }
      round += 1;
      notes = [Note.random(allowedStrings: allowedStrings)];
    } else {
      _playSound("wrong.mp3");
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - _lastAttemptMs >= attemptCooldownMs) {
        wrongAttempts += 1;
        _lastAttemptMs = now;
        if (wrongAttempts >= 3) {
          if (round >= targetScore) {
            stopGame();
            onGameEnd?.call();
            return;
          }
          round += 1;
          notes = [Note.random(allowedStrings: allowedStrings)];
          wrongAttempts = 0;
          _lastAttemptMs = 0;
        }
      }
    }

    onUpdate?.call();
  }

  Future<void> _playSound(String fileName) async {
    try {
      await _audioPlayer.play(AssetSource("sounds/$fileName"));
    } catch (e) {
    }
  }

  Future<void> stopGame() async {
    if (!_listening) return;
    await _audioCapture.stop();
    _listening = false;
    detectedNote = "-";
    _lastFreq = null;
    onUpdate?.call();
  }

  bool _pausedForTts = false;
  Future<void> pauseForTts(bool pause) async {
    if (pause == _pausedForTts) return;
    _pausedForTts = pause;

    if (pause) {
      await _audioCapture.stop();
    } else {
      await _audioCapture.start(
        _audioCallback,
            (Object e, StackTrace s) => onError?.call(),
        sampleRate: sampleRate,
        bufferSize: bufferSize,
      );
    }
  }

  void dispose() {
    stopGame();
    _audioPlayer.dispose();
  }

  void resetGame() {
    score = 0;
    round = 0;
    notes.clear();
    detectedNote = "-";
    _listening = false;
  }
}
