// lib/main.dart (modificato)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'providers/weather_provider.dart';
import 'providers/music_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => MusicProvider()),
      ],
      child: const ArmoniaMeteoApp(),
    ),
  );
}

class ArmoniaMeteoApp extends StatelessWidget {
  const ArmoniaMeteoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Armonia Meteo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}