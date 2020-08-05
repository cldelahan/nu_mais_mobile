import 'package:flutter/material.dart';
import 'package:down/HomePage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NuBank',
      theme: ThemeData(
        primaryColor: Color.fromRGBO(158, 27, 209, 1.0),
        secondaryHeaderColor: Color.fromRGBO(158, 27, 209, 0.2),
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage()
    );
  }
}

