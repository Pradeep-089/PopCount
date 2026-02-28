import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const PopCountApp());
}

class PopCountApp extends StatelessWidget {
  const PopCountApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PopCount',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}
