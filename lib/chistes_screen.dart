import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ChistesScreen extends StatefulWidget {
  @override
  _ChistesScreenState createState() => _ChistesScreenState();
}

class _ChistesScreenState extends State<ChistesScreen> {
  final List<String> temas = [
    'animales',
    'comida',
    'deportes',
    'profesiones',
    'transporte',
    'naturaleza',
    'escuela',
    'superhéroes',
    'cuentos',
    'viajes'
  ];

  String selectedTema = '';
  List<String> chistesGenerados = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chistes para niños'),
      ),
      body: Container(
        color: Colors.lightGreen,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Wrap(
                spacing: 10,
                children: temas.map((tema) {
                  final isSelected = selectedTema == tema;
                  return Padding(
                    padding: EdgeInsets.all(10),
                    child: SizedBox(
                      width: 150,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () => selectTema(tema),
                        child: Text(
                          tema,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            isSelected ? Colors.blue : Colors.grey[300]!,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: generarChistes,
                child: Text('Generar chistes'),
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: chistesGenerados.length,
                  itemBuilder: (context, index) {
                    return Container(
                      color: Colors.white,
                      padding: EdgeInsets.all(20),
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        children: [
                          SizedBox(height: 10),
                          Text(
                            chistesGenerados[index],
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
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

  void selectTema(String tema) {
    setState(() {
      selectedTema = tema;
    });
  }

  Future<String> obtenerChiste(String tema) async {
    final apiKey = dotenv.env['API_KEY'];
    final url = 'https://api.openai.com/v1/chat/completions';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: '''
    {
      "messages": [
        {
          "role": "user",
          "content": "Genera 5 chiste para niños sobre $tema"
        }
      ],
      "max_tokens": 500,
      "model": "gpt-3.5-turbo"
    }
  ''',
    );
    print(response.body);

    if (response.statusCode == 200) {
      final jsonResponse = utf8.decode(response.bodyBytes);
      final chisteGenerado = extractChiste(jsonResponse);
      return chisteGenerado;
    } else {
      throw Exception('Error al obtener el chiste: ${response.statusCode}');
    }
  }

  String extractChiste(String jsonResponse) {
    final jsonMap = json.decode(jsonResponse);
    final choices = jsonMap['choices'];
    final chiste = choices[0]['message']['content'].toString();
    return chiste;
  }

  void generarChistes() async {

    if (selectedTema.isNotEmpty) {
      try {
        String tema = selectedTema;
        chistesGenerados.clear();
        print('(---------------------------------------)');
        print(tema);
        final chiste = await obtenerChiste(tema);
        setState(() {
          chistesGenerados.add(chiste);
        });
      } catch (e) {
        setState(() {
          chistesGenerados.add('Error al obtener el chiste.');
          'Error al obtener el chiste.';
        });
      }
    } else {
      setState(() {
        chistesGenerados
            .add('Selecciona al menos un tema antes de generar un chiste.');
      });
    }
    //}
  }
}