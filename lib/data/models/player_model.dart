import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:bunker/data/models/player_card_model.dart';

part 'player_model.g.dart';

@JsonSerializable()
class PlayerModel extends Equatable {
  final String id;
  final String name;
  final String connectionId;
  final String userId;
  final int orderNumber;
  final bool isEliminated;
  final bool isHost;
  final bool isSelected;
  final bool isSurvivor;
  final int? eliminationRound;
  final String? personalOutcome;
  final List<PlayerCardModel> cards;

  const PlayerModel({
    required this.id,
    required this.name,
    required this.connectionId,
    required this.userId,
    required this.orderNumber,
    required this.isEliminated,
    required this.isHost,
    required this.isSelected,
    required this.isSurvivor,
    this.eliminationRound,
    this.personalOutcome,
    required this.cards,
  });

  // Копирование с изменениями
  PlayerModel copyWith({
    String? id,
    String? name,
    String? connectionId,
    String? userId,
    int? orderNumber,
    bool? isEliminated,
    bool? isHost,
    bool? isSelected,
    bool? isSurvivor,
    int? eliminationRound,
    String? personalOutcome,
    List<PlayerCardModel>? cards,
  }) {
    return PlayerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      connectionId: connectionId ?? this.connectionId,
      userId: userId ?? this.userId,
      orderNumber: orderNumber ?? this.orderNumber,
      isEliminated: isEliminated ?? this.isEliminated,
      isHost: isHost ?? this.isHost,
      isSelected: isSelected ?? this.isSelected,
      isSurvivor: isSurvivor ?? this.isSurvivor,
      eliminationRound: eliminationRound ?? this.eliminationRound,
      personalOutcome: personalOutcome ?? this.personalOutcome,
      cards: cards ?? this.cards,
    );
  }

  // Фабричный метод для JSON
  factory PlayerModel.fromJson(Map<String, dynamic> json) => _$PlayerModelFromJson(json);

  // Сериализация в JSON
  Map<String, dynamic> toJson() => _$PlayerModelToJson(this);

  @override
  List<Object?> get props => [
    id, name, connectionId, userId, orderNumber, isEliminated,
    isHost, isSelected, isSurvivor, eliminationRound, personalOutcome, cards
  ];
}
