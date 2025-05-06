class WeatherData {
  final double temperature;
  final int weatherCode;
  final double windSpeed;
  final int humidity;
  final String condition;

  WeatherData({
    required this.temperature,
    required this.weatherCode,
    required this.humidity,
    required this.windSpeed,
    required this.condition,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: json['current']['temperature_2m'].toDouble(),
      weatherCode: json['current']['weather_code'],
      humidity: json['current']['relative_humidity_2m'].toInt(),
      windSpeed: json['current']['wind_speed_10m'].toDouble(),
      condition: _mapWeatherCodeToCondition(json['current']['weather_code']),
    );
  }

  static String _mapWeatherCodeToCondition(int code) {
    if (code == 0) return 'Sereno';
    if (code == 1 || code == 2 || code == 3) return 'Parzialmente nuvoloso';
    if (code >= 45 && code <= 48) return 'Nebbia';
    if (code >= 51 && code <= 67) return 'Pioggia';
    if (code >= 71 && code <= 77) return 'Neve';
    if (code >= 80 && code <= 82) return 'Pioggia leggera';
    if (code >= 85 && code <= 86) return 'Neve intensa';
    if (code >= 95 && code <= 99) return 'Temporale';
    return 'Sconosciuto';
  }
}