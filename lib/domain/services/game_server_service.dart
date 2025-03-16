import 'dart:async';
import 'package:bunker/data/models/game_model.dart';
import 'package:bunker/data/models/player_model.dart';
import 'package:bunker/data/models/player_card_model.dart';
import 'package:bunker/data/models/game_round_model.dart';
import 'package:bunker/data/models/round_elimination_model.dart';
import 'package:bunker/data/models/catastrophe_model.dart';
import 'package:bunker/data/models/shelter_model.dart';
import 'package:bunker/data/models/generated_ending_model.dart';
import 'package:bunker/core/network/connection_manager.dart';
import 'package:bunker/core/utils/logger.dart';
import 'package:bunker/core/utils/game_content_generator.dart';
import 'package:uuid/uuid.dart';

/// Сервис, управляющий игровой логикой на устройстве хоста
class GameServerService {
  final Logger _logger = Logger('GameServerService');
  final ConnectionManager _connectionManager;
  final GameContentGenerator _contentGenerator;
  final Uuid _uuid = const Uuid();

  // Игровые данные
  GameModel? _currentGame;
  List<PlayerModel> _players = [];
  List<GameRoundModel> _rounds = [];
  Map<String, Map<String, String>> _votes = {}; // roundId -> {voterId -> targetId}

  // Таймеры
  Timer? _discussionTimer;
  Timer? _voteTimer;

  // Информация о текущем раунде
  int _currentRoundIndex = 0;
  bool _isVotingPhase = false;

  // Стримы для подписки на игровые события
  final _gameEventsController = StreamController<GameEvent>.broadcast();
  Stream<GameEvent> get gameEvents => _gameEventsController.stream;

  // Конструктор
  GameServerService({
    required ConnectionManager connectionManager,
    required GameContentGenerator contentGenerator,
  }) : _connectionManager = connectionManager,
        _contentGenerator = contentGenerator;

  // Инициализация игрового сервера
  Future<bool> initializeServer(GameModel initialGame, PlayerModel host) async {
    try {
      _currentGame = initialGame;
      _players = [host];

      // Отправляем информацию о сервере
      _connectionManager.updateGameState(initialGame);

      // Подписываемся на сообщения от клиентов
      _setupMessageHandlers();

      _logger.info('Игровой сервер инициализирован');
      return true;
    } catch (e) {
      _logger.error('Ошибка при инициализации игрового сервера: $e');
      return false;
    }
  }

  // Настройка обработчиков сообщений
  void _setupMessageHandlers() {
    // TODO: Реализовать подписку на сообщения
  }

  // Добавление нового игрока в игру
  bool addPlayer(PlayerModel player) {
    try {
      if (_currentGame == null) return false;

      // Проверяем, не заполнена ли уже игра
      if (_players.length >= _currentGame!.maxPlayers) {
        _logger.warn('Невозможно добавить игрока: достигнуто максимальное количество');
        return false;
      }

      // Проверяем, не началась ли уже игра
      if (_currentGame!.state != GameState.lobby) {
        _logger.warn('Невозможно добавить игрока: игра уже началась');
        return false;
      }

      // Назначаем порядковый номер игроку
      final updatedPlayer = player.copyWith(
        orderNumber: _players.length + 1,
      );

      // Добавляем игрока в список
      _players.add(updatedPlayer);

      // Обновляем состояние игры
      _updateGameState();

      _logger.info('Игрок ${player.name} добавлен в игру');
      return true;
    } catch (e) {
      _logger.error('Ошибка при добавлении игрока: $e');
      return false;
    }
  }

