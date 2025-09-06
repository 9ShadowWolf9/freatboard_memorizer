import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:permission_handler/permission_handler.dart';
import 'note.dart';
import 'note_recognition.dart';

class GameLogic {
  final FlutterAudioCapture _audioCapture = FlutterAudioCapture();
  final NoteRecognition _noteRecognition = NoteRecognition();

  List<Note> notes = [];
  String detectedNote = "-";
  bool _listening = false;
  int score = 0;
  double? _lastFreq;

  final int sampleRate;
  final int bufferSize;

  GameLogic({this.sampleRate = 44100, this.bufferSize = 4096});

  bool get isListening => _listening;

  Function()? onUpdate;
  Function()? onError;

  /// Start the game and audio capture
  Future<void> startGame() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) return;
    if (_listening) return;

    final ok = await _audioCapture.init();
    if (ok != true) return;

    notes = [Note.random()];
    score = 0;
    _lastFreq = null;

    await _audioCapture.start(_audioCallback,
            (Object e, StackTrace s) => onError?.call(),
        sampleRate: sampleRate, bufferSize: bufferSize);

    _listening = true;
    onUpdate?.call();
  }

  /// Audio processing callback
  void _audioCallback(Float32List floatData) {
    if (floatData.length < 2048) return;

    final amplitude =
    floatData.map((e) => e.abs()).reduce((a, b) => a > b ? a : b);
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
        cents.abs() < 10) {
      notes = [Note.random()];
      score += 1;
    }

    onUpdate?.call();
  }

  /// Stop the game and audio capture
  Future<void> stopGame() async {
    if (!_listening) return;
    await _audioCapture.stop();
    _listening = false;
    detectedNote = "-";
    _lastFreq = null;
    onUpdate?.call();
  }

  /// Pause/un-pause recorder while TTS speaks
  bool _pausedForTts = false;

  Future<void> pauseForTts(bool pause) async {
    if (pause == _pausedForTts) return;
    _pausedForTts = pause;

    if (pause) {
      await _audioCapture.stop();
    } else {
      await _audioCapture.start(_audioCallback,
              (Object e, StackTrace s) => onError?.call(),
          sampleRate: sampleRate,
          bufferSize: bufferSize);
    }
  }

  void dispose() {
    stopGame();
  }
}