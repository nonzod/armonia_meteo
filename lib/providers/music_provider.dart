// lib/providers/music_provider.dart
import 'package:flutter/material.dart';
import '../models/sound_synthesis_model.dart';
import '../services/ai_synthesis_service.dart';
import '../models/weather_model.dart';

class MusicProvider extends ChangeNotifier {
  final AISynthesisService _synthesisService = AISynthesisService();
  SoundSynthesisParams? _synthesisParams;
  bool _isPlaying = false;
  bool _isLoading = false;
  String _currentMusicDescription = '';
  
  SoundSynthesisParams? get synthesisParams => _synthesisParams;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  String get currentMusicDescription => _currentMusicDescription;
  
  Future<void> generateMusic(WeatherData weatherData, int durationMinutes) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Converti i dati meteo in parametri di sintesi musicale
      _synthesisParams = _synthesisService.mapWeatherToSynthesis(weatherData);
      
      // Descrivi la musica che verrà generata
      _currentMusicDescription = _generateMusicDescription(_synthesisParams!, weatherData);
      
      // Avvia la generazione e riproduzione
      await _synthesisService.startGenerating(_synthesisParams!, durationMinutes);
      
      _isPlaying = true;
    } catch (e) {
      print('Errore nella generazione della musica: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  String _generateMusicDescription(SoundSynthesisParams params, WeatherData weather) {
    String mood = '';
    String tempo = '';
    String texture = '';
    
    // Descrizione umore basata su waveType e brightness
    if (params.waveType == 'sine' && params.brightness > 0.6) {
      mood = 'luminosa';
    } else if (params.waveType == 'sine') {
      mood = 'serena';
    } else if (params.waveType == 'triangle' && params.reverb > 0.6) {
      mood = 'contemplativa';
    } else if (params.waveType == 'triangle') {
      mood = 'riflessiva';
    } else if (params.waveType == 'sawtooth') {
      mood = 'intensa';
    } else {
      mood = 'avvolgente';
    }
    
    // Descrizione tempo basata sul parametro tempo
    if (params.tempo < 70) {
      tempo = 'lenta';
    } else if (params.tempo < 100) {
      tempo = 'moderata';
    } else {
      tempo = 'vivace';
    }
    
    // Descrizione texture basata su harmonicity e resonance
    if (params.harmonicity > 0.7 && params.resonance < 0.4) {
      texture = 'eterea';
    } else if (params.harmonicity > 0.6) {
      texture = 'armoniosa';
    } else if (params.resonance > 0.7) {
      texture = 'profonda';
    } else if (params.modulation > 0.7) {
      texture = 'dinamica';
    } else {
      texture = 'rilassante';
    }
    
    return 'Musica $mood, $texture con melodia $tempo generata in base a ${weather.condition.toLowerCase()} a ${weather.temperature.toStringAsFixed(1)}°C';
  }
  
  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await _synthesisService.pause();
    } else {
      await _synthesisService.resume();
    }
    _isPlaying = !_isPlaying;
    notifyListeners();
  }
  
  Future<void> stopMusic() async {
    await _synthesisService.stopGenerating();
    _isPlaying = false;
    notifyListeners();
  }
  
  @override
  void dispose() {
    _synthesisService.stopGenerating();
    super.dispose();
  }
}