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

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  LevelConfig? selectedLevel;
  bool isSoundEnabled = true;
  late AnimationController _fadeInController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _loadSoundPreference();
    _fadeInController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
    _fadeInAnimation = CurvedAnimation(parent: _fadeInController, curve: Curves.easeIn);
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
  void dispose() {
    _fadeInController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBackground(child: SizedBox.expand()),
          // Top Overlay Layer for Readability
          IgnorePointer(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Fade-in Logo/Title with Pastel Gradient Effect
                    FadeTransition(
                      opacity: _fadeInAnimation,
                      child: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF42A5F5), Color(0xFFEC407A)],
                        ).createShader(bounds),
                        child: const Text(
                          'PopCount',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 2,
                            shadows: [
                              Shadow(color: Colors.black12, offset: Offset(2, 2), blurRadius: 6),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Tap the numbers in order!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF555555),
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
          
          // Sound Toggle Icon Button (Top Right)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  isSoundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                  color: const Color(0xFF2D2D2D),
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
                color: Colors.black.withOpacity(isSelected ? 0.2 : 0.1),
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
                      color: isSelected ? Colors.white : const Color(0xFF2D2D2D),
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
                color: Colors.greenAccent.shade700.withOpacity(0.3),
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

class _MascotBubbleState extends State<MascotBubble> with TickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<Offset> _floatAnimation;
  late AnimationController _tapController;
  late Animation<double> _scaleAnimation;
  bool _isMessageVisible = false;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _floatAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.1),
    ).animate(CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));

    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _tapController, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _floatController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  void _onTap() {
    _tapController.forward(from: 0);
    setState(() => _isMessageVisible = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isMessageVisible = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      clipBehavior: Clip.none,
      children: [
        // Speech Bubble
        Positioned(
          bottom: 80,
          right: 0,
          child: AnimatedOpacity(
            opacity: _isMessageVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: AnimatedScale(
              scale: _isMessageVisible ? 1.0 : 0.5,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: const Text(
                  "Let's count together! 😊",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Mascot
        SlideTransition(
          position: _floatAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: GestureDetector(
              onTap: _onTap,
              child: Container(
                width: 75,
                height: 75,
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
                  child: Icon(Icons.sentiment_satisfied_alt_rounded, color: Colors.white, size: 50),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
