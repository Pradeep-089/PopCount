import 'dart:async';
import 'package:flutter/material.dart';
import '../models/cell_data.dart';
import '../models/level_config.dart';

enum GameState {
  initializing,
  playing,
  won,
  lostTimeOut,
  lostBomb,
}

class GameController extends ChangeNotifier {
  final LevelConfig levelConfig;

  GameState _gameState = GameState.initializing;
  int _remainingSeconds = 0;
  int _expectedNumber = 1;
  List<CellData> _gridData = [];
  Timer? _timer;

  GameController({required this.levelConfig}) {
    _remainingSeconds = levelConfig.timeLimitSeconds;
    _initializeGrid();
    _startGame();
  }

  GameState get gameState => _gameState;
  int get remainingSeconds => _remainingSeconds;
  int get expectedNumber => _expectedNumber;
  List<CellData> get gridData => _gridData;
  int get maxTarget => (levelConfig.gridSize * levelConfig.gridSize) - levelConfig.bombCount;

  void _initializeGrid() {
    _gridData = [];
    int totalCells = levelConfig.gridSize * levelConfig.gridSize;
    
    // Fill numbers 1 to maxTarget
    for (int i = 1; i <= maxTarget; i++) {
      _gridData.add(CellData(value: i));
    }
    
    // Fill bombs
    for (int i = 0; i < levelConfig.bombCount; i++) {
      _gridData.add(CellData(value: -1, isBomb: true));
    }
    
    _gridData.shuffle();
    notifyListeners();
  }

  void _startGame() {
    _gameState = GameState.playing;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _handleTimeOut();
      }
    });
  }

  void _handleTimeOut() {
    _gameState = GameState.lostTimeOut;
    _timer?.cancel();
    notifyListeners();
  }

  void handleTap(CellData cell) {
    if (_gameState != GameState.playing || cell.isPopped) return;

    if (cell.isBomb) {
      _gameState = GameState.lostBomb;
      _timer?.cancel();
    } else if (cell.value == _expectedNumber) {
      cell.isPopped = true;
      _expectedNumber++;
      
      if (_expectedNumber > maxTarget) {
        _gameState = GameState.won;
        _timer?.cancel();
      }
    } else {
      // Penalty Tap: Wrong tap (not bomb), reset and reshuffle
      _expectedNumber = 1;
      for (var c in _gridData) {
        c.isPopped = false;
      }
      _gridData.shuffle();
    }
    notifyListeners();
  }

  String calculateTier() {
    if (_gameState != GameState.won) return 'N/A';
    
    int basePoints = levelConfig.basePoints;
    double timeRemainingPercent = _remainingSeconds / levelConfig.timeLimitSeconds;
    int speedBonus = 0;

    if (timeRemainingPercent > 0.7) {
      speedBonus = 40;
    } else if (timeRemainingPercent > 0.4) {
      speedBonus = 30;
    } else if (timeRemainingPercent > 0.1) {
      speedBonus = 20;
    } else {
      speedBonus = 10;
    }

    int totalPoints = basePoints + speedBonus;

    if (totalPoints >= 100) return 'Aimbot';
    if (totalPoints >= 90) return 'Cracked';
    if (totalPoints >= 80) return 'Sweaty';
    if (totalPoints >= 70) return 'Clutch';
    if (totalPoints >= 60) return 'Tryhard';
    if (totalPoints >= 50) return 'Gamer';
    if (totalPoints >= 40) return 'Casual';
    if (totalPoints >= 30) return 'Bot';
    if (totalPoints >= 20) return 'NPC';
    return 'Noob';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
