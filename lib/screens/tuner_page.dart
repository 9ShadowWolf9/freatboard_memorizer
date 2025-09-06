// lib/screens/tuner_page.dart
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:permission_handler/permission_handler.dart';

class TunerPage extends StatefulWidget {
  const TunerPage({super.key});

  @override
  State<TunerPage> createState() => _TunerPageState();
}

class _TunerPageState extends State<TunerPage> {
  final FlutterAudioCapture _audioCapture = FlutterAudioCapture();
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
        if (floatData.length >= 2048) {
          final f = detectPitchAutocorrelation(floatData, sampleRate);
          if (f > 0) {
            final mapping = freqToNote(f);
            setState(() {
              _freq = f;
              _note = mapping['name'] as String;
              _cents = mapping['cents'] as double;
            });
          }
        }
      },
          (Object e, StackTrace s) {
        debugPrint("Audio error: $e");
      },
      sampleRate: sampleRate,
      bufferSize: bufferSize,
    );

    setState(() {
      _listening = true;
    });
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

  double detectPitchAutocorrelation(Float32List buffer, int sampleRate) {
    final int size = buffer.length;
    final List<double> x = List<double>.filled(size, 0.0);
    for (int i = 0; i < size; i++) {
      final window = 0.5 * (1 - cos(2 * pi * i / (size - 1))); // Hann window
      x[i] = buffer[i] * window;
    }

    final int maxLag = (sampleRate / 82).floor(); // ~E2
    final int minLag = (sampleRate / 1000).floor(); // ~1kHz
    final List<double> ac = List<double>.filled(maxLag - minLag + 1, 0.0);

    for (int lag = minLag; lag <= maxLag; lag++) {
      double sum = 0.0;
      for (int i = 0; i < size - lag; i++) {
        sum += x[i] * x[i + lag];
      }
      ac[lag - minLag] = sum;
    }

    int bestLagIndex = 0;
    double bestVal = -double.infinity;
    for (int i = 0; i < ac.length; i++) {
      if (ac[i] > bestVal) {
        bestVal = ac[i];
        bestLagIndex = i;
      }
    }

    final int lag = bestLagIndex + minLag;
    if (bestVal <= 0) return 0.0;

    final double frequency = sampleRate / lag;
    if (frequency.isFinite && frequency > 30 && frequency < 5000) {
      return frequency;
    } else {
      return 0.0;
    }
  }

  Map<String, Object> freqToNote(double freq) {
    if (freq <= 0) return {'name': '-', 'cents': 0.0};
    final double noteNumber = 12 * (log(freq / 440.0) / ln2) + 69;
    final int rounded = noteNumber.round();
    final double cents = (noteNumber - rounded) * 100.0;

    const names = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
    final int nameIndex = (rounded % 12 + 12) % 12;
    final int octave = (rounded ~/ 12) - 1;
    final String name = '${names[nameIndex]}$octave';

    return {'name': name, 'cents': cents};
  }

  @override
  Widget build(BuildContext context) {
    final bool inTune = _cents.abs() < 7;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tuner gitarowy'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              _note,
              style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('${_freq.toStringAsFixed(1)} Hz', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            Text('Odchylenie: ${_cents.toStringAsFixed(1)} cent',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: CustomPaint(
                  size: const Size(300, 120),
                  painter: NeedlePainter(_cents),
                ),
              ),
            ),
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

class NeedlePainter extends CustomPainter {
  final double cents;
  NeedlePainter(this.cents);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 20);
    final radius = min(size.width / 2 - 16, size.height);
    final paintArc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;

    paintArc.color = Colors.white12;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), pi, pi, false, paintArc);

    final double maxAngle = pi / 2;
    final double angle = (cents / 50).clamp(-1.0, 1.0) * maxAngle;
    final needlePaint = Paint()
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = (cents.abs() < 7) ? Colors.green : Colors.red;

    final needle = Offset(center.dx + radius * cos(pi + angle), center.dy + radius * sin(pi + angle));
    canvas.drawLine(center, needle, needlePaint);

    final centerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, 6, centerPaint);
  }

  @override
  bool shouldRepaint(covariant NeedlePainter old) => old.cents != cents;
}
