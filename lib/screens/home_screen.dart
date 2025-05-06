// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import './meditation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<int> _durationOptions = [5, 10, 15, 20];
  int _selectedDuration = 10;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    setState(() {
      _isLoading = true;
    });
    
    await Provider.of<WeatherProvider>(context, listen: false).fetchWeatherData();
    
    setState(() {
      _isLoading = false;
    });
  }

  void _startMeditation() {
    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
    
    if (weatherProvider.weatherData != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MeditationScreen(
            durationMinutes: _selectedDuration,
          ),
        ),
      );
    } else {
      // Mostra un messaggio se non ci sono dati meteo
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossibile avviare la meditazione senza dati meteo.'),
          duration: Duration(seconds: 2),
        ),
      );
      
      // Riprova a recuperare i dati meteo
      _fetchWeatherData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Colors.indigo],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Armonia Meteo',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Meditazione in armonia con la natura',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 40),
                _buildWeatherCard(),
                const SizedBox(height: 40),
                _buildDurationSelector(),
                const Spacer(),
                _buildStartButton(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherCard() {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        if (weatherProvider.isLoading || _isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        }

        if (weatherProvider.error != null) {
          return Center(
            child: Column(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Errore: ${weatherProvider.error}',
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _fetchWeatherData,
                  child: const Text('Riprova'),
                ),
              ],
            ),
          );
        }

        final weatherData = weatherProvider.weatherData;
        if (weatherData == null) {
          return const Center(
            child: Text(
              'Nessun dato meteo disponibile',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return Card(
          color: Colors.white.withOpacity(0.2),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${weatherData.temperature.toStringAsFixed(1)}°C',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          weatherData.condition,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      _getWeatherIcon(weatherData.weatherCode),
                      size: 64,
                      color: Colors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildWeatherInfoItem(
                      Icons.water_drop_outlined,
                      '${weatherData.humidity}%',
                      'Umidità',
                    ),
                    _buildWeatherInfoItem(
                      Icons.air,
                      '${weatherData.windSpeed.toStringAsFixed(1)} km/h',
                      'Vento',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeatherInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white70,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildDurationSelector() {
    return Column(
      children: [
        const Text(
          'Durata della meditazione',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _durationOptions.map((duration) {
            final isSelected = duration == _selectedDuration;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDuration = duration;
                });
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Colors.white 
                      : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    '$duration min',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.indigo : Colors.white,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _startMeditation,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.indigo,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Inizia Meditazione',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  IconData _getWeatherIcon(int weatherCode) {
    if (weatherCode == 0) return Icons.wb_sunny;
    if (weatherCode >= 1 && weatherCode <= 3) return Icons.cloud_queue;
    if (weatherCode >= 45 && weatherCode <= 48) return Icons.cloud;
    if (weatherCode >= 51 && weatherCode <= 67) return Icons.umbrella;
    if (weatherCode >= 71 && weatherCode <= 77) return Icons.ac_unit;
    if (weatherCode >= 80 && weatherCode <= 82) return Icons.grain;
    if (weatherCode >= 85 && weatherCode <= 86) return Icons.snowing;
    if (weatherCode >= 95 && weatherCode <= 99) return Icons.thunderstorm;
    return Icons.question_mark;
  }
}