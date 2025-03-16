import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bunker/data/models/game_model.dart';
import 'package:bunker/data/repositories/game_repository.dart';
import 'package:bunker/core/utils/logger.dart';
import 'package:get_it/get_it.dart';

// События
abstract class GameDiscoveryEvent extends Equatable {
  const GameDiscoveryEvent();

  @override
  List<Object?> get props => [];
}

class StartGameDiscovery extends GameDiscoveryEvent {}

class RefreshGamesList extends GameDiscoveryEvent {}

class StopGameDiscovery extends GameDiscoveryEvent {}

class GameFound extends GameDiscoveryEvent {
  final GameModel game;

  const GameFound(this.game);

  @override
  List<Object?> get props => [game];
}

class JoinGameRequested extends GameDiscoveryEvent {
  final GameModel game;
  final String playerName;
  final String password;

  const JoinGameRequested({
    required this.game,
    required this.playerName,
    this.password = '',
  });

  @override
  List<Object?> get props => [game, playerName, password];
}

class ConnectToGameDirectly extends GameDiscoveryEvent {
  final String ipAddress;
  final String playerName;
  final String password;

  const ConnectToGameDirectly({
    required this.ipAddress,
    required this.playerName,
    this.password = '',
  });

  @override
  List<Object?> get props => [ipAddress, playerName, password];
}

// Состояния
abstract class GameDiscoveryState extends Equatable {
  const GameDiscoveryState();

  @override
  List<Object?> get props => [];
}

class GameDiscoveryInitial extends GameDiscoveryState {}

class GameDiscoveryLoading extends GameDiscoveryState {}

class GameDiscoverySuccess extends GameDiscoveryState {
  final List<GameModel> games;

  const GameDiscoverySuccess({required this.games});

  @override
  List<Object?> get props => [games];
}

class GameDiscoveryFailure extends GameDiscoveryState {
  final String error;

  const GameDiscoveryFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

class JoiningGame extends GameDiscoveryState {
  final GameModel game;

  const JoiningGame({required this.game});

  @override
  List<Object?> get props => [game];
}

class JoinGameSuccess extends GameDiscoveryState {
  final GameModel game;
  final String playerName;

  const JoinGameSuccess({required this.game, required this.playerName});

  @override
  List<Object?> get props => [game, playerName];
}

class JoinGameFailure extends GameDiscoveryState {
  final String error;

  const JoinGameFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// БЛоК
class GameDiscoveryBloc extends Bloc<GameDiscoveryEvent, GameDiscoveryState> {
  final GameRepository _gameRepository = GetIt.I<GameRepository>();
  final _logger = Logger('GameDiscoveryBloc');
  StreamSubscription? _gameDiscoverySubscription;
  final List<GameModel> _discoveredGames = [];

  GameDiscoveryBloc() : super(GameDiscoveryInitial()) {
    on<StartGameDiscovery>(_onStartGameDiscovery);
    on<RefreshGamesList>(_onRefreshGamesList);
    on<StopGameDiscovery>(_onStopGameDiscovery);
    on<GameFound>(_onGameFound);
    on<JoinGameRequested>(_onJoinGameRequested);
    on<ConnectToGameDirectly>(_onConnectToGameDirectly);
  }

  void _onStartGameDiscovery(
      StartGameDiscovery event, Emitter<GameDiscoveryState> emit) async {
    emit(GameDiscoveryLoading());
    _discoveredGames.clear();

    try {
      await _gameRepository.initializeDiscovery();
      _subscribeToGameDiscovery();
      emit(const GameDiscoverySuccess(games: []));
    } catch (e) {
      _logger.error("Ошибка при инициализации обнаружения: $e");
      emit(GameDiscoveryFailure(error: e.toString()));
    }
  }

  void _onRefreshGamesList(
      RefreshGamesList event, Emitter<GameDiscoveryState> emit) {
    _discoveredGames.clear();
    emit(GameDiscoveryLoading());
    emit(GameDiscoverySuccess(games: _discoveredGames));
  }

  void _onStopGameDiscovery(
      StopGameDiscovery event, Emitter<GameDiscoveryState> emit) {
    _gameDiscoverySubscription?.cancel();
    _gameRepository.stopDiscovery();
  }

  void _onGameFound(GameFound event, Emitter<GameDiscoveryState> emit) {
    // Проверяем, есть ли уже эта игра в списке, и обновляем или добавляем
    final existingIndex = _discoveredGames.indexWhere((g) => g.id == event.game.id);

    if (existingIndex >= 0) {
      _discoveredGames[existingIndex] = event.game;
    } else {
      _discoveredGames.add(event.game);
    }

    emit(GameDiscoverySuccess(games: List<GameModel>.from(_discoveredGames)));
  }

  void _onJoinGameRequested(
      JoinGameRequested event, Emitter<GameDiscoveryState> emit) async {
    emit(JoiningGame(game: event.game));

    try {
      final success = await _gameRepository.joinGame(
        event.game.hostIp!,
        event.playerName,
        event.password,
      );

      if (success) {
        emit(JoinGameSuccess(game: event.game, playerName: event.playerName));
      } else {
        emit(const JoinGameFailure(error: "Не удалось присоединиться к игре"));
      }
    } catch (e) {
      _logger.error("Ошибка при присоединении к игре: $e");
      emit(JoinGameFailure(error: e.toString()));
    }
  }

  void _onConnectToGameDirectly(
      ConnectToGameDirectly event, Emitter<GameDiscoveryState> emit) async {
    emit(GameDiscoveryLoading());

    try {
      final success = await _gameRepository.joinGame(
        event.ipAddress,
        event.playerName,
        event.password,
      );

      if (success) {
        // Поскольку мы подключились напрямую, у нас нет GameModel, поэтому создаем временную
        final tempGame = GameModel(
          id: "direct_connect",
          name: "Прямое подключение",
          hostId: "unknown",
          state: GameState.lobby,
          maxPlayers: 10,
          currentPlayers: 2,
          discussionTime: 120,
          voteTime: 30,
          voteType: VoteType.open,
          balanceLevel: "casual",
          packId: 1,
          createdAt: DateTime.now(),
          isCompleted: false,
          difficultyLevel: 1,
          totalRounds: 5,
          players: const [],
          hasPassword: false,
        );

        emit(JoinGameSuccess(game: tempGame, playerName: event.playerName));
      } else {
        emit(const JoinGameFailure(error: "Не удалось подключиться к игре по указанному IP"));
      }
    } catch (e) {
      _logger.error("Ошибка при прямом подключении: $e");
      emit(JoinGameFailure(error: e.toString()));
    }
  }

  void _subscribeToGameDiscovery() {
    _gameDiscoverySubscription?.cancel();
    _gameDiscoverySubscription = _gameRepository.discoveredGames.listen(
          (game) {
        add(GameFound(game));
      },
      onError: (error) {
        _logger.error("Ошибка при обнаружении игр: $error");
        add(RefreshGamesList());
      },
    );
  }

  @override
  Future<void> close() {
    _gameDiscoverySubscription?.cancel();
    _gameRepository.stopDiscovery();
    return super.close();
  }
}
