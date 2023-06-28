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

  List<String> selectedTemas = [];
  String chisteGenerado = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chistes para niños'),
      ),
      body: Container(
        color: Colors.lightGreen, // Cambia el color de fondo a uno pastel
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Wrap(
                spacing: 10,
                children: temas.map((tema) {
                  final isSelected = selectedTemas.contains(tema);
                  return Padding(
                    padding:
                        EdgeInsets.all(10), // Agrega un margen de 10 píxeles
                    child: SizedBox(
                      width: 150, // Cambia el ancho del botón
                      height: 60, // Cambia la altura del botón
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
                onPressed: generarChiste,
                child: Text('Generar chiste'),
              ),
              SizedBox(height: 20),
              Container(
                color: Colors.white, // Cambia el fondo del contenedor a blanco
                padding: EdgeInsets.all(20),
                child: Text(
                  chisteGenerado,
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
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
      if (selectedTemas.contains(tema)) {
        selectedTemas.remove(tema);
      } else {
        if (selectedTemas.length < 5) {
          selectedTemas.add(tema);
        } else {
          // Muestra un diálogo o notificación si se alcanza el límite de selecciones
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Límite de selecciones alcanzado'),
                content: Text('Ya has seleccionado 5 temas.'),
                actions: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      }
    });
  }

  Future<String> obtenerChiste(String tema) async {
    final apiKey = dotenv.env['API_KEY'];
    final url = 'https://api.openai.com/v1/chat/completions';

    // final response = await http.post(
    //   Uri.parse(url),
    //   headers: {
    //     'Authorization': 'Bearer $apiKey',
    //     'Content-Type': 'application/json',
    //   },
    //   body: '''
    //     {
    //       "prompt": "Genera un chiste para niños sobre $tema",
    //       "max_tokens": 50,
    //       'model': 'gpt-3.5-turbo'
    //     }
    //   ''',
    // );
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
          "content": "Genera un chiste para niños sobre $tema"
        }
      ],
      "max_tokens": 50,
      "model": "gpt-3.5-turbo"
    }
  ''',
    );
    print(response.body);

    if (response.statusCode == 200) {
      final jsonResponse = response.body;
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

  void generarChiste() async {
    if (selectedTemas.isNotEmpty) {
      try {
        String tema = selectedTemas.join(', ');
        print('(---------------------------------------)');
        print(tema);
        final chiste = await obtenerChiste(tema);
        setState(() {
          chisteGenerado = chiste;
        });
      } catch (e) {
        setState(() {
          chisteGenerado = 'Error al obtener el chiste.';
        });
      }
    } else {
      setState(() {
        chisteGenerado =
            'Selecciona al menos un tema antes de generar un chiste.';
      });
    }
  }
}