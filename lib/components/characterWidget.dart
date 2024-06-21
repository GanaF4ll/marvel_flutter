// ignore: file_names
import 'package:flutter/material.dart';
import '../screens/child-pages/characterDetails.dart';

class CharacterWidget extends StatelessWidget {
  final String name;
  final String description;
  final String imageUrl;
  final int id;

  const CharacterWidget({
    super.key,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CharacterDetailScreen(
              name: name,
              description: description,
              imageUrl: imageUrl,
              id: id,
            ),
          ),
        );
      },
      child: Card(
        color: Colors.grey.shade900,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                        // Icon(Icons.star, color: Colors.yellow),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description.isNotEmpty
                          ? description
                          : 'No description available for $name',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
