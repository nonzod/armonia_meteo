import 'package:flutter/material.dart';

class WeatherUtils {
  static IconData getWeatherIcon(int weatherCode) {
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