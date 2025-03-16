import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:bunker/data/models/player_model.dart';
import 'package:bunker/data/models/catastrophe_model.dart';
import 'package:bunker/data/models/shelter_model.dart';

part 'game_model.g.dart';

enum GameState {
  lobby,
  inProgress,
  ended
}

enum VoteType {
  open,
  semiOpen,
  closed
}

@JsonSerializable()
class GameModel extends Equatable {
  final String id;
  final String name;
  final String hostId;
  final GameState state;
  final int maxPlayers;
  final int currentPlayers;
  final int discussionTime;
  final int voteTime;
  final VoteType voteType;
  final String balanceLevel;
  final int packId;
  final CatastropheModel? catastrophe;
  final ShelterModel? shelter;
  final DateTime createdAt;
  final DateTime? endedAt;
  final bool isCompleted;
  final int difficultyLevel;
  final int totalRounds;
  final List<PlayerModel> players;
  final bool hasPassword;

  @JsonKey(ignore: true)
  String? hostIp;

  @JsonKey(ignore: true)
  int? port;

  GameModel({ // Удалено const, так как у класса есть не-final поля
    required this.id,
    required this.name,
    required this.hostId,
    required this.state,
    required this.maxPlayers,
    required this.currentPlayers,
    required this.discussionTime,
    required this.voteTime,
    required this.voteType,
    required this.balanceLevel,
    required this.packId,
    this.catastrophe,
    this.shelter,
    required this.createdAt,
    this.endedAt,
    required this.isCompleted,
    required this.difficultyLevel,
    required this.totalRounds,
    required this.players,
    required this.hasPassword,
  });

  // Копирование с изменениями
  GameModel copyWith({
    String? id,
    String? name,
    String? hostId,
    GameState? state,
    int? maxPlayers,
    int? currentPlayers,
    int? discussionTime,
    int? voteTime,
    VoteType? voteType,
    String? balanceLevel,
    int? packId,
    CatastropheModel? catastrophe,
    ShelterModel? shelter,
    DateTime? createdAt,
    DateTime? endedAt,
    bool? isCompleted,
    int? difficultyLevel,
    int? totalRounds,
    List<PlayerModel>? players,
    bool? hasPassword,
    String? hostIp,
    int? port,
  }) {
    return GameModel(
      id: id ?? this.id,
      name: name ?? this.name,
      hostId: hostId ?? this.hostId,
      state: state ?? this.state,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      currentPlayers: currentPlayers ?? this.currentPlayers,
      discussionTime: discussionTime ?? this.discussionTime,
      voteTime: voteTime ?? this.voteTime,
      voteType: voteType ?? this.voteType,
      balanceLevel: balanceLevel ?? this.balanceLevel,
      packId: packId ?? this.packId,
      catastrophe: catastrophe ?? this.catastrophe,
      shelter: shelter ?? this.shelter,
      createdAt: createdAt ?? this.createdAt,
      endedAt: endedAt ?? this.endedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      totalRounds: totalRounds ?? this.totalRounds,
      players: players ?? this.players,
      hasPassword: hasPassword ?? this.hasPassword,
    )
      ..hostIp = hostIp ?? this.hostIp
      ..port = port ?? this.port;
  }

  // Фабричный метод для JSON
  factory GameModel.fromJson(Map<String, dynamic> json) => _$GameModelFromJson(json);

  // Сериализация в JSON
  Map<String, dynamic> toJson() => _$GameModelToJson(this);

  @override
  List<Object?> get props => [
    id, name, hostId, state, maxPlayers, currentPlayers,
    discussionTime, voteTime, voteType, balanceLevel, packId,
    catastrophe, shelter, createdAt, endedAt, isCompleted,
    difficultyLevel, totalRounds, players, hasPassword
  ];
}