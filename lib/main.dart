import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const NumberBubbleApp());
}

class NumberBubbleApp extends StatelessWidget {
  const NumberBubbleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Number Bubble',
      debugShowCheckedModeBanner: false, // Removes the red debug banner
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}