
import '../models/level_config.dart';

class GameConstants {
  static const List<LevelConfig> levels = [
    LevelConfig(
      name: 'Little Learner',
      gridSize: 3, // ~2x2 to 3x3 layout
      bombCount: 0,
      timeLimitSeconds: 0, 
      basePoints: 10,
    ),
    LevelConfig(
      name: 'Growing Star',
      gridSize: 4, // ~3x3 to 4x4 layout
      bombCount: 0,
      timeLimitSeconds: 0,
      basePoints: 20,
    ),
    LevelConfig(
      name: 'Super Counter',
      gridSize: 5, // ~4x4 to 5x5 layout
      bombCount: 0,
      timeLimitSeconds: 0,
      basePoints: 30,
    ),
  ];

  static const List<String> childFriendlyRanks = [
    'Super Star!',
    'Great Job!',
    'Awesome!',
    'Well Done!',
    'Keep It Up!',
  ];
}