  // Удаление игрока из игры
  bool removePlayer(String playerId) {
    try {
      if (_currentGame == null) return false;

      // Проверяем, не началась ли уже игра
      if (_currentGame!.state != GameState.lobby) {
        // Если игра уже началась, помечаем игрока как исключенного
        final playerIndex = _players.indexWhere((p) => p.id == playerId);
        if (playerIndex >= 0) {
          final player = _players[playerIndex];
          _players[playerIndex] = player.copyWith(isEliminated: true);
          _updateGameState();

          _logger.info('Игрок ${player.name} помечен как исключенный');
          return true;
        }
      } else {
        // Если игра не началась, удаляем игрока
        final initialCount = _players.length;
        _players.removeWhere((p) => p.id == playerId);

        if (_players.length < initialCount) {
          // Пересчитываем порядковые номера
          for (int i = 0; i < _players.length; i++) {
            if (_players[i].isHost) continue;
            _players[i] = _players[i].copyWith(orderNumber: i + 1);
          }

          _updateGameState();
          _logger.info('Игрок удален из игры');
          return true;
        }
      }

      return false;
    } catch (e) {
      _logger.error('Ошибка при удалении игрока: $e');
      return false;
    }
  }

  // Обновление статуса игрока
  bool updatePlayerStatus(PlayerModel updatedPlayer) {
    try {
      if (_currentGame == null) return false;

      // Находим игрока в списке
      final playerIndex = _players.indexWhere((p) => p.id == updatedPlayer.id);
      if (playerIndex < 0) return false;

      // Обновляем статус
      _players[playerIndex] = updatedPlayer;

      // Обновляем состояние игры
      _updateGameState();

      return true;
    } catch (e) {
      _logger.error('Ошибка при обновлении статуса игрока: $e');
      return false;
    }
  }

  // Запуск игры
  Future<bool> startGame(List<Map<String, dynamic>> cardsByType) async {
    try {
      if (_currentGame == null) return false;

      // Проверяем готовность игры к запуску
      if (_players.length < 4) {
        _logger.warn('Недостаточно игроков для начала игры');
        return false;
      }

      if (_currentGame!.state != GameState.lobby) {
        _logger.warn('Игра уже запущена');
        return false;
      }

      // Генерируем карточки для игроков
      for (int i = 0; i < _players.length; i++) {
        final cards = await _contentGenerator.generatePlayerCards(cardsByType);
        _players[i] = _players[i].copyWith(cards: cards);
      }

      // Создаем первый раунд
      final firstRound = GameRoundModel(
        id: _uuid.v4(),
        gameId: _currentGame!.id,
        roundNumber: 1,
        targetEliminationCount: (_players.length * 0.2).ceil(), // 20% игроков в первом раунде
        startTime: DateTime.now(),
        isCompleted: false,
        eliminations: const [],
      );

      _rounds.add(firstRound);
      _currentRoundIndex = 0;

      // Обновляем состояние игры
      _currentGame = _currentGame!.copyWith(
        state: GameState.inProgress,
        currentPlayers: _players.length,
      );

      _updateGameState();

      // Запускаем таймер обсуждения
      _startDiscussionTimer();

      _logger.info('Игра запущена');
      return true;
    } catch (e) {
      _logger.error('Ошибка при запуске игры: $e');
      return false;
    }
  }

  // Раскрытие карточки игрока
  bool revealPlayerCard(String playerId, String cardId) {
    try {
      if (_currentGame == null) return false;

      // Находим игрока
      final playerIndex = _players.indexWhere((p) => p.id == playerId);
      if (playerIndex < 0) return false;

      final player = _players[playerIndex];

      // Находим карточку
      final cardIndex = player.cards.indexWhere((c) => c.id == cardId);
      if (cardIndex < 0) return false;

      // Проверяем, что карточка еще не раскрыта
      if (player.cards[cardIndex].isRevealed) return true;

      // Раскрываем карточку
      final updatedCards = List<PlayerCardModel>.from(player.cards);
      updatedCards[cardIndex] = updatedCards[cardIndex].copyWith(isRevealed: true);

      // Обновляем игрока
      _players[playerIndex] = player.copyWith(cards: updatedCards);

      // Обновляем состояние игры
      _updateGameState();

      _logger.info('Игрок ${player.name} раскрыл карточку ${player.cards[cardIndex].type}');
      return true;
    } catch (e) {
      _logger.error('Ошибка при раскрытии карточки: $e');
      return false;
    }
  }

