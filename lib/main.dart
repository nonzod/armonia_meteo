import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ArmoniaMeteoApp());
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