
import 'package:equatable/equatable.dart';

class CellData extends Equatable {
  final int id;
  final int value; // 1 to Target (Bombs represented by -1)
  final bool isBomb; // true if value == -1
  final bool isPopped; // true if successfully tapped

  const CellData({
    required this.id,
    required this.value,
    this.isBomb = false,
    this.isPopped = false,
  });

  CellData copyWith({bool? isPopped}) {
    return CellData(
      id: id,
      value: value,
      isBomb: isBomb,
      isPopped: isPopped ?? this.isPopped,
    );
  }

  @override
  List<Object?> get props => [id, value, isBomb, isPopped];
}
