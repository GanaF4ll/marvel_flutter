import 'package:flutter/material.dart';
import '../components/characterSuggestion.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> characters = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadEnv().then((_) {
      fetchCharactersByIds([
        1016181, // Spider-Man
        1009663, // Agent Venom
        1009629, // Storm
        1009318, // Ghost Rider
        1009592, // Silver Surfer
        1009417, // Magneto
        1009187, // Black Panther
        1009368, // Iron Man
        1009652, // Thanos
        1009268, // Deadpool
      ]);
    });
  }

  Future<void> loadEnv() async {
    await dotenv.load(); // Load environment variables
  }

  void fetchCharactersByIds(List<int> ids) async {
    setState(() {
      isLoading = true;
    });

    List<Map<String, dynamic>> allCharacters = [];

    for (var id in ids) {
      final publicKey = dotenv.env['PUBLIC_KEY'];
      final privateKey = dotenv.env['PRIVATE_KEY'];

      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final hash = generateMd5('$timestamp$privateKey$publicKey');

      final url = Uri.parse(
          'https://gateway.marvel.com/v1/public/characters/$id?ts=$timestamp&apikey=$publicKey&hash=$hash');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['data']['results'];
        allCharacters.addAll(List<Map<String, dynamic>>.from(results));
        print(results);
      } else {
        print('Failed to load character');
      }
    }

    setState(() {
      characters = allCharacters;
      isLoading = false;
    });
  }

  String generateMd5(String data) {
    var content = new Utf8Encoder().convert(data);
    var md5 = crypto.md5;
    var digest = md5.convert(content);
    return hex.encode(digest.bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Accueil'),
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 270,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Suggestions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: characters.length,
                            itemBuilder: (context, index) {
                              final character = characters[index];
                              final name = character['name'];
                              final imageUrl =
                                  "${character['thumbnail']['path']}.${character['thumbnail']['extension']}";

                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CharacterSuggestion(
                                  name: name,
                                  imageUrl: imageUrl,
                                  id: character['id'],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
