
import 'package:equatable/equatable.dart';
import '../models/cell_data.dart';
import '../models/level_config.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

class GameStartedEvent extends GameEvent {
  final LevelConfig levelConfig;
  const GameStartedEvent(this.levelConfig);

  @override
  List<Object?> get props => [levelConfig];
}

class BubbleTappedEvent extends GameEvent {
  final CellData cell;
  const BubbleTappedEvent(this.cell);

  @override
  List<Object?> get props => [cell];
}

class TimerTickedEvent extends GameEvent {
  final int remainingSeconds;
  const TimerTickedEvent(this.remainingSeconds);

  @override
  List<Object?> get props => [remainingSeconds];
}
