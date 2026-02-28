import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';
import '../models/level_config.dart';
import '../widgets/animated_background.dart';
import '../widgets/scorecard_modal.dart';

class GameScreen extends StatefulWidget {
  final LevelConfig levelConfig;

  const GameScreen({super.key, required this.levelConfig});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _isSoundEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSoundPreference();
  }

  Future<void> _loadSoundPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isSoundEnabled = prefs.getBool('isSoundEnabled') ?? true;
    });
  }

  void _playSuccessSound() {
    if (_isSoundEnabled) {
      debugPrint('Playing Success Sound Placeholder');
    }
  }

  void _playOopsSound() {
    if (_isSoundEnabled) {
      debugPrint('Playing Oops Sound Placeholder');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameBloc()..add(GameStartedEvent(widget.levelConfig)),
      child: Scaffold(
        body: Stack(
          children: [
            const AnimatedBackground(child: SizedBox.expand()),
            BlocListener<GameBloc, GameState>(
              listener: (context, state) {
                if (state is GameWon || state is GameLost) {
                  _showScorecard(context, state);
                }
              },
              child: SafeArea(
                child: Column(
                  children: [
                    // HUD
                    BlocBuilder<GameBloc, GameState>(
                      buildWhen: (previous, current) => 
                        current is GamePlaying && (previous is! GamePlaying || previous.elapsedTime != current.elapsedTime || previous.expectedNumber != current.expectedNumber || previous.mistakesCount != current.mistakesCount),
                      builder: (context, state) {
                        if (state is GamePlaying) {
                          final minutes = (state.elapsedTime ~/ 60).toString().padLeft(2, '0');
                          final seconds = (state.elapsedTime % 60).toString().padLeft(2, '0');
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _hudText('$minutes:$seconds'),
                                    MistakeIndicator(mistakesCount: state.mistakesCount),
                                  ],
                                ),
                                const SizedBox(height: 5), // Reduced space
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Soft cloud/abstract shape behind target
                                    Container(
                                      width: 140,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(50),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.white.withOpacity(0.2),
                                            blurRadius: 20,
                                            spreadRadius: 10,
                                          )
                                        ],
                                      ),
                                    ),
                                    NextNumberPulse(nextNumber: state.expectedNumber),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox(height: 120);
                      },
                    ),
                    
                    // Responsive Game Board
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
                          child: AspectRatio(
                            aspectRatio: 1.0, // Force a square grid
                            child: BlocBuilder<GameBloc, GameState>(
                              buildWhen: (previous, current) => current is GamePlaying,
                              builder: (context, state) {
                                if (state is GamePlaying) {
                                  return GridView.builder(
                                    padding: const EdgeInsets.all(15),
                                    physics: const NeverScrollableScrollPhysics(), // Grid stays within the square
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: widget.levelConfig.gridSize,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                    ),
                                    itemCount: state.grid.length,
                                    itemBuilder: (context, index) {
                                      final cell = state.grid[index];
                                      return GameBubble(
                                        key: ValueKey('bubble_${cell.id}_${state.mistakesCount == 0 && state.expectedNumber == 1}'),
                                        cell: cell,
                                        expectedNumber: state.expectedNumber,
                                        onTap: () {
                                          if (cell.value == state.expectedNumber) {
                                            _playSuccessSound();
                                          } else if (!cell.isPopped) {
                                            _playOopsSound();
                                          }
                                          context.read<GameBloc>().add(BubbleTappedEvent(cell));
                                        },
                                      );
                                    },
                                  );
                                }
                                return const Center(child: CircularProgressIndicator(color: Colors.white));
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hudText(String text, {Color color = Colors.white}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 24, 
        fontWeight: FontWeight.w900, 
        color: color.withOpacity(0.8),
        shadows: [
          Shadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(1, 1))
        ]
      ),
    );
  }

  void _showScorecard(BuildContext context, GameState state) async {
    final bloc = context.read<GameBloc>();
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ScorecardModal(state: state, levelConfig: widget.levelConfig),
    );

    if (result == 'play_again') {
      bloc.add(GameStartedEvent(widget.levelConfig));
    } else if (result == 'main_menu') {
      Navigator.of(context).pop();
    }
  }
}

class NextNumberPulse extends StatefulWidget {
  final int nextNumber;
  const NextNumberPulse({super.key, required this.nextNumber});

  @override
  State<NextNumberPulse> createState() => _NextNumberPulseState();
}

class _NextNumberPulseState extends State<NextNumberPulse> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScaleTransition(
          scale: _scaleAnimation,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Subtle sparkles around target
              ...List.generate(4, (i) => RotationTransition(
                turns: AlwaysStoppedAnimation(i * 45 / 360),
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) => Opacity(
                    opacity: 0.3 + (_pulseController.value * 0.4),
                    child: const Icon(Icons.auto_awesome, color: Colors.white, size: 100),
                  ),
                ),
              )),
              Container(
                width: 85,
                height: 85,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [Colors.pinkAccent, Colors.pink],
                    center: Alignment(-0.3, -0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: Center(
                  child: Text(
                    '${widget.nextNumber}',
                    style: const TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Text(
          "Find this number!",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black38,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }
}

class MistakeIndicator extends StatefulWidget {
  final int mistakesCount;
  const MistakeIndicator({super.key, required this.mistakesCount});

  @override
  State<MistakeIndicator> createState() => _MistakeIndicatorState();
}

class _MistakeIndicatorState extends State<MistakeIndicator> with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late AnimationController _popController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 5.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 5.0, end: -5.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -5.0, end: 5.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 5.0, end: 0.0), weight: 1),
    ]).animate(_shakeController);

    _popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void didUpdateWidget(MistakeIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mistakesCount > oldWidget.mistakesCount) {
      _shakeController.forward(from: 0);
      _popController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _popController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                final isFull = index < (3 - widget.mistakesCount);
                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: isFull ? 1.0 : 0.0,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 400),
                    scale: isFull ? 1.0 : 1.5,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Icon(
                        Icons.favorite_rounded,
                        color: Colors.redAccent.withOpacity(0.8),
                        size: 24,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class GameBubble extends StatefulWidget {
  final dynamic cell;
  final int expectedNumber;
  final VoidCallback onTap;

  const GameBubble({
    super.key,
    required this.cell,
    required this.expectedNumber,
    required this.onTap,
  });

  @override
  State<GameBubble> createState() => _GameBubbleState();
}

class _GameBubbleState extends State<GameBubble> with TickerProviderStateMixin {
  late AnimationController _correctController;
  late AnimationController _wrongController;
  late AnimationController _hintController;
  late AnimationController _floatController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _sparkleAnimation;
  late Animation<double> _hintAnimation;
  late Animation<double> _floatAnimation;
  Timer? _hintTimer;

  @override
  void initState() {
    super.initState();
    _correctController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 50),
    ]).animate(_correctController);
    _sparkleAnimation = Tween<double>(begin: 0.0, end: 1.5).animate(
      CurvedAnimation(parent: _correctController, curve: Curves.easeOut),
    );

    _wrongController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 4.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 4.0, end: -4.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -4.0, end: 4.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 4.0, end: 0.0), weight: 1),
    ]).animate(_wrongController);

    _hintController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _hintAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.05).chain(CurveTween(curve: Curves.easeInOut)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 50),
    ]).animate(_hintController);

    _floatController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (1500 + Random().nextInt(1000)).toInt()),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _startHintTimer();
  }

  void _startHintTimer() {
    _stopHint();
    if (!widget.cell.isPopped && widget.cell.value == widget.expectedNumber) {
      _hintTimer = Timer(const Duration(seconds: 5), () {
        if (mounted) {
          _hintController.repeat();
        }
      });
    }
  }

  void _stopHint() {
    _hintTimer?.cancel();
    _hintController.stop();
    _hintController.reset();
  }

  @override
  void didUpdateWidget(GameBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cell.isPopped && !widget.cell.isPopped) {
      _correctController.reset();
      _wrongController.reset();
    }
    if (oldWidget.expectedNumber != widget.expectedNumber || oldWidget.cell.isPopped != widget.cell.isPopped) {
      _startHintTimer();
    }
  }

  void _handleTap() {
    if (widget.cell.isPopped) return;
    _stopHint();
    if (widget.cell.value == widget.expectedNumber) {
      _correctController.forward(from: 0);
    } else {
      _wrongController.forward(from: 0);
    }
    widget.onTap();
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _correctController.dispose();
    _wrongController.dispose();
    _hintController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_correctController, _wrongController, _hintController, _floatAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, _floatAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value * _hintAnimation.value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: _handleTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Soft outer glow for unpopped bubbles
            if (!widget.cell.isPopped)
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.withOpacity(0.15),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ],
                ),
              ),
            AnimatedOpacity(
              opacity: widget.cell.isPopped ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Colors.pinkAccent.shade100, Colors.pink],
                    center: const Alignment(-0.3, -0.3),
                  ),
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, offset: Offset(0, 4), blurRadius: 4)
                  ],
                ),
                child: Stack(
                  children: [
                    // Inner highlight (toy-like)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        width: 15,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Center(
                      child: FittedBox(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '${widget.cell.value}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            FadeTransition(
              opacity: _correctController.drive(Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: const Interval(0, 0.5)))),
              child: ScaleTransition(
                scale: _sparkleAnimation,
                child: const Icon(Icons.star_rounded, color: Colors.yellowAccent, size: 40),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
