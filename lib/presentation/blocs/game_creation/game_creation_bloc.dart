import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import 'package:bunker/data/models/game_model.dart';

// События
abstract class GameCreationEvent extends Equatable {
  const GameCreationEvent();

  @override
  List<Object?> get props => [];
}

class PlayerCountChanged extends GameCreationEvent {
  final int count;

  const PlayerCountChanged(this.count);

  @override
  List<Object?> get props => [count];
}

class GameNameChanged extends GameCreationEvent {
  final String name;

  const GameNameChanged(this.name);

  @override
  List<Object?> get props => [name];
}

class PasswordChanged extends GameCreationEvent {
  final String password;

  const PasswordChanged(this.password);

  @override
  List<Object?> get props => [password];
}

class ExtendedCardSetToggled extends GameCreationEvent {}

class SportsModeToggled extends GameCreationEvent {}

class DiscussionTimeChanged extends GameCreationEvent {
  final int time;

  const DiscussionTimeChanged(this.time);

  @override
  List<Object?> get props => [time];
}

class VoteTimeChanged extends GameCreationEvent {
  final int time;

  const VoteTimeChanged(this.time);

  @override
  List<Object?> get props => [time];
}

class VoteTypeChanged extends GameCreationEvent {
  final VoteType type;

  const VoteTypeChanged(this.type);

  @override
  List<Object?> get props => [type];
}

class CreateGameSubmitted extends GameCreationEvent {}

// Состояние
class GameCreationState extends Equatable {
  final int playerCount;
  final String gameName;
  final String password;
  final bool useExtendedCardSet;
  final bool useSportsMode;
  final int discussionTime;
  final int voteTime;
  final VoteType voteType;
  final bool isSubmitting;
  final bool isSuccess;
  final String? error;

  const GameCreationState({
    this.playerCount = 8,
    this.gameName = "Бункер",
    this.password = "",
    this.useExtendedCardSet = false,
    this.useSportsMode = false,
    this.discussionTime = 120, // секунды
    this.voteTime = 30, // секунды
    this.voteType = VoteType.open,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.error,
  });

  GameCreationState copyWith({
    int? playerCount,
    String? gameName,
    String? password,
    bool? useExtendedCardSet,
    bool? useSportsMode,
    int? discussionTime,
    int? voteTime,
    VoteType? voteType,
    bool? isSubmitting,
    bool? isSuccess,
    String? error,
  }) {
    return GameCreationState(
      playerCount: playerCount ?? this.playerCount,
      gameName: gameName ?? this.gameName,
      password: password ?? this.password,
      useExtendedCardSet: useExtendedCardSet ?? this.useExtendedCardSet,
      useSportsMode: useSportsMode ?? this.useSportsMode,
      discussionTime: discussionTime ?? this.discussionTime,
      voteTime: voteTime ?? this.voteTime,
      voteType: voteType ?? this.voteType,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error ?? this.error,
    );
  }

  GameModel toGameModel(String hostId) {
    return GameModel(
      id: const Uuid().v4(),
      name: gameName,
      hostId: hostId,
      state: GameState.lobby,
      maxPlayers: playerCount,
      currentPlayers: 1, // только хост в начале
      discussionTime: discussionTime,
      voteTime: voteTime,
      voteType: voteType,
      balanceLevel: useSportsMode ? 'competitive' : 'casual',
      packId: useExtendedCardSet ? 2 : 1,
      catastrophe: null, // будет выбрано при старте игры
      shelter: null, // будет выбрано при старте игры
      createdAt: DateTime.now(),
      isCompleted: false,
      difficultyLevel: useSportsMode ? 2 : 1,
      totalRounds: useSportsMode ? 3 : 5,
      players: const [],
      hasPassword: password.isNotEmpty,
    );
  }

  @override
  List<Object?> get props => [
    playerCount,
    gameName,
    password,
    useExtendedCardSet,
    useSportsMode,
    discussionTime,
    voteTime,
    voteType,
    isSubmitting,
    isSuccess,
    error,
  ];
}

// БЛоК
class GameCreationBloc extends Bloc<GameCreationEvent, GameCreationState> {
  GameCreationBloc() : super(const GameCreationState()) {
    on<PlayerCountChanged>(_onPlayerCountChanged);
    on<GameNameChanged>(_onGameNameChanged);
    on<PasswordChanged>(_onPasswordChanged);
    on<ExtendedCardSetToggled>(_onExtendedCardSetToggled);
    on<SportsModeToggled>(_onSportsModeToggled);
    on<DiscussionTimeChanged>(_onDiscussionTimeChanged);
    on<VoteTimeChanged>(_onVoteTimeChanged);
    on<VoteTypeChanged>(_onVoteTypeChanged);
    on<CreateGameSubmitted>(_onCreateGameSubmitted);
  }

  void _onPlayerCountChanged(
      PlayerCountChanged event, Emitter<GameCreationState> emit) {
    emit(state.copyWith(playerCount: event.count));
  }

  void _onGameNameChanged(
      GameNameChanged event, Emitter<GameCreationState> emit) {
    emit(state.copyWith(gameName: event.name));
  }

  void _onPasswordChanged(
      PasswordChanged event, Emitter<GameCreationState> emit) {
    emit(state.copyWith(password: event.password));
  }

  void _onExtendedCardSetToggled(
      ExtendedCardSetToggled event, Emitter<GameCreationState> emit) {
    emit(state.copyWith(useExtendedCardSet: !state.useExtendedCardSet));
  }

  void _onSportsModeToggled(
      SportsModeToggled event, Emitter<GameCreationState> emit) {
    emit(state.copyWith(useSportsMode: !state.useSportsMode));
  }

  void _onDiscussionTimeChanged(
      DiscussionTimeChanged event, Emitter<GameCreationState> emit) {
    emit(state.copyWith(discussionTime: event.time));
  }

  void _onVoteTimeChanged(
      VoteTimeChanged event, Emitter<GameCreationState> emit) {
    emit(state.copyWith(voteTime: event.time));
  }

  void _onVoteTypeChanged(
      VoteTypeChanged event, Emitter<GameCreationState> emit) {
    emit(state.copyWith(voteType: event.type));
  }

  void _onCreateGameSubmitted(
      CreateGameSubmitted event, Emitter<GameCreationState> emit) {
    emit(state.copyWith(isSubmitting: true));

    // В данном случае мы просто отмечаем успешное создание
    // Реальное создание игры произойдет через GameRepository в LobbyBloc
    emit(state.copyWith(isSubmitting: false, isSuccess: true));
  }
}
