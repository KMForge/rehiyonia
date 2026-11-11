// Generate the original word-discovery sparkle, with no external audio samples.
// Run: dart run tool/generate_spark_sfx.dart
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

void main() {
  const rate = 44100;
  const duration = .8;
  final samples = Float64List((rate * duration).round());
  const notes = [1046.50, 1318.51, 1567.98, 2093.00, 2637.02];
  final random = math.Random(18025);
  for (var i = 0; i < samples.length; i++) {
    final t = i / rate;
    var value = 0.0;
    for (var n = 0; n < notes.length; n++) {
      final age = t - n * .055;
      if (age < 0) continue;
      final attack = (age / .006).clamp(0.0, 1.0);
      final envelope = attack * math.exp(-age * 10);
      final phase = 2 * math.pi * notes[n] * age;
      value += envelope * (math.sin(phase) + .16 * math.sin(phase * 2.76));
    }
    // A restrained, airy sparkle underneath the ascending bell tones.
    value += (random.nextDouble() * 2 - 1) * .035 * math.exp(-t * 14);
    final fadeOut = ((duration - t) / .12).clamp(0.0, 1.0);
    samples[i] = value * fadeOut;
  }
  final peak = samples.fold<double>(0, (p, v) => math.max(p, v.abs()));
  final data = ByteData(44 + samples.length * 2);
  void label(int offset, String text) {
    for (var i = 0; i < text.length; i++) {
      data.setUint8(offset + i, text.codeUnitAt(i));
    }
  }

  label(0, 'RIFF');
  data.setUint32(4, data.lengthInBytes - 8, Endian.little);
  label(8, 'WAVE');
  label(12, 'fmt ');
  data.setUint32(16, 16, Endian.little);
  data.setUint16(20, 1, Endian.little); // PCM
  data.setUint16(22, 1, Endian.little); // mono
  data.setUint32(24, rate, Endian.little);
  data.setUint32(28, rate * 2, Endian.little);
  data.setUint16(32, 2, Endian.little);
  data.setUint16(34, 16, Endian.little);
  label(36, 'data');
  data.setUint32(40, samples.length * 2, Endian.little);
  for (var i = 0; i < samples.length; i++) {
    data.setInt16(
      44 + i * 2,
      (samples[i] / peak * 18000).round(),
      Endian.little,
    );
  }
  final file = File('assets/audio/sound_effects/word_sparkle.wav');
  file.parent.createSync(recursive: true);
  file.writeAsBytesSync(data.buffer.asUint8List());
  stdout.writeln(
    'Generated ${file.path}: ${samples.length} samples, ${duration}s',
  );
}
