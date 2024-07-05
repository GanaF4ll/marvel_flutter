import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'dart:ui';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ComicDetailScreen extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String description;
  final int comicId;

  const ComicDetailScreen({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.comicId,
  });

  @override
  _ComicDetailScreenState createState() => _ComicDetailScreenState();
}

class _ComicDetailScreenState extends State<ComicDetailScreen> {
  List<String> characterImageUrls = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCharacterImages();
  }

  void fetchCharacterImages() async {
    final publicKey = dotenv.env['PUBLIC_KEY'];
    final privateKey = dotenv.env['PRIVATE_KEY'];

    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final hash = generateMd5('$timestamp$privateKey$publicKey');

    final url = Uri.parse(
      'https://gateway.marvel.com/v1/public/comics/${widget.comicId}/characters?ts=$timestamp&apikey=$publicKey&hash=$hash',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['data']['results'];

      setState(() {
        characterImageUrls = results.map<String>((character) {
          final thumbnail = character['thumbnail'];
          return '${thumbnail['path']}.${thumbnail['extension']}';
        }).toList();
        isLoading = false;
      });
    } else {
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
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    widget.imageUrl,
                    fit: BoxFit.cover,
                    height: 400,
                    width: double.infinity,
                  ),
                ),
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),
                      Container(
                        alignment: Alignment.center,
                        child: const Text(
                          'Comics details:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            widget.imageUrl,
                            fit: BoxFit.cover,
                            width: 250,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.description.isNotEmpty
                        ? widget.description
                        : 'No description available',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : characterImageUrls.isNotEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Characters:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                buildCharacterCarousel(),
                              ],
                            )
                          : const Text(
                              'No characters available',
                              style: TextStyle(color: Colors.white),
                            ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCharacterCarousel() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: SizedBox(
        height: 150,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: characterImageUrls.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  characterImageUrls[index],
                  fit: BoxFit.cover,
                  width: 100,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
