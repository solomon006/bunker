import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bunker/core/constants/asset_paths.dart';
import 'package:bunker/presentation/blocs/game/game_bloc.dart';
import 'package:bunker/presentation/widgets/player_card.dart';
import 'package:bunker/presentation/widgets/game_timer.dart';
import 'package:bunker/presentation/widgets/player_characteristic_card.dart';
import 'package:bunker/presentation/widgets/catastrophe_info_panel.dart';
import 'package:bunker/presentation/widgets/post_apocalyptic_button.dart';
import 'package:bunker/config/app_router.dart';
import 'package:bunker/data/models/player_card_model.dart';

class GamePage extends StatelessWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameBloc()..add(InitializeGame()),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AssetPaths.backgroundTexture),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(child: _GameContent()),
        ),
      ),
    );
  }
}

class _GameContent extends StatefulWidget {
  @override
  _GameContentState createState() => _GameContentState();
}

class _GameContentState extends State<_GameContent> {
  bool _showCatastrophePanel = false;
  int _selectedPlayerIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameBlocState>(
      builder: (context, state) {
        if (state is GameLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is GameRunning) {
          return Stack(
            children: [
              // Основной контент игры
              Column(
                children: [
                  // Верхняя панель
                  _buildTopPanel(state),

                  // Основная часть - карточка персонажа
                  Expanded(
                    child:
                        _selectedPlayerIndex == 0
                            ? _buildOwnPlayerCard(state)
                            : _buildOtherPlayerCard(
                              state,
                              _selectedPlayerIndex - 1,
                            ),
                  ),

                  // Нижняя панель
                  _buildBottomPanel(state),
                ],
              ),

              // Панель с информацией о катастрофе и бункере
              if (_showCatastrophePanel)
                CatastropheInfoPanel(
                  catastrophe: state.game.catastrophe!,
                  shelter: state.game.shelter!,
                  onClose: () => setState(() => _showCatastrophePanel = false),
                ),
            ],
          );
        } else if (state is GameEnded) {
          return _buildGameEndScreen(state);
        } else {
          return const Center(child: Text('Ошибка загрузки игры'));
        }
      },
    );
  }

  Widget _buildTopPanel(GameRunning state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.brown.withOpacity(0.8),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          // Иконка для открытия панели катастрофы/бункера
          IconButton(
            icon: const Icon(Icons.warning_amber_rounded, color: Colors.red),
            onPressed: () => setState(() => _showCatastrophePanel = true),
          ),

          const Spacer(),

          // Таймер
          const GameTimer(minutes: 1, seconds: 0),

          const Spacer(),

          // Кнопки управления временем
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.timer, color: Colors.white),
                onPressed: () => context.read<GameBloc>().add(AddTime(10)),
              ),
              IconButton(
                icon: const Icon(Icons.home, color: Colors.white),
                onPressed: () => _showExitConfirmDialog(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOwnPlayerCard(GameRunning state) {
    final currentPlayer = state.currentPlayer;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Заголовок с профессией
          Row(
            children: [
              Text(
                'Игрок ${state.currentPlayerIndex + 1}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              const Spacer(),
            ],
          ),

          const SizedBox(height: 8),

          // Профессия
          Text(
            currentPlayer.cards
                .firstWhere(
                  (card) => card.type == CardType.profession,
                ) // Undefined name 'CardType'.
                .title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          // Характеристики игрока
          ...currentPlayer.cards.map((card) {
            return PlayerCharacteristicCard(
              card: card,
              isOwnCard: true,
              onRevealPressed:
                  () => context.read<GameBloc>().add(
                    RevealCharacteristic(card.id),
                  ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildOtherPlayerCard(GameRunning state, int playerIndex) {
    if (playerIndex >= state.game.players.length) {
      return const Center(child: Text('Игрок не найден'));
    }

    final player = state.game.players[playerIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Заголовок с именем игрока и кнопкой голосования
          Row(
            children: [
              Text(
                'Игрок ${playerIndex + 1}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              const Spacer(),
              // Кнопка голосования
              if (!player.isEliminated && state.votingEnabled)
                ElevatedButton(
                  onPressed:
                      () => context.read<GameBloc>().add(
                        VoteForPlayer(player.id),
                      ),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Выгнать'),
                ),
            ],
          ),

          const SizedBox(height: 8),

          // Профессия (если раскрыта)
          Text(
            player.cards
                    .firstWhere(
                      (card) =>
                          card.type ==
                          CardType.profession, // Undefined name 'CardType'.
                      orElse:
                          () => const PlayerCardModel(
                            // The name 'PlayerCardModel' isn't a class.
                            id: '',
                            type:
                                CardType
                                    .profession, // Undefined name 'CardType'.
                            title: 'Неизвестно',
                            isRevealed: false,
                            utilityIndex: 0,
                          ),
                    )
                    .isRevealed
                ? player.cards
                    .firstWhere((card) => card.type == CardType.profession)
                    .title // Undefined name 'CardType'.
                : '???',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          // Характеристики игрока
          ...player.cards.map((card) {
            return PlayerCharacteristicCard(card: card, isOwnCard: false);
          }).toList(),

          if (player.isEliminated)
            Container(
              margin: const EdgeInsets.only(top: 20),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cancel, color: Colors.red),
                  SizedBox(width: 8),
                  Text(
                    'ИСКЛЮЧЕН ИЗ ИГРЫ',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel(GameRunning state) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          state.game.players.length + 1, // +1 для собственной карточки
          (index) => _buildPlayerButton(state, index),
        ),
      ),
    );
  }

  Widget _buildPlayerButton(GameRunning state, int index) {
    final isSelected = _selectedPlayerIndex == index;
    final isEliminated =
        index > 0 && state.game.players[index - 1].isEliminated;

    return InkWell(
      onTap: () => setState(() => _selectedPlayerIndex = index),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Colors.blue
                  : (isEliminated ? Colors.red : Colors.grey),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            index == 0 ? 'Я' : index.toString(),
            style: TextStyle(
              color: Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  void _showExitConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Выйти из игры?'),
            content: const Text(
              'Вы уверены, что хотите покинуть игру? Ваш персонаж будет считаться исключенным.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ОТМЕНА'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, AppRouter.home);
                  context.read<GameBloc>().add(LeaveGame());
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('ВЫЙТИ'),
              ),
            ],
          ),
    );
  }

  Widget _buildGameEndScreen(GameEnded state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'ИГРА ОКОНЧЕНА',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text(
            state.endingTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              state.endingDescription,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 30),
          PostApocalypticButton(
            onPressed:
                () => Navigator.pushReplacementNamed(context, AppRouter.home),
            text: 'В ГЛАВНОЕ МЕНЮ',
            width: 240,
          ),
        ],
      ),
    );
  }
}
