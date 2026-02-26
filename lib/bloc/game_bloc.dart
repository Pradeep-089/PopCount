
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'game_event.dart';
import 'game_state.dart';
import '../models/cell_data.dart';
import '../models/level_config.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  StreamSubscription<int>? _timerSubscription;

  GameBloc() : super(GameInitial()) {
    on<GameStartedEvent>(_onGameStarted);
    on<BubbleTappedEvent>(_onBubbleTapped);
    on<TimerTickedEvent>(_onTimerTicked);
  }

  Future<void> _onGameStarted(GameStartedEvent event, Emitter<GameState> emit) async {
    // Ensure previous subscription is canceled and nullified
    await _timerSubscription?.cancel();
    _timerSubscription = null;
    
    final level = event.levelConfig;
    final totalCells = level.gridSize * level.gridSize;
    final maxTarget = totalCells - level.bombCount;
    
    List<CellData> grid = [];
    int idCounter = 0;
    
    // Numbers
    for (int i = 1; i <= maxTarget; i++) {
      grid.add(CellData(id: idCounter++, value: i));
    }
    
    // Bombs
    for (int i = 0; i < level.bombCount; i++) {
      grid.add(CellData(id: idCounter++, value: -1, isBomb: true));
    }
    
    grid.shuffle();

    emit(GamePlaying(
      grid: grid,
      expectedNumber: 1,
      remainingTime: level.timeLimitSeconds,
      maxTarget: maxTarget,
      levelConfig: level,
    ));

    // Create a fresh subscription
    _timerSubscription = Stream.periodic(const Duration(seconds: 1), (x) => level.timeLimitSeconds - x - 1)
        .take(level.timeLimitSeconds)
        .listen((remaining) => add(TimerTickedEvent(remaining)));
  }

  void _onTimerTicked(TimerTickedEvent event, Emitter<GameState> emit) {
    if (state is GamePlaying) {
      final playingState = state as GamePlaying;
      if (event.remainingSeconds <= 0) {
        emit(const GameLost(FailureReason.timeout));
        _timerSubscription?.cancel();
        _timerSubscription = null;
      } else {
        emit(GamePlaying(
          grid: playingState.grid,
          expectedNumber: playingState.expectedNumber,
          remainingTime: event.remainingSeconds,
          maxTarget: playingState.maxTarget,
          levelConfig: playingState.levelConfig,
        ));
      }
    }
  }

  void _onBubbleTapped(BubbleTappedEvent event, Emitter<GameState> emit) {
    if (state is! GamePlaying) return;
    final playingState = state as GamePlaying;
    final cell = event.cell;

    if (cell.isPopped) return;

    if (cell.isBomb) {
      _timerSubscription?.cancel();
      _timerSubscription = null;
      emit(const GameLost(FailureReason.detonated));
    } else if (cell.value == playingState.expectedNumber) {
      // Correct Tap
      final updatedGrid = playingState.grid.map((c) {
        return c.id == cell.id ? c.copyWith(isPopped: true) : c;
      }).toList();

      final nextNumber = playingState.expectedNumber + 1;

      if (nextNumber > playingState.maxTarget) {
        _timerSubscription?.cancel();
        _timerSubscription = null;
        
        final level = playingState.levelConfig;
        final remainingTime = playingState.remainingTime;
        
        int basePoints = level.basePoints;
        double timeRemainingPercent = remainingTime / level.timeLimitSeconds;
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
        String tier = _getTier(totalPoints);

        emit(GameWon(
          finalRemainingTime: remainingTime,
          totalPoints: totalPoints,
          tier: tier,
        ));
      } else {
        emit(GamePlaying(
          grid: updatedGrid,
          expectedNumber: nextNumber,
          remainingTime: playingState.remainingTime,
          maxTarget: playingState.maxTarget,
          levelConfig: playingState.levelConfig,
        ));
      }
    } else {
      // Penalty Tap - Reshuffle
      final resetGrid = playingState.grid.map((c) => c.copyWith(isPopped: false)).toList();
      resetGrid.shuffle();
      emit(GamePlaying(
        grid: resetGrid,
        expectedNumber: 1,
        remainingTime: playingState.remainingTime,
        maxTarget: playingState.maxTarget,
        levelConfig: playingState.levelConfig,
      ));
    }
  }

  String _getTier(int points) {
    if (points >= 100) return 'Aimbot';
    if (points >= 90) return 'Cracked';
    if (points >= 80) return 'Sweaty';
    if (points >= 70) return 'Clutch';
    if (points >= 60) return 'Tryhard';
    if (points >= 50) return 'Gamer';
    if (points >= 40) return 'Casual';
    if (points >= 30) return 'Bot';
    if (points >= 20) return 'NPC';
    return 'Noob';
  }

  @override
  Future<void> close() {
    _timerSubscription?.cancel();
    _timerSubscription = null;
    return super.close();
  }
}
