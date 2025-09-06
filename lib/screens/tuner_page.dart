import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/note_recognition.dart';
import '../components/pitch_indicator.dart';

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
        const SnackBar(content: Text('Brak dostępu do mikrofonu')),
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
        // Ignore quiet signals
        final amplitude = floatData.map((e) => e.abs()).reduce((a, b) => a > b ? a : b);
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
    final bool inTune = _cents.abs() < 7;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: CustomPaint(
                  size: const Size(200, 200),
                  painter: PitchIndicatorPainter(_cents, _note),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('${_freq.toStringAsFixed(1)} Hz', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            Text('Odchylenie: ${_cents.toStringAsFixed(1)} cent', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _listening ? _stop : _start,
              child: Text(_listening ? 'Stop' : 'Start'),
            ),
            const SizedBox(height: 8),
            Text(
              inTune ? 'Dobrze nastrojone!' : 'Dostrój strunę',
              style: TextStyle(color: inTune ? Colors.green : Colors.orange),
            ),
          ],
        ),
      ),
    );
  }
}

