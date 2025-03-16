// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlayerModel _$PlayerModelFromJson(Map<String, dynamic> json) => PlayerModel(
      id: json['id'] as String,
      name: json['name'] as String,
      connectionId: json['connectionId'] as String,
      userId: json['userId'] as String,
      orderNumber: (json['orderNumber'] as num).toInt(),
      isEliminated: json['isEliminated'] as bool,
      isHost: json['isHost'] as bool,
      isSelected: json['isSelected'] as bool,
      isSurvivor: json['isSurvivor'] as bool,
      eliminationRound: (json['eliminationRound'] as num?)?.toInt(),
      personalOutcome: json['personalOutcome'] as String?,
      cards: (json['cards'] as List<dynamic>)
          .map((e) => PlayerCardModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PlayerModelToJson(PlayerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'connectionId': instance.connectionId,
      'userId': instance.userId,
      'orderNumber': instance.orderNumber,
      'isEliminated': instance.isEliminated,
      'isHost': instance.isHost,
      'isSelected': instance.isSelected,
      'isSurvivor': instance.isSurvivor,
      'eliminationRound': instance.eliminationRound,
      'personalOutcome': instance.personalOutcome,
      'cards': instance.cards,
    };
