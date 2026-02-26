
class LevelConfig {
  final String name;
  final int gridSize;
  final int bombCount;
  final int timeLimitSeconds;
  final int basePoints;

  const LevelConfig({
    required this.name,
    required this.gridSize,
    required this.bombCount,
    required this.timeLimitSeconds,
    required this.basePoints,
  });
}
