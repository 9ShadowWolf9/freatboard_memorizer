import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/note_recognition.dart';

class TunerPage extends StatefulWidget {
  const TunerPage({super.key});

  @override
  State<TunerPage> createState() => _TunerPageState();
}

class _TunerPageState extends State<TunerPage> {
  final FlutterAudioCapture _audioCapture = FlutterAudioCapture();
  final NoteRecognition _noteRecognition = NoteRecognition();

  bool _listening = false;
  double _freq = 0.0;
  String _note = '-';
  double _cents = 0.0;

  final int sampleRate = 44100;
  final int bufferSize = 4096;

  @override
  void dispose() {
    _stop();
    super.dispose();
  }

  Future<void> _start() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone access denied')),
      );
      return;
    }

    if (_listening) return;

    final ok = await _audioCapture.init();
    if (ok != true) {
      debugPrint("❌ AudioCapture init failed");
      return;
    }

    await _audioCapture.start(
          (Float32List floatData) {
        final amplitude =
        floatData.map((e) => e.abs()).reduce((a, b) => a > b ? a : b);
        if (amplitude < 0.05) return;

        if (floatData.length >= 2048) {
          final f = _noteRecognition.detectPitch(floatData);
          if (f > 0) {
            final mapping = _noteRecognition.freqToNote(f);
            setState(() {
              _freq = f;
              _note = mapping['name'] as String;
              _cents = mapping['cents'] as double;
            });
          }
        }
      },
          (Object e, StackTrace s) => debugPrint("Audio error: $e"),
      sampleRate: sampleRate,
      bufferSize: bufferSize,
    );

    setState(() => _listening = true);
  }

  Future<void> _stop() async {
    if (!_listening) return;
    await _audioCapture.stop();
    setState(() {
      _listening = false;
      _freq = 0.0;
      _note = '-';
      _cents = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    final bool inTune = _cents.abs() < 7;
    final leftArrowColor = _cents < -7 ? accent : accent.withOpacity(0.3);
    final rightArrowColor = _cents > 7 ? accent : accent.withOpacity(0.3);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("‹", style: TextStyle(fontSize: 80, color: leftArrowColor)),
                  const SizedBox(width: 20),
                  Text(
                    _note,
                    style: TextStyle(
                      fontSize: 120,
                      fontWeight: FontWeight.bold,
                      color: accent,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text("›", style: TextStyle(fontSize: 80, color: rightArrowColor)),
                ],
              ),
              const SizedBox(height: 30),
              Text(
                '${_freq.toStringAsFixed(1)} Hz',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Deviation: ${_cents.toStringAsFixed(1)} cents',
                style: TextStyle(
                  fontSize: 20,
                  color: theme.colorScheme.onSurface.withOpacity(0.70),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  elevation: 5,
                ),
                onPressed: _listening ? _stop : _start,
                child: Text(_listening ? 'Stop' : 'Start',
                    style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(height: 20),
              Text(
                inTune ? '🎵 Perfect!' : '👉 Tuning...',
                style: TextStyle(
                  fontSize: 20,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
