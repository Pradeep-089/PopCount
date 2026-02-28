
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../bloc/game_state.dart';
import '../models/level_config.dart';

class ScorecardModal extends StatelessWidget {
  final GameState state;
  final LevelConfig levelConfig;

  const ScorecardModal({super.key, required this.state, required this.levelConfig});

  @override
  Widget build(BuildContext context) {
    if (state is GameWon) {
      return _VictoryModal(state: state as GameWon);
    } else if (state is GameLost) {
      return _LossModal(state: state as GameLost);
    }
    return const SizedBox.shrink();
  }
}

class _VictoryModal extends StatefulWidget {
  final GameWon state;
  const _VictoryModal({required this.state});

  @override
  State<_VictoryModal> createState() => _VictoryModalState();
}

class _VictoryModalState extends State<_VictoryModal> with TickerProviderStateMixin {
  int _starsVisible = 0;
  late AnimationController _textController;

  @override
  void initState() {
    super.initState();
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    // Animate stars one by one
    for (int i = 1; i <= 3; i++) {
      Timer(Duration(milliseconds: i * 500), () {
        if (mounted) setState(() => _starsVisible = i);
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (widget.state.totalTime ~/ 60).toString().padLeft(2, '0');
    final seconds = (widget.state.totalTime % 60).toString().padLeft(2, '0');

    return Stack(
      children: [
        // Confetti burst placeholder
        const _ConfettiBurst(),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Dialog(
            backgroundColor: Colors.white.withOpacity(0.95),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated Text Header
                  ScaleTransition(
                    scale: Tween(begin: 1.0, end: 1.1).animate(
                      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
                    ),
                    child: Text(
                      widget.state.tier.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Animated 3-Star Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return AnimatedScale(
                        scale: _starsVisible > index ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.elasticOut,
                        child: Icon(
                          Icons.star_rounded,
                          color: Colors.amber.shade600,
                          size: 70,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  
                  Text(
                    'Time: $minutes:$seconds',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const Divider(height: 40, thickness: 2),
                  
                  // Green Try Again Button
                  SizedBox(
                    width: double.infinity,
                    height: 75,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent.shade700,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                        elevation: 8,
                      ),
                      onPressed: () => Navigator.of(context).pop('play_again'),
                      child: const Text(
                        'PLAY AGAIN',
                        style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Home Secondary Button
                  TextButton(
                    onPressed: () => Navigator.of(context).pop('main_menu'),
                    child: Text(
                      'Home',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LossModal extends StatelessWidget {
  final GameLost state;
  const _LossModal({required this.state});

  @override
  Widget build(BuildContext context) {
    String reason = state.reason == FailureReason.mistakesExceeded 
        ? "Too many oopsies! Let's try again!" 
        : "Oh no! Time's up!";

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        backgroundColor: Colors.white.withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('😮', style: TextStyle(fontSize: 80)),
              const Text(
                'OH NO!',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.orange),
              ),
              const SizedBox(height: 10),
              Text(reason, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 70,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
                  ),
                  onPressed: () => Navigator.of(context).pop('play_again'),
                  child: const Text('TRY AGAIN', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop('main_menu'),
                child: const Text('Main Menu', style: TextStyle(color: Colors.black54, fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfettiBurst extends StatefulWidget {
  const _ConfettiBurst();

  @override
  State<_ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<_ConfettiBurst> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: List.generate(30, (index) {
          final random = Random();
          final left = random.nextDouble();
          final color = Colors.primaries[random.nextInt(Colors.primaries.length)];
          
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final top = MediaQuery.of(context).size.height * _controller.value * (0.3 + random.nextDouble() * 0.7);
              return Positioned(
                top: top - 50,
                left: MediaQuery.of(context).size.width * left,
                child: RotationTransition(
                  turns: _controller,
                  child: Container(
                    width: 10,
                    height: 10,
                    color: color,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
