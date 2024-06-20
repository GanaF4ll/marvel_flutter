import 'package:flutter/material.dart';

class CharacterWidget extends StatelessWidget {
  final String name;
  final String description;
  final String imageUrl;

  const CharacterWidget({
    Key? key,
    required this.name,
    required this.description,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(imageUrl),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              description.isNotEmpty ? description : 'No description available',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
