// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'meditation_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.lightBlue, Colors.blue],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Titolo app
              const Text(
                'Armonia Meteo',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              // Widget condizioni meteo
              _buildWeatherDisplay(),
              const SizedBox(height: 40),
              // Widget selezione durata
              _buildDurationSelector(),
              const Spacer(),
              // Pulsante per iniziare meditazione
              _buildStartButton(context),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherDisplay() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud, size: 80, color: Colors.white),
          const SizedBox(height: 10),
          Text(
            'Nuvoloso',
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
          Text(
            '22°C',
            style: TextStyle(fontSize: 48, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationSelector() {
    return Column(
      children: [
        const Text(
          'Seleziona durata',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _durationOption('5 min'),
            _durationOption('10 min', isSelected: true),
            _durationOption('15 min'),
            _durationOption('20 min'),
          ],
        ),
      ],
    );
  }

  Widget _durationOption(String text, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.blue : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  // In _buildStartButton() di HomeScreen
  Widget _buildStartButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MeditationScreen(durationMinutes: 10),
          ),
        );
      },
      // ... resto del codice rimane invariato
    );
  }
}