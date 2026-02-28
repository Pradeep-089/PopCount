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
          seedColor: const Color(0xFF2196F3),
          primary: const Color(0xFF2196F3),
          secondary: const Color(0xFFF06292),
        ),
        // Child-friendly rounded font with improved contrast
        textTheme: GoogleFonts.baloo2TextTheme().copyWith(
          displayLarge: GoogleFonts.baloo2(
            color: const Color(0xFF1A1A1A),
            fontWeight: FontWeight.w900,
          ),
          bodyLarge: GoogleFonts.baloo2(
            color: const Color(0xFF2D2D2D),
          ),
          bodyMedium: GoogleFonts.baloo2(
            color: const Color(0xFF555555),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
