import 'dart:math';
import 'dart:typed_data';

class NoteRecognition {
  final int sampleRate;

  NoteRecognition({this.sampleRate = 44100});

  /// Detect pitch using autocorrelation
  double detectPitch(Float32List buffer) {
    final int size = buffer.length;
    final List<double> x = List<double>.filled(size, 0.0);

    // Apply Hann window
    for (int i = 0; i < size; i++) {
      final window = 0.5 * (1 - cos(2 * pi * i / (size - 1)));
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
    }
    return 0.0;
  }

  /// Convert frequency to musical note
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
}
