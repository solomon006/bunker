import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import 'package:bunker/data/models/game_model.dart';
import 'package:bunker/data/models/player_model.dart';
import 'package:bunker/data/repositories/game_repository.dart';
import 'package:bunker/core/utils/logger.dart';
import 'package:get_it/get_it.dart';

// События
abstract class LobbyEvent extends Equatable {
  const LobbyEvent();

  @override
  List<Object?> get props => [];
}

class InitLobby extends LobbyEvent {
  final GameModel? game;
  final bool isHost;
  final String playerName;

  const InitLobby({
    this.game,
    required this.isHost,
    required this.playerName,
  });

  @override
  List<Object?> get props => [game, isHost, playerName];
}

class CreateGame extends LobbyEvent {
  final GameModel game;

  const CreateGame(this.game);

  @override
  List<Object?> get props => [game];
}

class LobbyUpdated extends LobbyEvent {
  final GameModel game;

  const LobbyUpdated(this.game);

  @override
  List<Object?> get props => [game];
}

class ToggleReady extends LobbyEvent {}

class KickPlayer extends LobbyEvent {
  final String playerId;

  const KickPlayer(this.playerId);

  @override
  List<Object?> get props => [playerId];
}

class StartGame extends LobbyEvent {}

class LeaveLobby extends LobbyEvent {}

// Состояния
abstract class LobbyState extends Equatable {
  const LobbyState();

  @override
  List<Object?> get props => [];
}

class LobbyInitial extends LobbyState {}

class LobbyLoading extends LobbyState {}

class LobbyReady extends LobbyState {
  final GameModel game;
  final PlayerModel currentPlayer;
  final bool isHost;
  final bool isReady;

  const LobbyReady({
    required this.game,
    required this.currentPlayer,
    required this.isHost,
    required this.isReady,
  });

  @override
  List<Object?> get props => [game, currentPlayer, isHost, isReady];
}

class LobbyError extends LobbyState {
  final String error;

  const LobbyError(this.error);

  @override
  List<Object?> get props => [error];
}

class GameStarting extends LobbyState {}

class LobbyLeft extends LobbyState {}

// БЛоК
class LobbyBloc extends Bloc<LobbyEvent, LobbyState> {
  final GameRepository _gameRepository = GetIt.I<GameRepository>();
  final _logger = Logger('LobbyBloc');
  StreamSubscription? _gameSubscription;
  late PlayerModel _currentPlayer;
  bool _isHost = false;
  bool _isReady = false;
  String _sessionId = '';

  LobbyBloc() : super(LobbyInitial()) {
    on<InitLobby>(_onInitLobby);
    on<CreateGame>(_onCreateGame);
    on<LobbyUpdated>(_onLobbyUpdated);
    on<ToggleReady>(_onToggleReady);
    on<KickPlayer>(_onKickPlayer);
    on<StartGame>(_onStartGame);
    on<LeaveLobby>(_onLeaveLobby);
  }

  void _onInitLobby(InitLobby event, Emitter<LobbyState> emit) async {
    emit(LobbyLoading());

    _isHost = event.isHost;
    _sessionId = const Uuid().v4();

    try {
      if (_isHost && event.game != null) {
        // Хост создает новую игру
        add(CreateGame(event.game!));
      } else if (!_isHost && event.game != null) {
        // Игрок уже подключен к игре, просто настраиваем подписку
        _subscribeToGameUpdates();

        // Создаем экземпляр текущего игрока
        _currentPlayer = PlayerModel(
          id: _sessionId,
          name: event.playerName,
          connectionId: _sessionId,
          userId: _sessionId,
          orderNumber: event.game!.players.length + 1,
          isEliminated: false,
          isHost: false,
          isSelected: false,
          isSurvivor: true,
          cards: const [],
        );

        emit(LobbyReady(
          game: event.game!,
          currentPlayer: _currentPlayer,
          isHost: _isHost,
          isReady: _isReady,
        ));
      } else {
        emit(const LobbyError("Некорректные параметры инициализации лобби"));
      }
    } catch (e) {
      _logger.error("Ошибка при инициализации лобби: $e");
      emit(LobbyError(e.toString()));
    }
  }