  // Голосование за исключение игрока
  bool voteForPlayer(String voterId, String targetId) {
    try {
      if (_currentGame == null || _rounds.isEmpty || !_isVotingPhase) return false;

      // Проверяем, что игрок не голосует за себя
      if (voterId == targetId) {
        _logger.warn('Игрок не может голосовать за себя');
        return false;
      }

      // Находим игроков
      final voterIndex = _players.indexWhere((p) => p.id == voterId);
      final targetIndex = _players.indexWhere((p) => p.id == targetId);

      if (voterIndex < 0 || targetIndex < 0) return false;

      // Проверяем, что игроки не исключены
      if (_players[voterIndex].isEliminated || _players[targetIndex].isEliminated) {
        _logger.warn('Исключенные игроки не могут участвовать в голосовании');
        return false;
      }

      // Получаем текущий раунд
      final currentRound = _rounds[_currentRoundIndex];

      // Инициализируем карту голосов для текущего раунда, если необходимо
      if (!_votes.containsKey(currentRound.id)) {
        _votes[currentRound.id] = {};
      }

      // Записываем голос
      _votes[currentRound.id]![voterId] = targetId; // A value of type 'String' can't be assigned to a variable of type 'bool'.

      // Отправляем обновление о голосовании
      _gameEventsController.add(VoteEvent(
        roundId: currentRound.id,
        voterId: voterId,
        targetId: targetId,
      ));

      _logger.info('Игрок $voterId проголосовал за $targetId');
      return true;
    } catch (e) {
      _logger.error('Ошибка при голосовании: $e');
      return false;
    }
  }

  // Завершение фазы обсуждения и переход к голосованию
  void endDiscussionPhase() {
    if (_currentGame == null || _rounds.isEmpty) return;

    // Останавливаем таймер обсуждения
    _discussionTimer?.cancel();

    // Переходим к фазе голосования
    _isVotingPhase = true;

    // Отправляем уведомление о начале голосования
    _gameEventsController.add(PhaseChangeEvent(
      roundId: _rounds[_currentRoundIndex].id,
      phase: GamePhase.voting,
    ));

    // Запускаем таймер голосования
    _startVoteTimer();

    _logger.info('Начата фаза голосования');
  }

  // Завершение фазы голосования и обработка результатов
  void endVotingPhase() {
    if (_currentGame == null || _rounds.isEmpty) return;

    // Останавливаем таймер голосования
    _voteTimer?.cancel();

    // Получаем текущий раунд
    final currentRound = _rounds[_currentRoundIndex];

    // Подсчитываем голоса
    final voteResults = _countVotes(currentRound.id);

    // Находим игроков для исключения
    final playersToEliminate = _determinePlayersToEliminate(
      voteResults,
      currentRound.targetEliminationCount,
    );

    // Исключаем игроков
    final eliminations = <RoundEliminationModel>[];

    for (final entry in playersToEliminate.entries) {
      final playerId = entry.key;
      final votes = entry.value;

      // Находим игрока
      final playerIndex = _players.indexWhere((p) => p.id == playerId);
      if (playerIndex < 0) continue;

      // Помечаем игрока как исключенного
      _players[playerIndex] = _players[playerIndex].copyWith(
        isEliminated: true,
        eliminationRound: currentRound.roundNumber,
      );

      // Создаем запись об исключении
      eliminations.add(RoundEliminationModel(
        id: _uuid.v4(),
        roundId: currentRound.id,
        playerId: playerId,
        votesReceived: votes,
        eliminationReason: 'Результат голосования',
        eliminatedAt: DateTime.now(),
      ));
    }

    // Обновляем раунд
    _rounds[_currentRoundIndex] = currentRound.copyWith(
      isCompleted: true,
      endTime: DateTime.now(),
      eliminations: eliminations,
      roundSummary: 'Исключено игроков: ${eliminations.length}',
    );

    // Отправляем уведомление о результатах голосования
    _gameEventsController.add(VoteResultEvent(
      roundId: currentRound.id,
      results: voteResults,
      eliminations: eliminations,
    ));

    // Проверяем условия завершения игры
    final remainingPlayers = _players.where((p) => !p.isEliminated).length;

    if (remainingPlayers <= _currentGame!.maxPlayers ~/ 2) {
      // Условие завершения игры - выживание половины игроков
      _endGame(GameEndReason.targetSurvivorsReached);
    } else if (_currentRoundIndex + 1 >= _currentGame!.totalRounds) {
      // Условие завершения игры - достигнуто максимальное количество раундов
      _endGame(GameEndReason.maxRoundsReached);
    } else {
      // Переходим к следующему раунду
      _startNextRound();
    }

    _logger.info('Завершена фаза голосования');
  }

