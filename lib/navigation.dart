import 'package:flutter/material.dart';
import './screens/home.dart';
import './screens/character.dart';
import './screens/comics.dart';
import './screens/extra.dart';

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
    ComicScreen(),
    ExtraScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screenList[_currentScreen],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentScreen,
        onTap: onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Character',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Comics',
          ),
          BottomNavigationBarItem(

            icon: Icon(Icons.add_circle),
            label: 'Extra',
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
