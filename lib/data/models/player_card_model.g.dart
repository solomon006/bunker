// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_card_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlayerCardModel _$PlayerCardModelFromJson(Map<String, dynamic> json) =>
    PlayerCardModel(
      id: json['id'] as String,
      type: $enumDecode(_$CardTypeEnumMap, json['type']),
      title: json['title'] as String,
      description: json['description'] as String?,
      isRevealed: json['isRevealed'] as bool,
      utilityIndex: (json['utilityIndex'] as num).toInt(),
    );

Map<String, dynamic> _$PlayerCardModelToJson(PlayerCardModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$CardTypeEnumMap[instance.type]!,
      'title': instance.title,
      'description': instance.description,
      'isRevealed': instance.isRevealed,
      'utilityIndex': instance.utilityIndex,
    };

const _$CardTypeEnumMap = {
  CardType.profession: 'profession',
  CardType.biological: 'biological',
  CardType.health: 'health',
  CardType.hobby: 'hobby',
  CardType.baggage: 'baggage',
  CardType.specialCondition: 'specialCondition',
  CardType.phobia: 'phobia',
  CardType.character: 'character',
};
