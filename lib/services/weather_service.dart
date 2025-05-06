import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/weather_model.dart';

class WeatherService {
  static const String baseUrl = 'https://api.open-meteo.com/v1/forecast';

  // Richiede i permessi di localizzazione
  Future<bool> requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verifica se i servizi di localizzazione sono abilitati
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  // Ottiene la posizione corrente
  Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) return null;
      
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );
    } catch (e) {
      print('Errore nel recupero della posizione: $e');
      return null;
    }
  }

  // lib/services/weather_service.dart - gestiamo meglio i casi in cui i dati potrebbero essere nulli
  Future<WeatherData?> getWeatherData() async {
    try {
      final position = await getCurrentLocation();
      if (position == null) return null;

      final response = await http.get(Uri.parse(
        '$baseUrl?latitude=${position.latitude}&longitude=${position.longitude}&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m'
      ));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Verifica che i campi necessari esistano
        if (data['current'] == null) return null;
        
        try {
          return WeatherData.fromJson(data);
        } catch (e) {
          print('Errore nel parsing dei dati: $e');
          return null;
        }
      }
      return null;
    } catch (e) {
      print('Errore nel recupero dei dati meteo: $e');
      return null;
    }
  }
}