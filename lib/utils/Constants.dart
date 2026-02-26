import '../models/level_config.dart';

class GameConstants {
  static const List<LevelConfig> levels = [
    LevelConfig(
      name: 'ChildsPlay',
      gridSize: 2,
      bombCount: 0,
      timeLimitSeconds: 15,
      basePoints: 10,
    ),
    LevelConfig(
      name: 'Easy',
      gridSize: 3,
      bombCount: 0,
      timeLimitSeconds: 30,
      basePoints: 20,
    ),
    LevelConfig(
      name: 'Medium',
      gridSize: 4,
      bombCount: 3,
      timeLimitSeconds: 45,
      basePoints: 30,
    ),
    LevelConfig(
      name: 'Hard',
      gridSize: 5,
      bombCount: 5,
      timeLimitSeconds: 60,
      basePoints: 40,
    ),
    LevelConfig(
      name: 'Expert',
      gridSize: 6,
      bombCount: 8,
      timeLimitSeconds: 80,
      basePoints: 50,
    ),
    LevelConfig(
      name: 'NightMare',
      gridSize: 10,
      bombCount: 25,
      timeLimitSeconds: 180,
      basePoints: 60,
    ),
  ];

  static const Map<int, String> tierRankings = {
    100: 'Aimbot',
    90: 'Cracked',
    80: 'Sweaty',
    70: 'Clutch',
    60: 'Tryhard',
    50: 'Gamer',
    40: 'Casual',
    30: 'Bot',
    20: 'NPC',
    10: 'Noob',
  };
}
