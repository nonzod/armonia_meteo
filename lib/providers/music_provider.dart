// lib/providers/music_provider.dart
import 'package:flutter/material.dart';
import '../services/ai_synthesis_service.dart';
import '../models/weather_model.dart';

class MusicProvider extends ChangeNotifier {
  final AISynthesisService _synthesisService = AISynthesisService();
  Map<String, dynamic>? _musicParams;
  bool _isPlaying = false;
  bool _isLoading = false;
  String _currentMusicDescription = '';
  
  Map<String, dynamic>? get musicParams => _musicParams;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  String get currentMusicDescription => _currentMusicDescription;
  
  Future<void> generateMusic(WeatherData weatherData, int durationMinutes) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Converti i dati meteo in parametri musicali
      _musicParams = _synthesisService.mapWeatherToMusic(weatherData);
      
      // Descrivi la musica che verrà generata
      _currentMusicDescription = _synthesisService.generateMusicDescription(
        _musicParams!, 
        weatherData
      );
      
      // Avvia la generazione e riproduzione
      await _synthesisService.startGenerating(_musicParams!, durationMinutes);
      
      _isPlaying = true;
    } catch (e) {
      print('Errore nella generazione della musica: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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