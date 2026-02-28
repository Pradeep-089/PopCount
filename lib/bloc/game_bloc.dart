
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
    await _timerSubscription?.cancel();
    _timerSubscription = null;
    
    final level = event.levelConfig;
    final totalCells = level.gridSize * level.gridSize;
    // In EdTech version, no bombs are spawned.
    final maxTarget = totalCells; 
    
    List<CellData> grid = [];
    for (int i = 1; i <= maxTarget; i++) {
      grid.add(CellData(id: i - 1, value: i));
    }
    
    grid.shuffle();

    emit(GamePlaying(
      grid: grid,
      expectedNumber: 1,
      elapsedTime: 0,
      mistakesCount: 0,
      maxTarget: maxTarget,
      levelConfig: level,
    ));

    // Stopwatch behavior: increments every second
    _timerSubscription = Stream.periodic(const Duration(seconds: 1), (x) => x + 1)
        .listen((elapsed) => add(TimerTickedEvent(elapsed)));
  }

  void _onTimerTicked(TimerTickedEvent event, Emitter<GameState> emit) {
    if (state is GamePlaying) {
      final playingState = state as GamePlaying;
      emit(GamePlaying(
        grid: playingState.grid,
        expectedNumber: playingState.expectedNumber,
        elapsedTime: event.remainingSeconds, // remainingSeconds field in event reused for elapsed
        mistakesCount: playingState.mistakesCount,
        maxTarget: playingState.maxTarget,
        levelConfig: playingState.levelConfig,
      ));
    }
  }

  void _onBubbleTapped(BubbleTappedEvent event, Emitter<GameState> emit) {
    if (state is! GamePlaying) return;
    final playingState = state as GamePlaying;
    final cell = event.cell;

    if (cell.isPopped) return;

    if (cell.value == playingState.expectedNumber) {
      // Correct Tap
      final updatedGrid = playingState.grid.map((c) {
        return c.id == cell.id ? c.copyWith(isPopped: true) : c;
      }).toList();

      final nextNumber = playingState.expectedNumber + 1;

      if (nextNumber > playingState.maxTarget) {
        _timerSubscription?.cancel();
        _timerSubscription = null;
        
        // Positive reinforcement scoring logic
        int totalPoints = playingState.levelConfig.basePoints;
        String tier = _getEdTechTier(playingState.elapsedTime);

        emit(GameWon(
          totalTime: playingState.elapsedTime,
          totalPoints: totalPoints,
          tier: tier,
        ));
      } else {
        emit(GamePlaying(
          grid: updatedGrid,
          expectedNumber: nextNumber,
          elapsedTime: playingState.elapsedTime,
          mistakesCount: playingState.mistakesCount,
          maxTarget: playingState.maxTarget,
          levelConfig: playingState.levelConfig,
        ));
      }
    } else {
      // Wrong Tap - Increment Mistakes (Oopsie Meter)
      final newMistakesCount = playingState.mistakesCount + 1;
      
      if (newMistakesCount >= 3) {
        _timerSubscription?.cancel();
        _timerSubscription = null;
        emit(const GameLost(FailureReason.mistakesExceeded));
      } else {
        // Penalty: Reshuffle but keep progress? 
        // Based on BRD: accuracy tied loss, but doesn't specify sequence reset.
        // Keeping current logic of sequence reset for consistency unless specified.
        final resetGrid = playingState.grid.map((c) => c.copyWith(isPopped: false)).toList();
        resetGrid.shuffle();
        
        emit(GamePlaying(
          grid: resetGrid,
          expectedNumber: 1,
          elapsedTime: playingState.elapsedTime,
          mistakesCount: newMistakesCount,
          maxTarget: playingState.maxTarget,
          levelConfig: playingState.levelConfig,
        ));
      }
    }
  }

  String _getEdTechTier(int totalTime) {
    // Friendly rankings for children
    if (totalTime < 20) return 'Super Star!';
    if (totalTime < 40) return 'Great Job!';
    return 'Awesome!';
  }

  @override
  Future<void> close() {
    _timerSubscription?.cancel();
    _timerSubscription = null;
    return super.close();
  }
}
