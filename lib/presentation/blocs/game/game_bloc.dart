import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bunker/data/models/game_model.dart';
import 'package:bunker/data/models/player_model.dart';
import 'package:bunker/data/models/player_card_model.dart';
import 'package:bunker/data/models/game_round_model.dart';
import 'package:bunker/data/repositories/game_repository.dart';
import 'package:bunker/core/utils/logger.dart';
import 'package:get_it/get_it.dart';

// События
abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

class InitializeGame extends GameEvent {}

class GameStateUpdated extends GameEvent {
  final GameModel game;
  final List<GameRoundModel> rounds;

  const GameStateUpdated({required this.game, required this.rounds});

  @override
  List<Object?> get props => [game, rounds];
}

class RevealCharacteristic extends GameEvent {
  final String cardId;

  const RevealCharacteristic(this.cardId);

  @override
  List<Object?> get props => [cardId];
}

class VoteForPlayer extends GameEvent {
  final String playerId;

  const VoteForPlayer(this.playerId);

  @override
  List<Object?> get props => [playerId];
}

class AddTime extends GameEvent {
  final int seconds;

  const AddTime(this.seconds);

  @override
  List<Object?> get props => [seconds];
}

class LeaveGame extends GameEvent {}

class EndRound extends GameEvent {}

class GameComplete extends GameEvent {
  final String endingTitle;
  final String endingDescription;
  final bool isSuccess;

  const GameComplete({
    required this.endingTitle,
    required this.endingDescription,
    required this.isSuccess,
  });

  @override
  List<Object?> get props => [endingTitle, endingDescription, isSuccess];
}

// Состояния
abstract class GameBlocState extends Equatable {
  const GameBlocState();

  @override
  List<Object?> get props => [];
}

class GameInitial extends GameBlocState {}

class GameLoading extends GameBlocState {}

class GameRunning extends GameBlocState {
  final GameModel game;
  final PlayerModel currentPlayer;
  final List<GameRoundModel> rounds;
  final int currentPlayerIndex;
  final int currentRoundIndex;
  final bool votingEnabled;
  final Map<String, int> voteCount;
  final int remainingTime;
  final bool isRoundEnding;

  const GameRunning({
    required this.game,
    required this.currentPlayer,
    required this.rounds,
    required this.currentPlayerIndex,
    required this.currentRoundIndex,
    required this.votingEnabled,
    required this.voteCount,
    required this.remainingTime,
    required this.isRoundEnding,
  });

  @override
  List<Object?> get props => [
    game,
    currentPlayer,
    rounds,
    currentPlayerIndex,
    currentRoundIndex,
    votingEnabled,
    voteCount,
    remainingTime,
    isRoundEnding,
  ];

  // Создание копии с изменениями
  GameRunning copyWith({
    GameModel? game,
    PlayerModel? currentPlayer,
    List<GameRoundModel>? rounds,
    int? currentPlayerIndex,
    int? currentRoundIndex,
    bool? votingEnabled,
    Map<String, int>? voteCount,
    int? remainingTime,
    bool? isRoundEnding,
  }) {
    return GameRunning(
      game: game ?? this.game,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      rounds: rounds ?? this.rounds,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      currentRoundIndex: currentRoundIndex ?? this.currentRoundIndex,
      votingEnabled: votingEnabled ?? this.votingEnabled,
      voteCount: voteCount ?? this.voteCount,
      remainingTime: remainingTime ?? this.remainingTime,
      isRoundEnding: isRoundEnding ?? this.isRoundEnding,
    );
  }
}

class GameEnded extends GameBlocState {
  final String endingTitle;
  final String endingDescription;
  final bool isSuccess;
  final List<PlayerModel> survivors;

  const GameEnded({
    required this.endingTitle,
    required this.endingDescription,
    required this.isSuccess,
    required this.survivors,
  });

  @override
  List<Object?> get props => [
    endingTitle,
    endingDescription,
    isSuccess,
    survivors,
  ];
}

class GameError extends GameBlocState {
  final String error;

  const GameError(this.error);

  @override
  List<Object?> get props => [error];
}

// БЛоК
class GameBloc extends Bloc<GameEvent, GameBlocState> {
  final GameRepository _gameRepository = GetIt.I<GameRepository>();
  final _logger = Logger('GameBloc');
  StreamSubscription? _gameSubscription;
  StreamSubscription? _playerSubscription;
  StreamSubscription? _timerSubscription;
  Timer? _gameTimer;

