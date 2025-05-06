import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../utils/weather_utils.dart';
import 'meditation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedDuration = 10;

  @override
  void initState() {
    super.initState();
    // Carica i dati meteo quando la schermata si apre
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WeatherProvider>(context, listen: false).fetchWeatherData();
    });
  }

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
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        if (weatherProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (weatherProvider.error != null) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(Icons.error_outline, size: 80, color: Colors.white),
                const SizedBox(height: 10),
                Text('Impossibile caricare i dati meteo',
                    style: TextStyle(fontSize: 18, color: Colors.white)),
                TextButton(
                  onPressed: () => weatherProvider.fetchWeatherData(),
                  child: Text('Riprova', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }

        final weatherData = weatherProvider.weatherData;
        if (weatherData == null) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(Icons.cloud_queue, size: 80, color: Colors.white),
                const SizedBox(height: 10),
                Text('Dati meteo non disponibili',
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Icon(
                WeatherUtils.getWeatherIcon(weatherData.weatherCode),
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 10),
              Text(
                weatherData.condition,
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
              Text(
                '${weatherData.temperature.toStringAsFixed(1)}°C',
                style: TextStyle(fontSize: 48, color: Colors.white),
              ),
              Text(
                'Umidità: ${weatherData.humidity}% | Vento: ${weatherData.windSpeed} km/h',
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ],
          ),
        );
      },
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
            _durationOption('5 min', 5),
            _durationOption('10 min', 10),
            _durationOption('15 min', 15),
            _durationOption('20 min', 20),
          ],
        ),
      ],
    );
  }

  Widget _durationOption(String text, int minutes) {
    bool isSelected = _selectedDuration == minutes;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDuration = minutes;
        });
      },
      child: Container(
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
      ),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MeditationScreen(durationMinutes: _selectedDuration),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: const Text(
        'Inizia Meditazione',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}