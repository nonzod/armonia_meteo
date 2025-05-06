// lib/models/sound_synthesis_model.dart
class SoundSynthesisParams {
  final double frequency;     // Frequenza base (Hz)
  final double modulation;    // Modulazione (0-1)
  final double tempo;         // Tempo (BPM)
  final double reverb;        // Riverbero (0-1)
  final double harmonicity;   // Armonicità (0-1)
  final List<double> harmonics; // Armoniche
  final double resonance;     // Risonanza (0-1)
  final String waveType;      // Tipo di onda (sine, square, etc)
  final double brightness;    // Luminosità timbrica (0-1)
  
  SoundSynthesisParams({
    required this.frequency,
    required this.modulation,
    required this.tempo,
    required this.reverb,
    required this.harmonicity,
    required this.harmonics,
    required this.resonance,
    required this.waveType,
    required this.brightness,
  });
  
  @override
  String toString() {
    return 'SoundSynthesisParams(frequency: $frequency, modulation: $modulation, '
           'tempo: $tempo, reverb: $reverb, harmonicity: $harmonicity, '
           'harmonics: ${harmonics.length} items, resonance: $resonance, '
           'waveType: $waveType, brightness: $brightness)';
  }
}