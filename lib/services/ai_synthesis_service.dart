// lib/services/ai_synthesis_service.dart (versione semplificata)
import 'dart:async';
import 'dart:math';
import 'package:just_audio/just_audio.dart';
import '../models/weather_model.dart';

class AISynthesisService {
  final Random _random = Random();
  final List<AudioPlayer> _layerPlayers = [];
  final List<AudioPlayer> _effectPlayers = [];
  Timer? _generativeTimer;
  bool _isPlaying = false;
  
  // Mappa i dati meteo in parametri musicali
  Map<String, dynamic> mapWeatherToMusic(WeatherData weatherData) {
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
    double reverb = weatherData.humidity / 100; // Da 0 a 1

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
    
    return {
      'tonality': tonality,
      'reverb': reverb,
      'tempo': tempo,
      'chordProgression': chordProgression,
      'brightness': brightness,
    };
  }
  
  // Avvia la generazione e riproduzione
  Future<void> startGenerating(Map<String, dynamic> params, int durationMinutes) async {
    // Ferma qualsiasi generazione precedente
    await stopGenerating();
    
    // Carica i suoni di base
    await _loadBaseSounds(params);
    
    // Avvia la generazione procedurale in tempo reale
    _startProceduralGeneration(params);
    
    _isPlaying = true;
  }
  
  Future<void> _loadBaseSounds(Map<String, dynamic> params) async {
    try {
      // Layer 1: Drone di base
      final basePlayer = AudioPlayer();
      String baseAsset;
      
      // Seleziona il file audio appropriato in base al chord progression
      if (params['chordProgression'] == 'minor') {
        baseAsset = 'assets/audio/base_minor.mp3';
      } else if (params['chordProgression'] == 'diminished') {
        baseAsset = 'assets/audio/base_dark.mp3';
      } else if (params['chordProgression'] == 'suspended') {
        baseAsset = 'assets/audio/base_crystal.mp3';
      } else {
        baseAsset = 'assets/audio/base_major.mp3';
      }
      
      await basePlayer.setAsset(baseAsset);
      await basePlayer.setLoopMode(LoopMode.all);
      await basePlayer.setVolume(0.7);
      await basePlayer.play();
      _layerPlayers.add(basePlayer);
      
      // Layer 2: Melodia in base alla tonalità
      final melodyPlayer = AudioPlayer();
      String melodyAsset;
      
      if (params['tonality'].startsWith('minor')) {
        melodyAsset = 'assets/audio/melody_minor.mp3';
      } else if (params['tonality'].endsWith('low')) {
        melodyAsset = 'assets/audio/melody_low.mp3';
      } else if (params['tonality'].endsWith('high')) {
        melodyAsset = 'assets/audio/melody_high.mp3';
      } else {
        melodyAsset = 'assets/audio/melody_medium.mp3';
      }
      
      await melodyPlayer.setAsset(melodyAsset);
      await melodyPlayer.setLoopMode(LoopMode.all);
      await melodyPlayer.setVolume(params['brightness'] * 0.5);
      // Velocità basata sul tempo
      double speedFactor = params['tempo'] / 80; // Normalizza intorno a 80 BPM
      await melodyPlayer.setSpeed(speedFactor);
      await melodyPlayer.play();
      _layerPlayers.add(melodyPlayer);
      
      // Layer 3: Texture ambientale (es. pioggia, vento)
      if (params['condition'] != 'Sereno' && params['condition'] != 'Parzialmente nuvoloso') {
        final texturePlayer = AudioPlayer();
        String textureAsset = 'assets/audio/texture_${params['condition'].toLowerCase()}.mp3';
        try {
          await texturePlayer.setAsset(textureAsset);
          await texturePlayer.setLoopMode(LoopMode.all);
          await texturePlayer.setVolume(params['reverb'] * 0.6);
          await texturePlayer.play();
          _layerPlayers.add(texturePlayer);
        } catch (e) {
          print('Texture audio non trovata: $e');
          // Fallback texture
          await texturePlayer.setAsset('assets/audio/texture_default.mp3');
          await texturePlayer.setLoopMode(LoopMode.all);
          await texturePlayer.setVolume(params['reverb'] * 0.6);
          await texturePlayer.play();
          _layerPlayers.add(texturePlayer);
        }
      }
    } catch (e) {
      print('Errore nel caricamento degli audio: $e');
    }
  }
  
