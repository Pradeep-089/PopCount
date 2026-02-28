
import '../models/level_config.dart';

class GameConstants {
  static const List<LevelConfig> levels = [
    LevelConfig(
      name: 'Baby Steps',
      gridSize: 2,
      bombCount: 0,
      timeLimitSeconds: 0, // Stopwatch mode
      basePoints: 10,
    ),
    LevelConfig(
      name: 'Little Learner',
      gridSize: 3,
      bombCount: 0,
      timeLimitSeconds: 0,
      basePoints: 20,
    ),
    LevelConfig(
      name: 'Growing Up',
      gridSize: 4,
      bombCount: 0,
      timeLimitSeconds: 0,
      basePoints: 30,
    ),
    LevelConfig(
      name: 'Kindergarten',
      gridSize: 5,
      bombCount: 0,
      timeLimitSeconds: 0,
      basePoints: 40,
    ),
    LevelConfig(
      name: 'School Age',
      gridSize: 6,
      bombCount: 0,
      timeLimitSeconds: 0,
      basePoints: 50,
    ),
    LevelConfig(
      name: 'Math Whiz',
      gridSize: 8,
      bombCount: 0,
      timeLimitSeconds: 0,
      basePoints: 60,
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
