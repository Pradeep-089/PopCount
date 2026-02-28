import 'package:flutter/material.dart';
import 'game_screen.dart';
import '../utils/Constants.dart';
import '../models/level_config.dart';
import '../widgets/animated_background.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LevelConfig? selectedLevel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Title
                  const Text(
                    'PopCount',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      shadows: [
                        Shadow(color: Colors.black45, offset: Offset(4, 4), blurRadius: 10),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Tap the numbers in order!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 60),

                  // Difficulty Buttons
                  _DifficultyButton(
                    level: GameConstants.levels[0],
                    emoji: '🟢',
                    color: Colors.greenAccent,
                    isSelected: selectedLevel == GameConstants.levels[0],
                    onTap: () => _onLevelSelected(GameConstants.levels[0]),
                  ),
                  const SizedBox(height: 20),
                  _DifficultyButton(
                    level: GameConstants.levels[1],
                    emoji: '🟡',
                    color: Colors.orangeAccent,
                    isSelected: selectedLevel == GameConstants.levels[1],
                    onTap: () => _onLevelSelected(GameConstants.levels[1]),
                  ),
                  const SizedBox(height: 20),
                  _DifficultyButton(
                    level: GameConstants.levels[2],
                    emoji: '🔵',
                    color: Colors.blueAccent,
                    isSelected: selectedLevel == GameConstants.levels[2],
                    onTap: () => _onLevelSelected(GameConstants.levels[2]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onLevelSelected(LevelConfig level) {
    setState(() {
      selectedLevel = level;
    });
    
    // Slight delay to allow animation to show before transition
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameScreen(levelConfig: level),
          ),
        ).then((_) => setState(() => selectedLevel = null)); // Reset selection when coming back
      }
    });
  }
}

class _DifficultyButton extends StatelessWidget {
  final LevelConfig level;
  final String emoji;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _DifficultyButton({
    required this.level,
    required this.emoji,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isSelected ? 1.05 : 1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 85,
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: isSelected ? Colors.white : Colors.transparent,
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isSelected ? 0.4 : 0.2),
                blurRadius: isSelected ? 15 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              children: [
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    level.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.play_arrow_rounded,
                  color: isSelected ? Colors.white : Colors.black26,
                  size: 40,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
