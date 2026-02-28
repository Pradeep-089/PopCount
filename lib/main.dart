import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          primary: Colors.blueAccent,
          secondary: Colors.pinkAccent,
        ),
        textTheme: GoogleFonts.baloo2TextTheme(), // Child-friendly rounded font
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
