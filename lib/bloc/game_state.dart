
import 'package:equatable/equatable.dart';
import '../models/cell_data.dart';
import '../models/level_config.dart';

enum FailureReason { timeout, detonated }

abstract class GameState extends Equatable {
  const GameState();

  @override
  List<Object?> get props => [];
}

class GameInitial extends GameState {}

class GamePlaying extends GameState {
  final List<CellData> grid;
  final int expectedNumber;
  final int remainingTime;
  final int maxTarget;
  final LevelConfig levelConfig; // Added for tier calculation

  const GamePlaying({
    required this.grid,
    required this.expectedNumber,
    required this.remainingTime,
    required this.maxTarget,
    required this.levelConfig,
  });

  @override
  List<Object?> get props => [grid, expectedNumber, remainingTime, maxTarget, levelConfig];
}

class GameWon extends GameState {
  final int finalRemainingTime;
  final int totalPoints;
  final String tier;

  const GameWon({
    required this.finalRemainingTime,
    required this.totalPoints,
    required this.tier,
  });

  @override
  List<Object?> get props => [finalRemainingTime, totalPoints, tier];
}

class GameLost extends GameState {
  final FailureReason reason;
  const GameLost(this.reason);

  @override
  List<Object?> get props => [reason];
}
