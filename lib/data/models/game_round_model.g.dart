// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_round_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameRoundModel _$GameRoundModelFromJson(Map<String, dynamic> json) =>
    GameRoundModel(
      id: json['id'] as String,
      gameId: json['gameId'] as String,
      roundNumber: (json['roundNumber'] as num).toInt(),
      targetEliminationCount: (json['targetEliminationCount'] as num).toInt(),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      isCompleted: json['isCompleted'] as bool,
      roundSummary: json['roundSummary'] as String?,
      eliminations: (json['eliminations'] as List<dynamic>)
          .map((e) => RoundEliminationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GameRoundModelToJson(GameRoundModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gameId': instance.gameId,
      'roundNumber': instance.roundNumber,
      'targetEliminationCount': instance.targetEliminationCount,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'isCompleted': instance.isCompleted,
      'roundSummary': instance.roundSummary,
      'eliminations': instance.eliminations,
    };
