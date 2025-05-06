// lib/services/music_generation_service.dart
import 'dart:math';
import '../models/weather_model.dart';
import '../models/music_params_model.dart';
import 'package:just_audio/just_audio.dart';

class MusicGenerationService {
  final Random _random = Random();
  late final AudioPlayer _backgroundPlayer;
  late final AudioPlayer _melodyPlayer;
  
  MusicGenerationService() {
    _backgroundPlayer = AudioPlayer();
    _melodyPlayer = AudioPlayer();
  }

  // Genera i parametri musicali in base al meteo
  MusicParams generateMusicParams(WeatherData weatherData) {
    // Temperatura -> Tonalità
    String tonality;
    if (weatherData.temperature < 10) {
      tonality = 'minor_low'; // Tonalità minori, basse frequenze
    } else if (weatherData.temperature < 20) {
      tonality = 'major_mid'; // Tonalità maggiori, frequenze medie
    } else {
      tonality = 'major_high'; // Tonalità maggiori brillanti, alte frequenze
    }

    // Umidità -> Riverbero
    double reverbLevel = weatherData.humidity / 100; // Da 0 a 1

    // Vento -> Ritmo e arpeggi
    double tempo = 60 + (weatherData.windSpeed * 2); // Da 60 a ~140 BPM
    
    // Condizioni -> Accordi e toni
    String chordProgression;
    double brightness;
    
    switch (weatherData.condition) {
      case 'Sereno':
        chordProgression = 'major';
        brightness = 0.8;
        break;
      case 'Parzialmente nuvoloso':
        chordProgression = 'major';
        brightness = 0.6;
        break;
      case 'Nuvoloso':
        chordProgression = 'minor';
        brightness = 0.4;
        break;
      case 'Pioggia':
      case 'Pioggia leggera':
        chordProgression = 'minor';
        brightness = 0.3;
        break;
      case 'Neve':
      case 'Neve intensa':
        chordProgression = 'suspended';
        brightness = 0.5;
        break;
      case 'Temporale':
        chordProgression = 'diminished';
        brightness = 0.2;
        break;
      case 'Nebbia':
        chordProgression = 'minor';
        brightness = 0.3;
        break;
      default:
        chordProgression = 'major';
        brightness = 0.5;
    }

    return MusicParams(
      tonality: tonality,
      reverbLevel: reverbLevel,
      tempo: tempo,
      chordProgression: chordProgression,
      brightness: brightness,
    );
  }
  
  Future<void> loadAndPlayMusic(MusicParams params, int durationMinutes) async {
    // Seleziona tracce audio in base ai parametri
    String backgroundTrack = _selectBackgroundTrack(params);
    String melodyTrack = _selectMelodyTrack(params);
    
    // Carica le tracce audio
    await _backgroundPlayer.setAsset(backgroundTrack);
    await _melodyPlayer.setAsset(melodyTrack);
    
    // Imposta il volume in base ai parametri
    _backgroundPlayer.setVolume(0.7);
    _melodyPlayer.setVolume(params.brightness);
    
    // Imposta la velocità in base al tempo
    double speedFactor = params.tempo / 80; // Normalizza intorno a 80 BPM
    _melodyPlayer.setSpeed(speedFactor);
    
    // Riproduzione in loop
    _backgroundPlayer.setLoopMode(LoopMode.all);
    _melodyPlayer.setLoopMode(LoopMode.all);
    
    // Avvia la riproduzione
    await _backgroundPlayer.play();
    await _melodyPlayer.play();
  }
  
  String _selectBackgroundTrack(MusicParams params) {
    // Logic to select the appropriate background track based on parameters
    if (params.chordProgression == 'minor') {
      return 'assets/audio/ambient_minor.mp3';
    } else if (params.chordProgression == 'diminished') {
      return 'assets/audio/ambient_dark.mp3';
    } else if (params.chordProgression == 'suspended') {
      return 'assets/audio/ambient_crystal.mp3';
    } else {
      return 'assets/audio/ambient_major.mp3';
    }
  }
  
  String _selectMelodyTrack(MusicParams params) {
    // Logic to select the appropriate melody track based on parameters
    if (params.tonality.startsWith('minor')) {
      return 'assets/audio/melody_minor.mp3';
    } else if (params.tonality.endsWith('low')) {
      return 'assets/audio/melody_low.mp3';
    } else if (params.tonality.endsWith('high')) {
      return 'assets/audio/melody_high.mp3';
    } else {
      return 'assets/audio/melody_medium.mp3';
    }
  }
  
  Future<void> stop() async {
    await _backgroundPlayer.stop();
    await _melodyPlayer.stop();
  }
  
  Future<void> pause() async {
    await _backgroundPlayer.pause();
    await _melodyPlayer.pause();
  }
  
  Future<void> resume() async {
    await _backgroundPlayer.play();
    await _melodyPlayer.play();
  }
  
  void dispose() {
    _backgroundPlayer.dispose();
    _melodyPlayer.dispose();
  }
}