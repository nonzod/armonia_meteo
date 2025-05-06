// lib/screens/meditation_screen.dart (modificato)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import 'dart:math';
import '../providers/music_provider.dart';
import '../providers/weather_provider.dart';

class MeditationScreen extends StatefulWidget {
  final int durationMinutes;

  const MeditationScreen({super.key, required this.durationMinutes});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> with SingleTickerProviderStateMixin {
  int _remainingSeconds = 0;
  bool _isPlaying = false;
  Timer? _timer;
  late AnimationController _animationController;
  final Random _random = Random();
  final List<ParticlePoint> _particles = [];

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.durationMinutes * 60;
    
    // Configurazione animazione
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _animationController.repeat(reverse: true);
    
    // Inizializza le particelle
    _initParticles();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startMeditation();
    });
  }

  void _initParticles() {
    // Crea particelle iniziali per l'animazione
    for (int i = 0; i < 30; i++) {
      _particles.add(ParticlePoint(
        x: _random.nextDouble() * 300,
        y: _random.nextDouble() * 300,
        size: 2 + _random.nextDouble() * 6,
        speed: 0.2 + _random.nextDouble() * 1.0,
        angle: _random.nextDouble() * 2 * pi,
        color: Colors.white.withOpacity(0.1 + _random.nextDouble() * 0.6),
      ));
    }
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
    _animationController.dispose();
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
              _buildGenerativeVisual(),
              const SizedBox(height: 40),
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

  Widget _buildGenerativeVisual() {
    return Consumer<MusicProvider>(
      builder: (context, musicProvider, child) {
        if (musicProvider.isLoading) {
          return const CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 4,
          );
        }
        
        return Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.1),
          ),
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              // Aggiorna le particelle
              for (var particle in _particles) {
                particle.update(_animationController.value);
              }
              
              return CustomPaint(
                painter: ParticlePainter(
                  particles: _particles,
                  animationValue: _animationController.value,
                  isPlaying: _isPlaying,
                ),
                child: Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.15),
                    ),
                    child: const Icon(
                      Icons.waves,
                      size: 50,
                      color: Colors.white70,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMusicInfo() {
    return Consumer<MusicProvider>(
      builder: (context, musicProvider, child) {
        if (musicProvider.isLoading) {
          return const Text(
            'Generando musica personalizzata...',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          );
        }
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            musicProvider.currentMusicDescription,
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

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

// Classe per le particelle visive
class ParticlePoint {
  double x;
  double y;
  double size;
  double speed;
  double angle;
  Color color;
  
  ParticlePoint({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.angle,
    required this.color,
  });
  
  void update(double animValue) {
    // Muovi la particella
    x += cos(angle) * speed * (1 + animValue);
    y += sin(angle) * speed * (1 + animValue);
    
    // Wrapping se esce dai bordi
    if (x < 0) x = 300;
    if (x > 300) x = 0;
    if (y < 0) y = 300;
    if (y > 300) y = 0;
  }
}

// Painter per le particelle
class ParticlePainter extends CustomPainter {
  final List<ParticlePoint> particles;
  final double animationValue;
  final bool isPlaying;
  
  ParticlePainter({
    required this.particles,
    required this.animationValue,
    required this.isPlaying,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // Centro del cerchio
    final center = Offset(size.width / 2, size.height / 2);
    
    // Disegna le particelle
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill;
      
      // Calcola la posizione relativa al centro
      final position = Offset(
        center.dx - 150 + particle.x, 
        center.dy - 150 + particle.y
      );
      
      // Disegna solo se è in riproduzione
      if (isPlaying) {
        double particleSize = particle.size * (0.8 + animationValue * 0.4);
        canvas.drawCircle(position, particleSize, paint);
      }
    }
    
    // Disegna linee tra le particelle vicine
    if (isPlaying) {
      final linePaint = Paint()
        ..color = Colors.white.withOpacity(0.1)
        ..strokeWidth = 0.5;
      
      for (int i = 0; i < particles.length; i++) {
        for (int j = i + 1; j < particles.length; j++) {
          final p1 = particles[i];
          final p2 = particles[j];
          
          // Calcola la distanza tra le particelle
          final distance = sqrt(
            pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2)
          );
          
          // Disegna linee solo tra particelle vicine
          if (distance < 50) {
            final op1 = Offset(
              center.dx - 150 + p1.x, 
              center.dy - 150 + p1.y
            );
            final op2 = Offset(
              center.dx - 150 + p2.x, 
              center.dy - 150 + p2.y
            );
            
            // Opacità basata sulla distanza
            final opacity = 0.1 - (distance / 50) * 0.1;
            linePaint.color = Colors.white.withOpacity(opacity);
            
            canvas.drawLine(op1, op2, linePaint);
          }
        }
      }
    }
  }
  
  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}