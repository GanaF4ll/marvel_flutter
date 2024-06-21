import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart' as crypto;
import '../../components/comicWidget.dart';

class CharacterDetailScreen extends StatefulWidget {
  final String name;
  final String description;
  final String imageUrl;
  final int id;

  const CharacterDetailScreen({
    super.key,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.id,
  });

  @override
  _CharacterDetailScreenState createState() => _CharacterDetailScreenState();
}

class _CharacterDetailScreenState extends State<CharacterDetailScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> comics = [];

  @override
  void initState() {
    super.initState();
    fetchComicsByCharacterId();
  }

  void fetchComicsByCharacterId() async {
    const publicKey = 'f3b8273d94ceecaa06c3797595dd1392';
    const privateKey = '0f6d9c527a7147c280ad07578543cd99b6ebb1b4';

    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final hash = generateMd5('$timestamp$privateKey$publicKey');

    final url = Uri.parse(
        'https://gateway.marvel.com/v1/public/characters/${widget.id}/comics?limit=10&ts=$timestamp&apikey=$publicKey&hash=$hash');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['data']['results'];
      if (results.isNotEmpty) {
        setState(() {
          comics = List<Map<String, dynamic>>.from(results);
          isLoading = false;
          print('Comics: $comics');
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      print('Failed to load comics');
      setState(() {
        isLoading = false;
      });
    }
  }

  String generateMd5(String data) {
    var content = const Utf8Encoder().convert(data);
    var md5 = crypto.md5;
    var digest = md5.convert(content);
    return hex.encode(digest.bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      widget.imageUrl,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.description.isNotEmpty
                        ? widget.description
                        : 'No description available',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Comics:',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  comics.isNotEmpty
                      ? Expanded(
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.7,
                            ),
                            itemCount: comics.length,
                            itemBuilder: (context, index) {
                              final comic = comics[index];
                              final imageUrl =
                                  '${comic['thumbnail']['path']}.${comic['thumbnail']['extension']}';
                              return ComicWidget(
                                imageUrl: imageUrl,
                                id: comic['id'],
                              );
                            },
                          ),
                        )
                      : Text('No comics available'),
                ],
              ),
            ),
    );
  }
}
