// components/comicWidget.dart
import 'package:flutter/material.dart';

class ComicWidget extends StatelessWidget {
  final String imageUrl;
  final int id;
  final String title;
  final String description;
  final VoidCallback onTap;

  const ComicWidget({
    Key? key,
    required this.imageUrl,
    required this.id,
    required this.title,
    required this.description,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        child: ClipRRect(
          child: AspectRatio(
            aspectRatio: 1,
            child: Image.network(
              imageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.fitHeight,
            ),
          ),
        ),
      ),
    );
  }
}
