import 'package:flutter/material.dart';
import './navigation.dart';

void main() {
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
