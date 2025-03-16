import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'player_card_model.g.dart';

enum CardType {
  profession,
  biological,
  health,
  hobby,
  baggage,
  specialCondition,
  phobia,
  character
}

@JsonSerializable()
class PlayerCardModel extends Equatable {
  final String id;
  final CardType type;
  final String title;
  final String? description;
  final bool isRevealed;
  final int utilityIndex;

  const PlayerCardModel({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    required this.isRevealed,
    required this.utilityIndex,
  });

  // Копирование с изменениями
  PlayerCardModel copyWith({
    String? id,
    CardType? type,
    String? title,
    String? description,
    bool? isRevealed,
    int? utilityIndex,
  }) {
    return PlayerCardModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      isRevealed: isRevealed ?? this.isRevealed,
      utilityIndex: utilityIndex ?? this.utilityIndex,
    );
  }

  // Фабричный метод для JSON
  factory PlayerCardModel.fromJson(Map<String, dynamic> json) => _$PlayerCardModelFromJson(json);

  // Сериализация в JSON
  Map<String, dynamic> toJson() => _$PlayerCardModelToJson(this);

  @override
  List<Object?> get props => [id, type, title, description, isRevealed, utilityIndex];
}
