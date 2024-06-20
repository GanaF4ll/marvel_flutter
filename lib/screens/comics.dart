import 'package:flutter/material.dart';

class ComicScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comic Screen'),
      ),
      body: Center(
        child: Text(
          'Welcome to the Comic Screen!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
