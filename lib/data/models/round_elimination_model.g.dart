// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'round_elimination_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoundEliminationModel _$RoundEliminationModelFromJson(
        Map<String, dynamic> json) =>
    RoundEliminationModel(
      id: json['id'] as String,
      roundId: json['roundId'] as String,
      playerId: json['playerId'] as String,
      votesReceived: (json['votesReceived'] as num).toInt(),
      eliminationReason: json['eliminationReason'] as String?,
      eliminatedAt: DateTime.parse(json['eliminatedAt'] as String),
    );

Map<String, dynamic> _$RoundEliminationModelToJson(
        RoundEliminationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'roundId': instance.roundId,
      'playerId': instance.playerId,
      'votesReceived': instance.votesReceived,
      'eliminationReason': instance.eliminationReason,
      'eliminatedAt': instance.eliminatedAt.toIso8601String(),
    };
