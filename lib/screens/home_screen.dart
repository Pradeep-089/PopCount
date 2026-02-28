import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool isSoundEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSoundPreference();
  }

  Future<void> _loadSoundPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isSoundEnabled = prefs.getBool('isSoundEnabled') ?? true;
    });
  }

  Future<void> _toggleSound() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isSoundEnabled = !isSoundEnabled;
      prefs.setBool('isSoundEnabled', isSoundEnabled);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedBackground(
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
                      
                      const SizedBox(height: 60),

                      // Start Button
                      _StartGameButton(
                        onPressed: selectedLevel == null ? null : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GameScreen(levelConfig: selectedLevel!),
                            ),
                          ).then((_) => setState(() => selectedLevel = null));
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Sound Toggle Icon Button (Top Right)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  isSoundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: _toggleSound,
              ),
            ),
          ),

          // Mascot
          const Positioned(
            bottom: 30,
            right: 30,
            child: MascotBubble(),
          ),
        ],
      ),
    );
  }

  void _onLevelSelected(LevelConfig level) {
    setState(() {
      selectedLevel = level;
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

class _StartGameButton extends StatefulWidget {
  final VoidCallback? onPressed;
  const _StartGameButton({this.onPressed});

  @override
  State<_StartGameButton> createState() => _StartGameButtonState();
}

class _StartGameButtonState extends State<_StartGameButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.9 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onPressed?.call();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 80,
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: widget.onPressed != null ? Colors.greenAccent.shade700 : Colors.grey.shade400,
            borderRadius: BorderRadius.circular(40),
            boxShadow: widget.onPressed != null ? [
              BoxShadow(
                color: Colors.greenAccent.shade700.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ] : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 45),
              const SizedBox(width: 10),
              const Text(
                'START GAME',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MascotBubble extends StatefulWidget {
  const MascotBubble({super.key});

  @override
  State<MascotBubble> createState() => _MascotBubbleState();
}

class _MascotBubbleState extends State<MascotBubble> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _floatAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.15),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _floatAnimation,
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Let's count together! 😊", textAlign: TextAlign.center),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              width: 200,
              duration: const Duration(seconds: 1),
            ),
          );
        },
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [Colors.blue.shade300, Colors.blue.shade700],
              center: const Alignment(-0.3, -0.3),
            ),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5)),
            ],
          ),
          child: const Center(
            child: Icon(Icons.sentiment_satisfied_alt_rounded, color: Colors.white, size: 45),
          ),
        ),
      ),
    );
  }
}
