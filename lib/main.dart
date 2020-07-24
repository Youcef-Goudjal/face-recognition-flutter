import 'screens/home.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Face Recognition",
      theme: ThemeData(
        brightness: Brightness.dark,
        accentColor: Colors.deepPurple,
      ),

      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}
