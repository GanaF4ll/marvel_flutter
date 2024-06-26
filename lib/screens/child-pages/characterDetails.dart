// screens/characterDetails.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:marvel_flutter/screens/child-pages/comicsDetails.dart';
import '../../components/comicWidget.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CharacterDetailScreen extends StatefulWidget {
  final String name;
  final String description;
  final String imageUrl;
  final int id;

  const CharacterDetailScreen({
    Key? key,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.id,
  }) : super(key: key);

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
    final publicKey = dotenv.env['PUBLIC_KEY'];
    final privateKey = dotenv.env['PRIVATE_KEY'];

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
                        : 'No description available for ${widget.name}',
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
                              final title = comic['title'];
                              final description = comic['description'] ??
                                  'No description available';

                              return ComicWidget(
                                imageUrl: imageUrl,
                                id: comic['id'],
                                title: title,
                                description: description,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ComicDetailScreen(
                                        imageUrl: imageUrl,
                                        title: title,
                                        description: description,
                                        comicId: comic[
                                            'id'], // Pass the comic ID here
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        )
                      : Text(
                          'No comics available',
                          style: TextStyle(color: Colors.white),
                        ),
                ],
              ),
            ),
    );
  }
}