  GameBloc() : super(GameInitial()) {
    on<InitializeGame>(_onInitializeGame);
    on<GameStateUpdated>(_onGameStateUpdated);
    on<RevealCharacteristic>(_onRevealCharacteristic);
    on<VoteForPlayer>(_onVoteForPlayer);
    on<AddTime>(_onAddTime);
    on<LeaveGame>(_onLeaveGame);
    on<EndRound>(_onEndRound);
    on<GameComplete>(_onGameComplete);
  }

  void _onInitializeGame(
    InitializeGame event,
    Emitter<GameBlocState> emit,
  ) async {
    emit(GameLoading());

    try {
      // Подписываемся на обновления игры
      _subscribeToGameUpdates();

      // Запускаем игровой таймер
      _startGameTimer();
    } catch (e) {
      _logger.error("Ошибка при инициализации игры: $e");
      emit(GameError(e.toString()));
    }
  }

  void _onGameStateUpdated(
    GameStateUpdated event,
    Emitter<GameBlocState> emit,
  ) {
    // Если игра завершена, переходим в соответствующее состояние
    if (event.game.isCompleted) {
      _getEndingForGame(event.game).then((ending) {
        add(
          GameComplete(
            endingTitle: ending['title'] ?? 'Игра окончена',
            endingDescription:
                ending['description'] ?? 'Некоторые выжили, некоторые нет...',
            isSuccess: ending['isSuccess'] ?? false,
          ),
        );
      });
      return;
    }

    try {
      // Получаем текущего игрока
      final currentPlayer = event.game.players.firstWhere(
        (player) => player.id == _gameRepository.currentPlayerId,
        orElse: () => throw Exception("Игрок не найден"),
      );

      // Определяем индекс текущего игрока
      final currentPlayerIndex = event.game.players.indexOf(currentPlayer);

      // Определяем текущий раунд
      final currentRoundIndex =
          event.rounds.isEmpty ? 0 : event.rounds.length - 1;

      // Определяем, активно ли голосование
      final votingEnabled =
          event.game.state == GameState.inProgress &&
          !currentPlayer.isEliminated;

      // Словарь с количеством голосов за каждого игрока
      final voteCount = <String, int>{};
      if (event.rounds.isNotEmpty) {
        final currentRound = event.rounds.last;
        for (var elimination in currentRound.eliminations) {
          voteCount[elimination.playerId] = elimination.votesReceived;
        }
      }

      // Определяем, заканчивается ли раунд
      final isRoundEnding =
          event.rounds.isNotEmpty &&
          event.rounds.last.isCompleted &&
          event.game.state == GameState.inProgress;

      // Определяем оставшееся время
      int remainingTime = 0;
      if (event.rounds.isNotEmpty && !event.rounds.last.isCompleted) {
        final currentRound = event.rounds.last;
        final endTime =
            currentRound.endTime ??
            DateTime.now().add(Duration(seconds: event.game.discussionTime));
        remainingTime = endTime.difference(DateTime.now()).inSeconds;
        if (remainingTime < 0) remainingTime = 0;
      }

      emit(
        GameRunning(
          game: event.game,
          currentPlayer: currentPlayer,
          rounds: event.rounds,
          currentPlayerIndex: currentPlayerIndex,
          currentRoundIndex: currentRoundIndex,
          votingEnabled: votingEnabled,
          voteCount: voteCount,
          remainingTime: remainingTime,
          isRoundEnding: isRoundEnding,
        ),
      );
    } catch (e) {
      _logger.error("Ошибка при обновлении состояния игры: $e");
      emit(GameError(e.toString()));
    }
  }

  void _onRevealCharacteristic(
    RevealCharacteristic event,
    Emitter<GameBlocState> emit,
  ) async {
    if (state is GameRunning) {
      try {
        await _gameRepository.revealPlayerCard(event.cardId);
      } catch (e) {
        _logger.error("Ошибка при раскрытии характеристики: $e");
      }
    }
  }

  void _onVoteForPlayer(
    VoteForPlayer event,
    Emitter<GameBlocState> emit,
  ) async {
    if (state is GameRunning) {
      final currentState = state as GameRunning;

      if (!currentState.votingEnabled) return;

      try {
        await _gameRepository.voteForPlayer(event.playerId);

        // Обновляем счетчик голосов локально
        final updatedVoteCount = Map<String, int>.from(currentState.voteCount);
        updatedVoteCount[event.playerId] =
            (updatedVoteCount[event.playerId] ?? 0) + 1;

        emit(currentState.copyWith(voteCount: updatedVoteCount));
      } catch (e) {
        _logger.error("Ошибка при голосовании: $e");
      }
    }
  }

