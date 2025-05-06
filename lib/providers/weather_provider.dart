import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  WeatherData? _weatherData;
  bool _isLoading = false;
  String? _error;

  WeatherData? get weatherData => _weatherData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchWeatherData() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final data = await _weatherService.getWeatherData();
      if (data != null) {
        _weatherData = data;
        _error = null;
      } else {
        _error = "Impossibile recuperare i dati meteo";
      }
    } catch (e) {
      _error = "Errore: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}