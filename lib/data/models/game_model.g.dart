// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameModel _$GameModelFromJson(Map<String, dynamic> json) => GameModel(
      id: json['id'] as String,
      name: json['name'] as String,
      hostId: json['hostId'] as String,
      state: $enumDecode(_$GameStateEnumMap, json['state']),
      maxPlayers: (json['maxPlayers'] as num).toInt(),
      currentPlayers: (json['currentPlayers'] as num).toInt(),
      discussionTime: (json['discussionTime'] as num).toInt(),
      voteTime: (json['voteTime'] as num).toInt(),
      voteType: $enumDecode(_$VoteTypeEnumMap, json['voteType']),
      balanceLevel: json['balanceLevel'] as String,
      packId: (json['packId'] as num).toInt(),
      catastrophe: json['catastrophe'] == null
          ? null
          : CatastropheModel.fromJson(
              json['catastrophe'] as Map<String, dynamic>),
      shelter: json['shelter'] == null
          ? null
          : ShelterModel.fromJson(json['shelter'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      endedAt: json['endedAt'] == null
          ? null
          : DateTime.parse(json['endedAt'] as String),
      isCompleted: json['isCompleted'] as bool,
      difficultyLevel: (json['difficultyLevel'] as num).toInt(),
      totalRounds: (json['totalRounds'] as num).toInt(),
      players: (json['players'] as List<dynamic>)
          .map((e) => PlayerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasPassword: json['hasPassword'] as bool,
    );

Map<String, dynamic> _$GameModelToJson(GameModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'hostId': instance.hostId,
      'state': _$GameStateEnumMap[instance.state]!,
      'maxPlayers': instance.maxPlayers,
      'currentPlayers': instance.currentPlayers,
      'discussionTime': instance.discussionTime,
      'voteTime': instance.voteTime,
      'voteType': _$VoteTypeEnumMap[instance.voteType]!,
      'balanceLevel': instance.balanceLevel,
      'packId': instance.packId,
      'catastrophe': instance.catastrophe,
      'shelter': instance.shelter,
      'createdAt': instance.createdAt.toIso8601String(),
      'endedAt': instance.endedAt?.toIso8601String(),
      'isCompleted': instance.isCompleted,
      'difficultyLevel': instance.difficultyLevel,
      'totalRounds': instance.totalRounds,
      'players': instance.players,
      'hasPassword': instance.hasPassword,
    };

const _$GameStateEnumMap = {
  GameState.lobby: 'lobby',
  GameState.inProgress: 'inProgress',
  GameState.ended: 'ended',
};

const _$VoteTypeEnumMap = {
  VoteType.open: 'open',
  VoteType.semiOpen: 'semiOpen',
  VoteType.closed: 'closed',
};
