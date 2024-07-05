import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart' as crypto;
import '../components/characterWidget.dart';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CharacterScreen extends StatefulWidget {
  @override
  _CharacterScreenState createState() => _CharacterScreenState();
}

class _CharacterScreenState extends State<CharacterScreen> {
  List<Map<String, dynamic>> characters = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  List<String> suggestions = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    fetchAllCharacters();
  }

  void fetchAllCharacters() async {
    final publicKey = dotenv.env['PUBLIC_KEY'];
    final privateKey = dotenv.env['PRIVATE_KEY'];

    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final hash = generateMd5('$timestamp$privateKey$publicKey');

    final url = Uri.parse(
        'https://gateway.marvel.com/v1/public/characters?limit=100&ts=$timestamp&apikey=$publicKey&hash=$hash');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['data']['results'];
      setState(() {
        characters = List<Map<String, dynamic>>.from(results);
        isLoading = false;
      });
    } else {
      print('Failed to load characters');
      setState(() {
        isLoading = false;
      });
    }
  }

  void fetchCharacterSuggestions(String query) async {
    final publicKey = dotenv.env['PUBLIC_KEY'];
    final privateKey = dotenv.env['PRIVATE_KEY'];

    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final hash = generateMd5('$timestamp$privateKey$publicKey');

    final url = Uri.parse(
        'https://gateway.marvel.com/v1/public/characters?nameStartsWith=$query&limit=10&ts=$timestamp&apikey=$publicKey&hash=$hash');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['data']['results'];
      setState(() {
        suggestions = List<String>.from(
            results.map((character) => character['name'] as String));
      });
    } else {
      print('Failed to load character suggestions');
    }
  }

  void fetchCharactersByName(String name) async {
    final publicKey = dotenv.env['PUBLIC_KEY'];
    final privateKey = dotenv.env['PRIVATE_KEY'];

    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final hash = generateMd5('$timestamp$privateKey$publicKey');

    final url = Uri.parse(
        'https://gateway.marvel.com/v1/public/characters?nameStartsWith=$name&limit=100&ts=$timestamp&apikey=$publicKey&hash=$hash');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['data']['results'];
      setState(() {
        characters = List<Map<String, dynamic>>.from(results);
        isLoading = false;
      });
    } else {
      print('Failed to load characters');
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
      body: SafeArea(
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator(
                  color: Color.fromARGB(255, 250, 0, 0))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Autocomplete<String>(
                              optionsBuilder:
                                  (TextEditingValue textEditingValue) {
                                if (textEditingValue.text.isEmpty) {
                                  return const Iterable<String>.empty();
                                }
                                if (_debounce?.isActive ?? false)
                                  _debounce?.cancel();
                                _debounce = Timer(
                                    const Duration(milliseconds: 100), () {
                                  fetchCharacterSuggestions(
                                      textEditingValue.text);
                                });
                                return suggestions.where((String option) {
                                  return option.toLowerCase().contains(
                                      textEditingValue.text.toLowerCase());
                                });
                              },
                              onSelected: (String selection) {
                                _searchController.text = selection;
                                setState(() {
                                  isLoading = true;
                                });
                                fetchCharactersByName(selection);
                              },
                              fieldViewBuilder: (BuildContext context,
                                  TextEditingController
                                      fieldTextEditingController,
                                  FocusNode fieldFocusNode,
                                  VoidCallback onFieldSubmitted) {
                                _searchController.text =
                                    fieldTextEditingController.text;
                                return TextField(
                                  controller: fieldTextEditingController,
                                  focusNode: fieldFocusNode,
                                  decoration: InputDecoration(
                                    hintText: 'Search Characters',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    suffixIcon: IconButton(
                                      icon: const Icon(Icons.search),
                                      onPressed: () {
                                        setState(() {
                                          isLoading = true;
                                        });
                                        fetchCharactersByName(
                                            fieldTextEditingController.text);
                                      },
                                    ),
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 10.0),
                                  ),
                                  style: TextStyle(color: Colors.black),
                                );
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 3, 44, 104),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.close),
                              color: Colors.white,
                              onPressed: () {
                                setState(() {
                                  isLoading = true;
                                });
                                _searchController.clear();
                                fetchAllCharacters();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: characters.length,
                        itemBuilder: (context, index) {
                          final character = characters[index];
                          final thumbnail = character['thumbnail'];
                          final imageUrl =
                              '${thumbnail['path']}.${thumbnail['extension']}';
                          return CharacterWidget(
                            name: character['name'],
                            description: character['description'] ??
                                'No description available for ${character['name']}',
                            imageUrl: imageUrl,
                            id: character['id'],
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
