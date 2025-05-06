// lib/screens/meditation_screen.dart (modificato)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import '../providers/music_provider.dart';
import '../providers/weather_provider.dart';

class MeditationScreen extends StatefulWidget {
  final int durationMinutes;

  const MeditationScreen({super.key, required this.durationMinutes});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> {
  int _remainingSeconds = 0;
  bool _isPlaying = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.durationMinutes * 60;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startMeditation();
    });
  }

  void _startMeditation() async {
    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
    final musicProvider = Provider.of<MusicProvider>(context, listen: false);
    
    // Genera la musica basata sul meteo
    if (weatherProvider.weatherData != null) {
      await musicProvider.generateMusic(
        weatherProvider.weatherData!, 
        widget.durationMinutes
      );
      
      // Avvia il timer solo dopo che la musica è pronta
      setState(() {
        _isPlaying = true;
      });
      
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0 && _isPlaying) {
        setState(() {
          _remainingSeconds--;
        });
      } else if (_remainingSeconds <= 0) {
        _endMeditation();
      }
    });
  }

  void _togglePlayPause() {
    final musicProvider = Provider.of<MusicProvider>(context, listen: false);
    musicProvider.togglePlayPause();
    
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _endMeditation() {
    _timer?.cancel();
    final musicProvider = Provider.of<MusicProvider>(context, listen: false);
    musicProvider.stopMusic();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo, Colors.deepPurple],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              _buildAnimatedIcon(),
              const SizedBox(height: 60),
              Text(
                _formatTime(_remainingSeconds),
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              _buildMusicInfo(),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _togglePlayPause,
                    icon: Icon(
                      _isPlaying ? Icons.pause_circle : Icons.play_circle,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                  const SizedBox(width: 40),
                  IconButton(
                    onPressed: _endMeditation,
                    icon: const Icon(
                      Icons.stop_circle,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon() {
    return Consumer<MusicProvider>(
      builder: (context, musicProvider, child) {
        if (musicProvider.isLoading) {
          return const CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 4,
          );
        }
        
        return CircleAvatar(
          radius: 100,
          backgroundColor: Colors.white24,
          child: Icon(
            Icons.waves,
            size: 100,
            color: Colors.white70,
          )
          .animate(onPlay: (controller) => controller.repeat())
          .scale(
            duration: 2.seconds,
            curve: Curves.easeInOut,
            begin: const Offset(1, 1),
            end: const Offset(1.1, 1.1),
          )
          .then()
          .scale(
            duration: 2.seconds,
            curve: Curves.easeInOut,
            begin: const Offset(1.1, 1.1),
            end: const Offset(1, 1),
          ),
        );
      },
    );
  }

  Widget _buildMusicInfo() {
    return Consumer<MusicProvider>(
      builder: (context, musicProvider, child) {
        final params = musicProvider.musicParams;
        if (params == null) {
          return const SizedBox.shrink();
        }

        String description = _getMusicDescription(params);
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        );
      },
    );
  }

  String _getMusicDescription(dynamic params) {
    String tempo = '';
    if (params.tempo < 70) {
      tempo = 'lenta';
    } else if (params.tempo < 100) {
      tempo = 'moderata';
    } else {
      tempo = 'vivace';
    }

    String tonalita = '';
    if (params.tonality.contains('minor')) {
      tonalita = 'profonda';
    } else if (params.tonality.contains('low')) {
      tonalita = 'rilassante';
    } else if (params.tonality.contains('high')) {
      tonalita = 'luminosa';
    } else {
      tonalita = 'bilanciata';
    }

    return 'Musica $tonalita con ritmo $tempo generata in base al meteo attuale';
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}