  // Запуск следующего раунда
  void _startNextRound() {
    if (_currentGame == null) return;

    // Увеличиваем индекс текущего раунда
    _currentRoundIndex++;

    // Определяем количество игроков для исключения в этом раунде
    final targetEliminations = (_players.where((p) => !p.isEliminated).length * 0.2).ceil();

    // Создаем новый раунд
    final newRound = GameRoundModel(
      id: _uuid.v4(),
      gameId: _currentGame!.id,
      roundNumber: _currentRoundIndex + 1,
      targetEliminationCount: targetEliminations,
      startTime: DateTime.now(),
      isCompleted: false,
      eliminations: const [],
    );

    // Добавляем раунд в список
    _rounds.add(newRound);

    // Переходим к фазе обсуждения
    _isVotingPhase = false;

    // Отправляем уведомление о начале нового раунда
    _gameEventsController.add(RoundStartEvent(
      roundId: newRound.id,
      roundNumber: newRound.roundNumber,
      targetEliminations: newRound.targetEliminationCount,
    ));

    // Запускаем таймер обсуждения
    _startDiscussionTimer();

    _logger.info('Начат раунд ${newRound.roundNumber}');
  }

  // Подсчет голосов
  Map<String, int> _countVotes(String roundId) {
    final results = <String, int>{};

    // Получаем голоса для текущего раунда
    final roundVotes = _votes[roundId] ?? {};

    // Подсчитываем количество голосов для каждого игрока
    for (final targetId in roundVotes.values) {
      if (!results.containsKey(targetId)) {
        results[targetId] = 0; // The argument type 'bool' can't be assigned to the parameter type 'String'.
      }
      results[targetId] = results[targetId]! + 1; // The argument type 'bool' can't be assigned to the parameter type 'String'.
    }

    return results;
  }

  // Определение игроков для исключения
  Map<String, int> _determinePlayersToEliminate(
      Map<String, int> voteResults,
      int targetCount,
      ) {
    // Сортируем результаты по количеству голосов
    final sortedResults = voteResults.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Выбираем игроков с наибольшим количеством голосов
    final eliminated = <String, int>{};
    int eliminatedCount = 0;

    for (int i = 0; i < sortedResults.length && eliminatedCount < targetCount; i++) {
      eliminated[sortedResults[i].key] = sortedResults[i].value;
      eliminatedCount++;
    }

    return eliminated;
  }

  // Завершение игры
  Future<void> _endGame(GameEndReason reason) async {
    if (_currentGame == null) return;

    // Останавливаем таймеры
    _discussionTimer?.cancel();
    _voteTimer?.cancel();

    // Помечаем выживших
    for (int i = 0; i < _players.length; i++) {
      if (!_players[i].isEliminated) {
        _players[i] = _players[i].copyWith(isSurvivor: true);
      }
    }

    // Определяем, была ли игра успешной
    final remainingPlayers = _players.where((p) => !p.isEliminated).length;
    final isSuccess = remainingPlayers >= _currentGame!.maxPlayers ~/ 2;

    // Генерируем концовку
    final survivors = _players.where((p) => !p.isEliminated).toList();

    // Обновляем состояние игры
    _currentGame = _currentGame!.copyWith(
      state: GameState.ended,
      isCompleted: true,
      endedAt: DateTime.now(),
      currentPlayers: remainingPlayers,
    );

    // Отправляем уведомление о завершении игры
    _gameEventsController.add(GameEndEvent(
      gameId: _currentGame!.id,
      reason: reason,
      survivors: survivors,
      isSuccess: isSuccess,
    ));

    _updateGameState();

    _logger.info('Игра завершена: $reason');
  }

  // Запуск таймера обсуждения
  void _startDiscussionTimer() {
    if (_currentGame == null) return;

    final discussionTime = _currentGame!.discussionTime;

    _discussionTimer = Timer(Duration(seconds: discussionTime), () {
      endDiscussionPhase();
    });

    _logger.info('Запущен таймер обсуждения: $discussionTime секунд');
  }

