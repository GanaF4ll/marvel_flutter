import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import './navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
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
        scaffoldBackgroundColor: Colors.grey.shade900,
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
