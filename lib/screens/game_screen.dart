import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';
import '../models/level_config.dart';
import '../widgets/animated_background.dart';
import '../widgets/scorecard_modal.dart';

class GameScreen extends StatelessWidget {
  final LevelConfig levelConfig;

  const GameScreen({super.key, required this.levelConfig});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameBloc()..add(GameStartedEvent(levelConfig)),
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
                                    Row(
                                      children: List.generate(3, (index) {
                                        return Icon(
                                          index < (3 - state.mistakesCount) ? Icons.favorite : Icons.favorite_border,
                                          color: Colors.redAccent,
                                          size: 24,
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                NextNumberPulse(nextNumber: state.expectedNumber),
                              ],
                            ),
                          );
                        }
                        return const SizedBox(height: 150);
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
                                      crossAxisCount: levelConfig.gridSize,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8,
                                    ),
                                    itemCount: state.grid.length,
                                    itemBuilder: (context, index) {
                                      final cell = state.grid[index];
                                      return _buildBubble(context, cell);
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

  Widget _buildBubble(BuildContext context, dynamic cell) {
    return GestureDetector(
      onTap: () => context.read<GameBloc>().add(BubbleTappedEvent(cell)),
      child: AnimatedOpacity(
        opacity: cell.isPopped ? 0.2 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.pink,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black, width: 2),
            boxShadow: cell.isPopped ? [] : [
              const BoxShadow(color: Colors.black26, offset: Offset(2, 2), blurRadius: 2)
            ],
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${cell.value}',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: cell.isPopped ? Colors.transparent : Colors.black87,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _hudText(String text, {Color color = Colors.white}) {
    return Text(
      text,
      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: color, shadows: [
        Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 6, offset: const Offset(2, 2))
      ]),
    );
  }

  void _showScorecard(BuildContext context, GameState state) async {
    final bloc = context.read<GameBloc>();
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ScorecardModal(state: state, levelConfig: levelConfig),
    );

    if (result == 'play_again') {
      bloc.add(GameStartedEvent(levelConfig));
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

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
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
      children: [
        ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Colors.pinkAccent, Colors.pink],
                center: Alignment(-0.3, -0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.pink.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
              border: Border.all(color: Colors.white, width: 4),
            ),
            child: Center(
              child: Text(
                '${widget.nextNumber}',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Find this number!",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(0.9),
            letterSpacing: 1.1,
            shadows: const [Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
          ),
        ),
      ],
    );
  }
}