  void _startProceduralGeneration(Map<String, dynamic> params) {
    // Intervallo basato sul tempo
    int intervalMs = (60000 / params['tempo']).round();
    
    _generativeTimer = Timer.periodic(Duration(milliseconds: intervalMs), (timer) async {
      if (!_isPlaying) return;
      
      // Variazioni random di volume per creare dinamismo
      _varyPlayerParameters();
      
      // Possibilità di aggiungere effetti occasionali
      if (_random.nextDouble() < 0.15) {
        _playRandomEffect(params);
      }
    });
  }
  
  void _varyPlayerParameters() {
    for (var player in _layerPlayers) {
      // Varia il volume leggermente
      double currentVolume = player.volume;
      double variation = (_random.nextDouble() * 0.1) - 0.05; // Da -0.05 a +0.05
      double newVolume = max(0.1, min(1.0, currentVolume + variation));
      player.setVolume(newVolume);
    }
  }
  
  void _playRandomEffect(Map<String, dynamic> params) async {
    String effectAsset;
    
    // Seleziona un effetto in base alle condizioni meteo
    if (params['chordProgression'] == 'minor' || params['chordProgression'] == 'diminished') {
      effectAsset = 'assets/audio/effect_low.mp3';
    } else if (params['brightness'] > 0.6) {
      effectAsset = 'assets/audio/effect_high.mp3';
    } else {
      effectAsset = 'assets/audio/effect_mid.mp3';
    }
    
    try {
      final effectPlayer = AudioPlayer();
      await effectPlayer.setAsset(effectAsset);
      await effectPlayer.setVolume(0.3 + (params['reverb'] * 0.3));
      await effectPlayer.play();
      
      _effectPlayers.add(effectPlayer);
      
      // Rimuovi il player dopo la riproduzione
      effectPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          effectPlayer.dispose();
          _effectPlayers.remove(effectPlayer);
        }
      });
    } catch (e) {
      print('Errore nella riproduzione dell\'effetto: $e');
    }
  }
  
  Future<void> pause() async {
    _isPlaying = false;
    for (var player in _layerPlayers) {
      await player.pause();
    }
  }
  
  Future<void> resume() async {
    _isPlaying = true;
    for (var player in _layerPlayers) {
      await player.play();
    }
  }
  
  Future<void> stopGenerating() async {
    _isPlaying = false;
    _generativeTimer?.cancel();
    
    // Ferma tutti i player audio
    for (var player in _layerPlayers) {
      await player.stop();
      await player.dispose();
    }
    for (var player in _effectPlayers) {
      await player.stop();
      await player.dispose();
    }
    
    _layerPlayers.clear();
    _effectPlayers.clear();
  }
  
  String generateMusicDescription(Map<String, dynamic> params, WeatherData weather) {
    String mood = '';
    String tempo = '';
    String texture = '';
    
    // Descrizione umore basata su chord progression e brightness
    if (params['chordProgression'] == 'major' && params['brightness'] > 0.6) {
      mood = 'luminosa';
    } else if (params['chordProgression'] == 'major') {
      mood = 'serena';
    } else if (params['chordProgression'] == 'minor' && params['reverb'] > 0.6) {
      mood = 'contemplativa';
    } else if (params['chordProgression'] == 'minor') {
      mood = 'riflessiva';
    } else if (params['chordProgression'] == 'diminished') {
      mood = 'intensa';
    } else {
      mood = 'avvolgente';
    }
    
    // Descrizione tempo
    if (params['tempo'] < 70) {
      tempo = 'lenta';
    } else if (params['tempo'] < 100) {
      tempo = 'moderata';
    } else {
      tempo = 'vivace';
    }
    
    // Descrizione texture
    if (params['tonality'].contains('high')) {
      texture = 'eterea';
    } else if (params['tonality'].contains('low')) {
      texture = 'profonda';
    } else {
      texture = 'armoniosa';
    }
    
    return 'Musica $mood, $texture con melodia $tempo generata in base a ${weather.condition.toLowerCase()} a ${weather.temperature.toStringAsFixed(1)}°C';
  }
}