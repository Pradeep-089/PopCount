
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
    String resultTitle = '';
    String reason = '';
    Color titleColor = Colors.black;
    String tier = 'N/A';
    String timeDisplay = '00:00';
    String emoji = '🏆';

    if (state is GameWon) {
      final s = state as GameWon;
      resultTitle = 'VICTORY!';
      reason = 'Board Cleared';
      titleColor = Colors.green;
      tier = s.tier;
      emoji = '🌟';
      
      final minutes = (s.totalTime ~/ 60).toString().padLeft(2, '0');
      final seconds = (s.totalTime % 60).toString().padLeft(2, '0');
      timeDisplay = '$minutes:$seconds';
    } else if (state is GameLost) {
      final s = state as GameLost;
      resultTitle = 'OH NO!';
      titleColor = Colors.orange;
      emoji = '😮';
      
      if (s.reason == FailureReason.mistakesExceeded) {
        reason = "Too many oopsies! Let's try again!";
      } else if (s.reason == FailureReason.timeout) {
        reason = 'Time Out';
      } else {
        reason = 'Hit a Bomb';
      }
    }

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        backgroundColor: Colors.white.withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 80),
              ),
              const SizedBox(height: 10),
              Text(
                resultTitle,
                style: TextStyle(
                  fontSize: 40, 
                  fontWeight: FontWeight.w900, 
                  color: titleColor,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                reason, 
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const Divider(height: 40, thickness: 2),
              
              if (state is GameWon) ...[
                Text(
                  'Total Time: $timeDisplay',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Column(
                    children: [
                      const Text('REWARD', style: TextStyle(fontSize: 12, letterSpacing: 4, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text(
                        tier,
                        style: const TextStyle(
                          fontSize: 44, 
                          fontWeight: FontWeight.w900, 
                          color: Colors.blueAccent,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 70,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink, 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
                    elevation: 5,
                  ),
                  onPressed: () => Navigator.of(context).pop('play_again'),
                  child: const Text(
                    'TRY AGAIN', 
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () => Navigator.of(context).pop('main_menu'),
                child: const Text(
                  'Main Menu',
                  style: TextStyle(color: Colors.black54, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
