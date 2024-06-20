import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import './navigation.dart';

void main() async {
  // Assurez-vous d'appeler WidgetsFlutterBinding.ensureInitialized() avant d'utiliser async dans main
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Charger les variables d'environnement
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // Capture l'erreur si le fichier .env n'est pas trouvé ou s'il y a un autre problème
    print('Erreur lors du chargement du fichier .env : $e');
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Montserrat',
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.blue.shade200,
        primarySwatch: Colors.teal,
      ),
      home: Scaffold(
        body: Center(
          child: NavigationScreen(key: UniqueKey()),
        ),
      ),
    );
  }
}
