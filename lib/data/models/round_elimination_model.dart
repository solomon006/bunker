import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'round_elimination_model.g.dart';

@JsonSerializable()
class RoundEliminationModel extends Equatable {
  final String id;
  final String roundId;
  final String playerId;
  final int votesReceived;
  final String? eliminationReason;
  final DateTime eliminatedAt;

  const RoundEliminationModel({
    required this.id,
    required this.roundId,
    required this.playerId,
    required this.votesReceived,
    this.eliminationReason,
    required this.eliminatedAt,
  });

  // Копирование с изменениями
  RoundEliminationModel copyWith({
    String? id,
    String? roundId,
    String? playerId,
    int? votesReceived,
    String? eliminationReason,
    DateTime? eliminatedAt,
  }) {
    return RoundEliminationModel(
      id: id ?? this.id,
      roundId: roundId ?? this.roundId,
      playerId: playerId ?? this.playerId,
      votesReceived: votesReceived ?? this.votesReceived,
      eliminationReason: eliminationReason ?? this.eliminationReason,
      eliminatedAt: eliminatedAt ?? this.eliminatedAt,
    );
  }

  // Фабричный метод для JSON
  factory RoundEliminationModel.fromJson(Map<String, dynamic> json) => _$RoundEliminationModelFromJson(json);

  // Сериализация в JSON
  Map<String, dynamic> toJson() => _$RoundEliminationModelToJson(this);

  @override
  List<Object?> get props => [id, roundId, playerId, votesReceived, eliminationReason, eliminatedAt];
}
