
import 'package:equatable/equatable.dart';
import '../models/cell_data.dart';
import '../models/level_config.dart';

enum FailureReason { timeout, detonated, mistakesExceeded }

abstract class GameState extends Equatable {
  const GameState();

  @override
  List<Object?> get props => [];
}

class GameInitial extends GameState {}

class GamePlaying extends GameState {
  final List<CellData> grid;
  final int expectedNumber;
  final int elapsedTime; // Changed from remainingTime to elapsedTime for stopwatch behavior
  final int mistakesCount; // Added for the "Oopsie Meter"
  final int maxTarget;
  final LevelConfig levelConfig;

  const GamePlaying({
    required this.grid,
    required this.expectedNumber,
    required this.elapsedTime,
    required this.mistakesCount,
    required this.maxTarget,
    required this.levelConfig,
  });

  @override
  List<Object?> get props => [grid, expectedNumber, elapsedTime, mistakesCount, maxTarget, levelConfig];
}

class GameWon extends GameState {
  final int totalTime;
  final int totalPoints;
  final String tier;

  const GameWon({
    required this.totalTime,
    required this.totalPoints,
    required this.tier,
  });

  @override
  List<Object?> get props => [totalTime, totalPoints, tier];
}

class GameLost extends GameState {
  final FailureReason reason;
  const GameLost(this.reason);

  @override
  List<Object?> get props => [reason];
}
