import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart' as crypto;

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Accueil'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bienvenue sur l\'écran d\'accueil!',
              style: TextStyle(fontSize: 24),
            ),
            ElevatedButton(
              onPressed: fetchMarvelCharacters,
              child: Text('Fetch Characters'),
            ),
          ],
        ),
      ),
    );
  }
}

void fetchMarvelCharacters() async {
  // Charger les variables d'environnement
  // final publicKey = dotenv.env['PUBLIC_KEY'];
  // final privateKey = dotenv.env['PRIVATE_KEY'];
  final publicKey = 'f3b8273d94ceecaa06c3797595dd1392';
  final privateKey = '0f6d9c527a7147c280ad07578543cd99b6ebb1b4';

  final timestamp = DateTime.now().millisecondsSinceEpoch;

  final hash = generateMd5('$timestamp$privateKey$publicKey');

  final url = Uri.parse(
      'https://gateway.marvel.com/v1/public/characters?ts=$timestamp&apikey=$publicKey&hash=$hash');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    // Décoder la réponse JSON
    final data = jsonDecode(response.body);

    // Accéder au champ results de data
    final results = data['data']['results'];
    print('results: $results');
  } else {
    print('Failed to load characters');
  }
  print('Failed to load characters');
}

String generateMd5(String data) {
  var content = new Utf8Encoder().convert(data);
  var md5 = crypto.md5;
  var digest = md5.convert(content);
  return hex.encode(digest.bytes);
}