  // Запуск таймера голосования
  void _startVoteTimer() {
    if (_currentGame == null) return;

    final voteTime = _currentGame!.voteTime;

    _voteTimer = Timer(Duration(seconds: voteTime), () {
      endVotingPhase();
    });

    _logger.info('Запущен таймер голосования: $voteTime секунд');
  }

  // Добавление времени к текущей фазе
  void addTime(int seconds) {
    if (_isVotingPhase && _voteTimer != null) {
      // Отменяем текущий таймер голосования
      _voteTimer!.cancel();

      // Запускаем новый таймер с увеличенным временем
      _voteTimer = Timer(Duration(seconds: seconds), () {
        endVotingPhase();
      });

      _logger.info('Добавлено время к таймеру голосования: $seconds секунд');
    } else if (!_isVotingPhase && _discussionTimer != null) {
      // Отменяем текущий таймер обсуждения
      _discussionTimer!.cancel();

      // Запускаем новый таймер с увеличенным временем
      _discussionTimer = Timer(Duration(seconds: seconds), () {
        endDiscussionPhase();
      });

      _logger.info('Добавлено время к таймеру обсуждения: $seconds секунд');
    }
  }

  // Обновление состояния игры
  void _updateGameState() {
    if (_currentGame == null) return;

    // Обновляем количество активных игроков
    final activePlayers = _players.where((p) => !p.isEliminated).length;

    // Создаем обновленную игру
    final updatedGame = _currentGame!.copyWith(
      currentPlayers: activePlayers,
      players: _players,
    );

    // Сохраняем обновленную игру
    _currentGame = updatedGame;

    // Отправляем обновление через ConnectionManager
    _connectionManager.updateGameState(updatedGame);
  }

  // Отправка информации о раунде
  void sendRoundInfo() {
    if (_currentGame == null || _rounds.isEmpty) return;

    // Получаем текущий раунд
    final currentRound = _rounds[_currentRoundIndex];

    // Отправляем информацию о раунде
    _gameEventsController.add(RoundInfoEvent(
      round: currentRound,
      isVotingPhase: _isVotingPhase,
      votes: _votes[currentRound.id] ?? {},
    ));
  }

  // Утилизация ресурсов
  void dispose() {
    _discussionTimer?.cancel();
    _voteTimer?.cancel();
    _gameEventsController.close();
  }
}

// Игровые события
abstract class GameEvent {}

class PhaseChangeEvent extends GameEvent {
  final String roundId;
  final GamePhase phase;

  PhaseChangeEvent({
    required this.roundId,
    required this.phase,
  });
}

class VoteEvent extends GameEvent {
  final String roundId;
  final String voterId;
  final String targetId;

  VoteEvent({
    required this.roundId,
    required this.voterId,
    required this.targetId,
  });
}

class VoteResultEvent extends GameEvent {
  final String roundId;
  final Map<String, int> results;
  final List<RoundEliminationModel> eliminations;

  VoteResultEvent({
    required this.roundId,
    required this.results,
    required this.eliminations,
  });
}

class RoundStartEvent extends GameEvent {
  final String roundId;
  final int roundNumber;
  final int targetEliminations;

  RoundStartEvent({
    required this.roundId,
    required this.roundNumber,
    required this.targetEliminations,
  });
}

class RoundInfoEvent extends GameEvent {
  final GameRoundModel round;
  final bool isVotingPhase;
  final Map<String, String> votes;

  RoundInfoEvent({
    required this.round,
    required this.isVotingPhase,
    required this.votes,
  });
}

class GameEndEvent extends GameEvent {
  final String gameId;
  final GameEndReason reason;
  final List<PlayerModel> survivors;
  final bool isSuccess;

  GameEndEvent({
    required this.gameId,
    required this.reason,
    required this.survivors,
    required this.isSuccess,
  });
}

// Перечисления
enum GamePhase {
  discussion,
  voting,
}

enum GameEndReason {
  targetSurvivorsReached,
  maxRoundsReached,
  hostLeft,
  userCancelled,
}

