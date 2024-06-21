import 'package:flutter/material.dart';

class ComicWidget extends StatelessWidget {
  final String imageUrl;
  final int id;

  const ComicWidget({
    super.key,
    required this.imageUrl,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Card(
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                imageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.fill,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
