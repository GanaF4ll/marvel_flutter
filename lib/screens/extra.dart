import 'package:flutter/material.dart';

class ExtraScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Extra Screen'),
      ),
      body: Center(
        child: Text(
          'This is the Extra Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
