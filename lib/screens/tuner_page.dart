import 'dart:async';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:pitchupdart/pitch_handler.dart';
import 'package:pitchupdart/instrument_type.dart';

class TunerPage extends StatefulWidget {
  const TunerPage({super.key});

  @override
  State<TunerPage> createState() => _TunerPageState();
}

class _TunerPageState extends State<TunerPage> {
  final AudioRecorder _recorder = AudioRecorder();
  final PitchHandler _pitchUp = PitchHandler(InstrumentType.guitar);

  bool _isRecording = false;
  String _note = '-';
  String _status = '-';
  double _cents = 0;

  StreamSubscription<Uint8List>? _audioStream;
  double _lastHz = 0;

  /* ---------- start / stop recording ---------- */
  Future<void> _toggle() async {
    if (await Permission.microphone.request().isDenied) return;

    if (_isRecording) {
      await _audioStream?.cancel();
      await _recorder.stop();
      setState(() => _isRecording = false);
    } else {
      _audioStream = (await _recorder.startStream(const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 44100,
        numChannels: 1,
      )))
          .listen((bytes) => _processAudio(bytes));

      setState(() => _isRecording = true);
    }
  }

  /* ---------- pitch detection ---------- */
  double? _findPitch(Uint8List bytes) {
    final samples = bytes.buffer.asInt16List();
    const sampleRate = 44100;
    final frame = math.min(4096, samples.length);
    if (frame < 1024) return null;

    // RMS threshold (ignore quiet frames)
    double sum = 0;
    for (int i = 0; i < frame; i++) sum += samples[i] * samples[i].toDouble();
    final rms = math.sqrt(sum / frame);
    if (rms < 5000) return null; // lower for faster detection

    // Autocorrelation
    int peakLag = 0;
    double maxCorr = 0;
    for (int lag = 40; lag < 1000 && lag < frame; lag++) {
      double corr = 0;
      for (int i = 0; i < frame - lag; i++) {
        corr += samples[i] * samples[i + lag];
      }
      if (corr > maxCorr) {
        maxCorr = corr;
        peakLag = lag;
      }
    }
    if (peakLag == 0) return null;

    double hz = sampleRate / peakLag;
    hz = _correctOctave(hz, _lastHz);

    return hz;
  }

  double _correctOctave(double hz, double lastHz) {
    if (lastHz == 0) return hz;
    while (hz > lastHz * 1.5) hz /= 2;
    while (hz < lastHz / 1.5) hz *= 2;
    return hz;
  }

  /* ---------- smoothing filter ---------- */
  double _smoothHz(double newHz) {
    const alpha = 0.5; // higher = faster response
    if (_lastHz == 0) return newHz;
    // Jump quickly if change > 50 cents (~3%)
    if ((newHz - _lastHz).abs() / _lastHz > 0.03) return newHz;
    return _lastHz * (1 - alpha) + newHz * alpha;
  }

  /* ---------- process audio ---------- */
  void _processAudio(Uint8List bytes) async {
    final rawHz = _findPitch(bytes);
    if (rawHz == null) return;

    final smoothHz = _smoothHz(rawHz);
    _lastHz = smoothHz;

    final result = await _pitchUp.handlePitch(smoothHz);

    setState(() {
      _note = result.note;
      _status = result.tuningStatus.name;
      _cents = result.diffCents;
    });
  }

  /* ---------- UI ---------- */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guitar Tuner')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isRecording ? Icons.mic : Icons.mic_off,
              size: 100,
              color: _isRecording ? Colors.red : Colors.grey,
            ),
            const SizedBox(height: 20),
            Text('Note: $_note', style: const TextStyle(fontSize: 40)),
            Text('Status: $_status', style: const TextStyle(fontSize: 24)),
            Text('Cents: ${_cents.toStringAsFixed(1)}',
                style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _toggle,
              child: Text(_isRecording ? 'STOP' : 'START',
                  style: const TextStyle(fontSize: 22)),
            ),
          ],
        ),
      ),
    );
  }

  /* ---------- dispose ---------- */
  @override
  void dispose() {
    _audioStream?.cancel();
    _recorder.dispose();
    super.dispose();
  }
}
