import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart' as crypto;
import '../components/comicWidget.dart';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../screens/child-pages/comicsDetails.dart';

class ComicScreen extends StatefulWidget {
  @override
  _ComicScreenState createState() => _ComicScreenState();
}

class _ComicScreenState extends State<ComicScreen> {
  List<Map<String, dynamic>> comics = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  List<String> suggestions = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    dotenv.load().then((_) {
      fetchAllComics();
    });
  }

  void fetchAllComics() async {
    final publicKey = dotenv.env['PUBLIC_KEY'];
    final privateKey = dotenv.env['PRIVATE_KEY'];

    if (publicKey == null || privateKey == null) {
      print('API keys are missing');
      return;
    }

    print('Public Key: $publicKey');
    print('Private Key: $privateKey');

    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final hash = generateMd5('$timestamp$privateKey$publicKey');

    final url = Uri.https('gateway.marvel.com', '/v1/public/comics', {
      'limit': '100',
      'ts': timestamp,
      'apikey': publicKey,
      'hash': hash,
    });

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['data']['results'];
      setState(() {
        comics = List<Map<String, dynamic>>.from(results)
            .where((comic) =>
                !comic['thumbnail']['path'].contains('image_not_available'))
            .toList();
        isLoading = false;
      });
    } else {
      print(
          'Failed to load comics: ${response.statusCode} ${response.reasonPhrase}');
      setState(() {
        isLoading = false;
      });
    }
  }

  void fetchComicSuggestions(String query) async {
    final publicKey = dotenv.env['PUBLIC_KEY'];
    final privateKey = dotenv.env['PRIVATE_KEY'];

    if (publicKey == null || privateKey == null) {
      print('API keys are missing');
      return;
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final hash = generateMd5('$timestamp$privateKey$publicKey');

    final url = Uri.parse(
        'https://gateway.marvel.com/v1/public/comics?titleStartsWith=${Uri.encodeQueryComponent(query)}&limit=10&ts=$timestamp&apikey=$publicKey&hash=$hash');

    print('Fetching comic suggestions with URL: $url');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['data']['results'];
      setState(() {
        suggestions =
            List<String>.from(results.map((comic) => comic['title'] as String));
      });
    } else {
      print(
          'Failed to load comic suggestions: ${response.statusCode} ${response.reasonPhrase}');
      print('Response body: ${response.body}');
    }
  }

  void fetchComicsByTitle(String title) async {
    final publicKey = dotenv.env['PUBLIC_KEY'];
    final privateKey = dotenv.env['PRIVATE_KEY'];

    if (publicKey == null || privateKey == null) {
      print('API keys are missing');
      return;
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final hash = generateMd5('$timestamp$privateKey$publicKey');

    final encodedTitle = Uri.encodeQueryComponent(title);

    final url = Uri.https('gateway.marvel.com', '/v1/public/comics', {
      'titleStartsWith': encodedTitle,
      'limit': '100',
      'ts': timestamp,
      'apikey': publicKey,
      'hash': hash,
    });

    print('Fetching comics by title with URL: $url');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['data']['results'];
      setState(() {
        comics = List<Map<String, dynamic>>.from(results)
            .where((comic) =>
                !comic['thumbnail']['path'].contains('image_not_available'))
            .toList();
        isLoading = false;
      });
    } else {
      print(
          'Failed to load comics: ${response.statusCode} ${response.reasonPhrase}');
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
                                  fetchComicSuggestions(textEditingValue.text);
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
                                fetchComicsByTitle(selection);
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
                                  onSubmitted: (String value) {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    fetchComicsByTitle(value);
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Search Comics',
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
                                        fetchComicsByTitle(
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
                                fetchAllComics();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 4.0,
                          mainAxisSpacing: 4.0,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: comics.length,
                        itemBuilder: (context, index) {
                          final comic = comics[index];
                          final thumbnail = comic['thumbnail'];
                          final imageUrl =
                              '${thumbnail['path']}.${thumbnail['extension']}';

                          return ComicWidget(
                            title: comic['title'],
                            description: comic['description'] ??
                                'No description available for ${comic['title']}',
                            imageUrl: imageUrl,
                            id: comic['id'],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ComicDetailScreen(
                                    imageUrl: imageUrl,
                                    title: comic['title'],
                                    description: comic['description'] ??
                                        'No description available for ${comic['title']}',
                                    comicId: comic['id'],
                                  ),
                                ),
                              );
                            },
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