  void _onAddTime(AddTime event, Emitter<GameBlocState> emit) async {
    if (state is GameRunning) {
      try {
        await _gameRepository.addTimeToRound(event.seconds);
      } catch (e) {
        _logger.error("Ошибка при добавлении времени: $e");
      }
    }
  }

  void _onLeaveGame(LeaveGame event, Emitter<GameBlocState> emit) async {
    try {
      _gameSubscription?.cancel();
      _playerSubscription?.cancel();
      _timerSubscription?.cancel();
      _gameTimer?.cancel();

      await _gameRepository.leaveGame();
    } catch (e) {
      _logger.error("Ошибка при выходе из игры: $e");
    }
  }

  void _onEndRound(EndRound event, Emitter<GameBlocState> emit) async {
    if (state is GameRunning) {
      final currentState = state as GameRunning;

      try {
        if (currentState.isRoundEnding &&
            currentState.game.players.any(
              (player) =>
                  player.isHost && player.id == _gameRepository.currentPlayerId,
            )) {
          await _gameRepository.endRound();
        }
      } catch (e) {
        _logger.error("Ошибка при завершении раунда: $e");
      }
    }
  }

  void _onGameComplete(GameComplete event, Emitter<GameBlocState> emit) {
    if (state is GameRunning) {
      final currentState = state as GameRunning;

      // Определяем выживших
      final survivors =
          currentState.game.players
              .where((player) => !player.isEliminated)
              .toList();

      emit(
        GameEnded(
          endingTitle: event.endingTitle,
          endingDescription: event.endingDescription,
          isSuccess: event.isSuccess,
          survivors: survivors,
        ),
      );
    }
  }

  void _subscribeToGameUpdates() {
    // Подписка на обновления игры
    _gameSubscription = _gameRepository.gameStream.listen(
      (game) {
        // Получаем раунды для этой игры
        _gameRepository.getRoundsForGame(game.id).then((rounds) {
          add(GameStateUpdated(game: game, rounds: rounds));
        });
      },
      onError: (error) {
        _logger.error("Ошибка при получении обновлений игры: $error");
      },
    );

    // Подписка на обновления игрока
    _playerSubscription = _gameRepository.playerStream.listen(
      (player) {
        // Обрабатываем обновления конкретного игрока, если нужно
      },
      onError: (error) {
        _logger.error("Ошибка при получении обновлений игрока: $error");
      },
    );
  }

  void _startGameTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state is GameRunning) {
        final currentState = state as GameRunning;

        if (currentState.remainingTime > 0) {
          emit(
            currentState.copyWith(
              remainingTime: currentState.remainingTime - 1,
            ),
          );
        } else if (!currentState.isRoundEnding &&
            currentState.game.players.any(
              (player) =>
                  player.isHost && player.id == _gameRepository.currentPlayerId,
            )) {
          // Если время вышло и текущий игрок - хост, завершаем раунд
          add(EndRound());
        }
      }
    });
  }

  Future<Map<String, dynamic>> _getEndingForGame(GameModel game) async {
    // Здесь должна быть логика получения концовки из базы данных или генерация новой
    // В данном примере возвращаем заглушку
    try {
      // Проверяем, есть ли выжившие
      final survivors =
          game.players.where((player) => !player.isEliminated).toList();
      final isSuccess = survivors.length >= game.maxPlayers ~/ 2;

      if (isSuccess) {
        return {
          'title': 'Выжившие спаслись!',
          'description':
              'Оставшимся в бункере удалось пережить катастрофу и заложить основы нового общества. '
              'Несмотря на все трудности, человечество получило шанс на новое начало.',
          'isSuccess': true,
        };
      } else {
        return {
          'title': 'Последний свет угас...',
          'description':
              'К сожалению, выбранная группа оказалась неспособной к выживанию. '
              'Их разногласия и недостаток необходимых навыков привели к тому, что '
              'бункер не смог функционировать достаточно долго.',
          'isSuccess': false,
        };
      }
    } catch (e) {
      _logger.error("Ошибка при получении концовки: $e");
      return {
        'title': 'Игра окончена',
        'description': 'Интересное приключение подошло к концу.',
        'isSuccess': false,
      };
    }
  }

  @override
  Future<void> close() {
    _gameSubscription?.cancel();
    _playerSubscription?.cancel();
    _timerSubscription?.cancel();
    _gameTimer?.cancel();
    return super.close();
  }
}
