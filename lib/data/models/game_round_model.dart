import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:bunker/data/models/round_elimination_model.dart';

part 'game_round_model.g.dart';

@JsonSerializable()
class GameRoundModel extends Equatable {
  final String id;
  final String gameId;
  final int roundNumber;
  final int targetEliminationCount;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isCompleted;
  final String? roundSummary;
  final List<RoundEliminationModel> eliminations;

  const GameRoundModel({
    required this.id,
    required this.gameId,
    required this.roundNumber,
    required this.targetEliminationCount,
    required this.startTime,
    this.endTime,
    required this.isCompleted,
    this.roundSummary,
    required this.eliminations,
  });

  // Копирование с изменениями
  GameRoundModel copyWith({
    String? id,
    String? gameId,
    int? roundNumber,
    int? targetEliminationCount,
    DateTime? startTime,
    DateTime? endTime,
    bool? isCompleted,
    String? roundSummary,
    List<RoundEliminationModel>? eliminations,
  }) {
    return GameRoundModel(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      roundNumber: roundNumber ?? this.roundNumber,
      targetEliminationCount: targetEliminationCount ?? this.targetEliminationCount,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isCompleted: isCompleted ?? this.isCompleted,
      roundSummary: roundSummary ?? this.roundSummary,
      eliminations: eliminations ?? this.eliminations,
    );
  }

  // Фабричный метод для JSON
  factory GameRoundModel.fromJson(Map<String, dynamic> json) => _$GameRoundModelFromJson(json);

  // Сериализация в JSON
  Map<String, dynamic> toJson() => _$GameRoundModelToJson(this);

  @override
  List<Object?> get props => [
    id, gameId, roundNumber, targetEliminationCount,
    startTime, endTime, isCompleted, roundSummary, eliminations
  ];
}
