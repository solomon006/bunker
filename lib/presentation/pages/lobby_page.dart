import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bunker/core/constants/asset_paths.dart';
import 'package:bunker/data/models/game_model.dart';
import 'package:bunker/presentation/blocs/lobby/lobby_bloc.dart';
import 'package:bunker/presentation/blocs/game_creation/game_creation_bloc.dart';
import 'package:bunker/presentation/widgets/post_apocalyptic_card.dart';
import 'package:bunker/presentation/widgets/post_apocalyptic_button.dart';
import 'package:bunker/config/app_router.dart';

class LobbyPage extends StatelessWidget {
  final bool isHost;
  final GameModel? game;
  final GameCreationState? gameCreationState;
  final String playerName;

  const LobbyPage({
    Key? key,
    required this.isHost,
    this.game,
    this.gameCreationState,
    required this.playerName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              LobbyBloc()..add(
                InitLobby(game: game, isHost: isHost, playerName: playerName),
              ),
      child: BlocListener<LobbyBloc, LobbyState>(
        listener: (context, state) {
          if (state is GameStarting) {
            Navigator.pushReplacementNamed(context, AppRouter.game);
          } else if (state is LobbyLeft) {
            Navigator.pushReplacementNamed(context, AppRouter.home);
          }
        },
        child: BlocBuilder<LobbyBloc, LobbyState>(
          builder: (context, state) {
            return Scaffold(
              body: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AssetPaths.backgroundTexture),
                    fit: BoxFit.cover,
                  ),
                ),
                child: SafeArea(child: _buildContent(context, state)),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, LobbyState state) {
    if (state is LobbyLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is LobbyReady) {
      return Column(
        children: [
          // Заголовок и кнопка назад
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('Выйти из лобби?'),
                            content: const Text(
                              'Вы уверены, что хотите покинуть лобби? Ваше место может занять другой игрок.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('ОТМЕНА'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  context.read<LobbyBloc>().add(LeaveLobby());
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('ВЫЙТИ'),
                              ),
                            ],
                          ),
                    );
                  },
                ),
                Expanded(
                  child: Text(
                    state.game.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 48), // Для симметрии
              ],
            ),
          ),

          // Информация об игре
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: PostApocalypticCard(
              child: Column(
                children: [
                  const Text(
                    'ИНФОРМАЦИЯ ОБ ИГРЕ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildInfoItem(
                        Icons.people,
                        'Игроки',
                        '${state.game.currentPlayers}/${state.game.maxPlayers}',
                      ),
                      _buildInfoItem(
                        Icons.timer,
                        'Время обсуждения',
                        '${state.game.discussionTime ~/ 60} мин',
                      ),
                      _buildInfoItem(
                        Icons.how_to_vote,
                        'Тип голосования',
                        _getVoteTypeName(state.game.voteType),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (state.game.hasPassword)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.lock, size: 16, color: Colors.orange),
                        SizedBox(width: 4),
                        Text(
                          'Игра защищена паролем',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Список игроков
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: PostApocalypticCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ИГРОКИ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: state.game.players.length,
                        itemBuilder: (context, index) {
                          final player = state.game.players[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  player.isHost
                                      ? Colors.amber
                                      : (player.isSelected
                                          ? Colors.green
                                          : Colors.grey),
                              child: Icon(
                                player.isHost
                                    ? Icons.star
                                    : (player.isSelected
                                        ? Icons.check
                                        : Icons.person),
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              player.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              player.isHost
                                  ? 'Хост'
                                  : (player.isSelected ? 'Готов' : 'Не готов'),
                            ),
                            trailing:
                                player.id == state.currentPlayer.id
                                    ? const Text(
                                      'ВЫ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    )
                                    : (state.isHost && !player.isHost
                                        ? IconButton(
                                          icon: const Icon(
                                            Icons.remove_circle,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            _showKickPlayerDialog(
                                              context,
                                              player.name,
                                              () {
                                                context.read<LobbyBloc>().add(
                                                  KickPlayer(player.id),
                                                );
                                              },
                                            );
                                          },
                                        )
                                        : null),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Кнопки управления
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: PostApocalypticButton(
                    onPressed: () {
                      context.read<LobbyBloc>().add(ToggleReady());
                    },
                    text: state.isReady ? 'НЕ ГОТОВ' : 'ГОТОВ',
                    icon: state.isReady ? Icons.cancel : Icons.check_circle,
                    accentColor: state.isReady ? Colors.red : Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: PostApocalypticButton(
                    onPressed:
                        state.isHost &&
                                _canStartGame(
                                  state.game,
                                ) // The argument type 'void Function()?' can't be assigned to the parameter type 'VoidCallback'.
                            ? () {
                              context.read<LobbyBloc>().add(StartGame());
                            }
                            : null,
                    text: 'НАЧАТЬ ИГРУ',
                    icon: Icons.play_arrow,
                    accentColor:
                        state.isHost && _canStartGame(state.game)
                            ? Colors.blue
                            : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else if (state is LobbyError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Ошибка: ${state.error}',
              style: const TextStyle(fontSize: 18, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PostApocalypticButton(
              onPressed: () {
                context.read<LobbyBloc>().add(LeaveLobby());
              },
              text: 'ВЕРНУТЬСЯ',
              icon: Icons.home,
              width: 200,
            ),
          ],
        ),
      );
    }

    return const Center(child: Text('Инициализация лобби...'));
  }

  Widget _buildInfoItem(IconData icon, String title, String value) {
    return Column(
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String _getVoteTypeName(VoteType type) {
    switch (type) {
      case VoteType.open:
        return 'Открытое';
      case VoteType.semiOpen:
        return 'Полуоткрытое';
      case VoteType.closed:
        return 'Закрытое';
      default:
        return 'Неизвестно';
    }
  }

  bool _canStartGame(GameModel game) {
    // Проверяем, можно ли начать игру
    if (game.currentPlayers < 4) return false; // Минимум 4 игрока
    if (game.currentPlayers < 2)
      return false; // Для тестирования можно уменьшить

    // Проверяем, что все игроки готовы (кроме хоста)
    final allPlayersReady = game.players
        .where((p) => !p.isHost)
        .every((p) => p.isSelected);

    return allPlayersReady;
  }

  void _showKickPlayerDialog(
    BuildContext context,
    String playerName,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Исключить игрока'),
            content: Text(
              'Вы уверены, что хотите исключить игрока "$playerName" из лобби?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ОТМЕНА'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onConfirm();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('ИСКЛЮЧИТЬ'),
              ),
            ],
          ),
    );
  }
}