  void _onCreateGame(CreateGame event, Emitter<LobbyState> emit) async {
    emit(LobbyLoading());

    try {
      // Создаем экземпляр текущего игрока-хоста
      _currentPlayer = PlayerModel(
        id: _sessionId,
        name: "Хост",
        connectionId: _sessionId,
        userId: _sessionId,
        orderNumber: 1,
        isEliminated: false,
        isHost: true,
        isSelected: false,
        isSurvivor: true,
        cards: const [],
      );

      // Создаем игру через репозиторий
      final success = await _gameRepository.createGame(
          event.game.copyWith(
            hostId: _sessionId,
            players: [_currentPlayer],
            currentPlayers: 1,
          )
      );

      if (success) {
        _subscribeToGameUpdates();
        emit(LobbyReady(
          game: event.game,
          currentPlayer: _currentPlayer,
          isHost: _isHost,
          isReady: _isReady,
        ));
      } else {
        emit(const LobbyError("Не удалось создать игру"));
      }
    } catch (e) {
      _logger.error("Ошибка при создании игры: $e");
      emit(LobbyError(e.toString()));
    }
  }

  void _onLobbyUpdated(LobbyUpdated event, Emitter<LobbyState> emit) {
    // Получаем обновленного текущего игрока из списка игроков
    final updatedCurrentPlayer = event.game.players.firstWhere(
          (player) => player.id == _currentPlayer.id,
      orElse: () => _currentPlayer,
    );

    _currentPlayer = updatedCurrentPlayer;
    _isReady = updatedCurrentPlayer.isSelected; // isSelected используется как флаг готовности

    emit(LobbyReady(
      game: event.game,
      currentPlayer: _currentPlayer,
      isHost: _isHost,
      isReady: _isReady,
    ));
  }

  void _onToggleReady(ToggleReady event, Emitter<LobbyState> emit) async {
    if (state is LobbyReady) {
      final currentState = state as LobbyReady;

      try {
        // Меняем статус готовности
        _isReady = !_isReady;

        // Обновляем игрока
        final updatedPlayer = _currentPlayer.copyWith(isSelected: _isReady);
        await _gameRepository.updatePlayerStatus(updatedPlayer);

        emit(LobbyReady(
          game: currentState.game,
          currentPlayer: updatedPlayer,
          isHost: _isHost,
          isReady: _isReady,
        ));
      } catch (e) {
        _logger.error("Ошибка при изменении статуса готовности: $e");
      }
    }
  }

  void _onKickPlayer(KickPlayer event, Emitter<LobbyState> emit) async {
    if (state is LobbyReady && _isHost) {
      try {
        await _gameRepository.kickPlayer(event.playerId);
      } catch (e) {
        _logger.error("Ошибка при исключении игрока: $e");
      }
    }
  }

  void _onStartGame(StartGame event, Emitter<LobbyState> emit) async {
    if (state is LobbyReady && _isHost) {
      emit(GameStarting());

      try {
        final success = await _gameRepository.startGame();

        if (!success) {
          final currentState = state as LobbyReady;
          emit(LobbyReady(
            game: currentState.game,
            currentPlayer: _currentPlayer,
            isHost: _isHost,
            isReady: _isReady,
          ));
        }
      } catch (e) {
        _logger.error("Ошибка при запуске игры: $e");
        if (state is GameStarting) {
          emit(LobbyError(e.toString()));
        }
      }
    }
  }

  void _onLeaveLobby(LeaveLobby event, Emitter<LobbyState> emit) async {
    try {
      _gameSubscription?.cancel();
      await _gameRepository.leaveLobby();
      emit(LobbyLeft());
    } catch (e) {
      _logger.error("Ошибка при выходе из лобби: $e");
    }
  }

  void _subscribeToGameUpdates() {
    _gameSubscription?.cancel();
    _gameSubscription = _gameRepository.gameStream.listen(
          (game) {
        add(LobbyUpdated(game));

        // Проверяем, не запущена ли игра
        if (game.state == GameState.inProgress) {
          // Переход к экрану игры будет реализован через навигацию в UI,
          // когда блок перейдет в состояние GameStarting
          add(StartGame());
        }
      },
      onError: (error) {
        _logger.error("Ошибка при получении обновлений игры: $error");
      },
    );
  }

  @override
  Future<void> close() {
    _gameSubscription?.cancel();
    return super.close();
  }
}
