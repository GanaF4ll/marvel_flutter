import 'package:flutter/material.dart';
import './screens/home.dart';
import './screens/character.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({required Key key}) : super(key: key);
  @override
  _NavigationScreenState createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _currentScreen = 0;
  final List<Widget> _screenList = [
    HomeScreen(),
    CharacterScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marvel Flutter'),
      ),
      body: _screenList[_currentScreen],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentScreen,
        onTap: onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'Character',
          ),
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentScreen = index;
    });
  }
}
