import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Importeremo questi file quando li creeremo
// import 'providers/weather_provider.dart';
// import 'providers/audio_provider.dart';
// import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Carica le variabili d'ambiente (.env)
  await dotenv.load();
  
  runApp(const ArmoniaMeteoApp());
}

class ArmoniaMeteoApp extends StatelessWidget {
  const ArmoniaMeteoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Armonia Meteo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Armonia Meteo'),
        ),
        body: const Center(
          child: Text(
            'Benvenuto in Armonia Meteo!',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}