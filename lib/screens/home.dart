import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:http/http.dart' as http;

import '../components/characterSuggestion.dart';
import '../components/eventSuggestion.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> characters = [];
  List<Map<String, dynamic>> events = [];
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
      fetchEventsByIds([
        227, // Age of Apocalypse
        314, // Age of Ultron
        229, // Annhilation
        310, // Avengers VS X-men
        238, // Civil War
        330, // Civil War II
      ]);
    });
  }

  Future<void> loadEnv() async {
    await dotenv.load(); // Load environment variables
  }

  Future<void> fetchCharactersByIds(List<int> ids) async {
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
        // print(results);
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

  Future<void> fetchEventsByIds(List<int> ids) async {
    setState(() {
      isLoading = true;
    });

    List<Map<String, dynamic>> allEvents = [];

    for (var id in ids) {
      final publicKey = dotenv.env['PUBLIC_KEY'];
      final privateKey = dotenv.env['PRIVATE_KEY'];

      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final hash = generateMd5('$timestamp$privateKey$publicKey');

      final url = Uri.parse(
          'https://gateway.marvel.com:443/v1/public/events/$id?ts=$timestamp&apikey=$publicKey&hash=$hash');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['data']['results'];
        allEvents.addAll(List<Map<String, dynamic>>.from(results));
        print(results);
      } else {
        print('Failed to load events');
      }
    }

    setState(() {
      events = allEvents;
      isLoading = false;
    });
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
                        const Text(
                          'Character Suggestions',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
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
                  Container(
                    height: 320,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Event Suggestions',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: events.length,
                            itemBuilder: (context, index) {
                              final event = events[index];
                              final name = event['name'];
                              final imageUrl =
                                  "${event['thumbnail']['path']}.${event['thumbnail']['extension']}";

                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: EventSuggestion(
                                  title: event['title'],
                                  imageUrl: imageUrl,
                                  id: event['id'],
                                  description: event['description'] ??
                                      'No description available.',
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
