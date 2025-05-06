// lib/models/music_params_model.dart
class MusicParams {
  final String tonality;       // Basata sulla temperatura
  final double reverbLevel;    // Basata sull'umidità
  final double tempo;          // Basato sul vento
  final String chordProgression; // Basato sulle condizioni meteo
  final double brightness;     // Basato sulle condizioni meteo

  MusicParams({
    required this.tonality,
    required this.reverbLevel,
    required this.tempo,
    required this.chordProgression,
    required this.brightness,
  });

  @override
  String toString() {
    return 'MusicParams(tonality: $tonality, reverbLevel: $reverbLevel, tempo: $tempo, chordProgression: $chordProgression, brightness: $brightness)';
  }
}