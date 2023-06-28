import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'chistes_screen.dart';

Future<void> main() async {
  await dotenv.load();
  runApp(ChistesApp());
}

class ChistesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chistes para niños',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChistesScreen(),
    );
  }
}
