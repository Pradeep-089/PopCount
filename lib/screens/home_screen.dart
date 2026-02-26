import 'package:flutter/material.dart';
import 'game_screen.dart';
import '../utils/Constants.dart';
import '../models/level_config.dart';
import '../widgets/primary_button.dart';
import '../widgets/animated_background.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late LevelConfig selectedLevel;

  @override
  void initState() {
    super.initState();
    selectedLevel = GameConstants.levels[1]; // Default to 'Easy'
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: Center(
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 5,
                  )
                ]
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'NUMBER\nBUBBLE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 40,
                    height: 0.9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 30),
                const Text('SELECT DIFFICULTY', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<LevelConfig>(
                      value: selectedLevel,
                      isExpanded: true,
                      items: GameConstants.levels.map((LevelConfig level) {
                        return DropdownMenuItem<LevelConfig>(
                          value: level,
                          child: Text(level.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        );
                      }).toList(),
                      onChanged: (LevelConfig? newValue) {
                        setState(() {
                          selectedLevel = newValue!;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                PrimaryButton(
                  text: 'START GAME',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GameScreen(levelConfig: selectedLevel),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
