
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
    String timeRemaining = '00:00';

    if (state is GameWon) {
      final s = state as GameWon;
      resultTitle = 'VICTORY';
      reason = 'Board Cleared';
      titleColor = Colors.green;
      tier = s.tier;
      
      final minutes = (s.finalRemainingTime ~/ 60).toString().padLeft(2, '0');
      final seconds = (s.finalRemainingTime % 60).toString().padLeft(2, '0');
      timeRemaining = '$minutes:$seconds';
    } else if (state is GameLost) {
      final s = state as GameLost;
      resultTitle = 'GAME OVER';
      reason = s.reason == FailureReason.timeout ? 'Time Out' : 'Hit a Bomb';
      titleColor = Colors.red;
    }

    return Dialog(
      backgroundColor: Colors.white.withOpacity(0.95),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            Text(reason, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            const Divider(height: 40, thickness: 2),
            
            Text(
              'Time Remaining: $timeRemaining',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            
            if (state is GameWon)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  children: [
                    const Text('FINAL RANK', style: TextStyle(fontSize: 12, letterSpacing: 4, fontWeight: FontWeight.bold)),
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
            
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink, 
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.of(context).pop('play_again'),
                    child: const Text(
                      'PLAY AGAIN', 
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      side: const BorderSide(width: 2, color: Colors.black87),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.of(context).pop('main_menu'),
                    child: const Text(
                      'MAIN MENU', 
                      style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w900, letterSpacing: 1),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
