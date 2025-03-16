import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bunker/core/constants/asset_paths.dart';
import 'package:bunker/presentation/blocs/game_discovery/game_discovery_bloc.dart';
import 'package:bunker/presentation/widgets/post_apocalyptic_card.dart';
import 'package:bunker/presentation/widgets/post_apocalyptic_button.dart';
import 'package:bunker/presentation/widgets/game_list_item.dart';
import 'package:bunker/data/models/game_model.dart';
import 'package:bunker/config/app_router.dart';

class JoinGamePage extends StatelessWidget {
  const JoinGamePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameDiscoveryBloc()..add(StartGameDiscovery()),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AssetPaths.backgroundTexture),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: _JoinGameContent(),
          ),
        ),
      ),
    );
  }
}

class _JoinGameContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Заголовок и кнопка назад
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Text(
                  'ПОДКЛЮЧИТЬСЯ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => context.read<GameDiscoveryBloc>().add(RefreshGamesList()),
              ),
            ],
          ),
        ),

        // Список найденных игр
        Expanded(
          child: BlocBuilder<GameDiscoveryBloc, GameDiscoveryState>(
            builder: (context, state) {
              if (state is GameDiscoveryLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is GameDiscoverySuccess) {
                if (state.games.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'Игры не найдены',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        PostApocalypticButton(
                          onPressed: () => context.read<GameDiscoveryBloc>().add(RefreshGamesList()),
                          text: 'ОБНОВИТЬ',
                          icon: Icons.refresh,
                          width: 200,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.games.length,
                  itemBuilder: (context, index) {
                    final game = state.games[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GameListItem(
                        game: game,
                        onTap: () => _showJoinGameDialog(context, game),
                      ),
                    );
                  },
                );
              } else if (state is GameDiscoveryFailure) {
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
                        onPressed: () => context.read<GameDiscoveryBloc>().add(RefreshGamesList()),
                        text: 'ПОВТОРИТЬ',
                        icon: Icons.refresh,
                        width: 200,
                      ),
                    ],
                  ),
                );
              }

              return const Center(
                child: Text('Поиск игр...'),
              );
            },
          ),
        ),

        // Ручное подключение
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: PostApocalypticButton(
            onPressed: () => _showManualConnectionDialog(context),
            text: 'ВВЕСТИ IP ВРУЧНУЮ',
            icon: Icons.computer,
            width: double.infinity,
          ),
        ),
      ],
    );
  }

  void _showJoinGameDialog(BuildContext context, GameModel game) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Подключиться к "${game.name}"'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Ваше имя',
                border: OutlineInputBorder(),
              ),
            ),
            if (game.hasPassword) ...[
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Пароль',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ОТМЕНА'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Введите ваше имя')),
                );
                return;
              }

              Navigator.pop(context);

              // Переход в лобби
              context.read<GameDiscoveryBloc>().add(
                JoinGameRequested(
                  game: game,
                  playerName: nameController.text,
                  password: passwordController.text,
                ),
              );

              Navigator.pushReplacementNamed(
                context,
                AppRouter.lobby,
                arguments: {
                  'game': game,
                  'playerName': nameController.text,
                },
              );
            },
            child: const Text('ПОДКЛЮЧИТЬСЯ'),
          ),
        ],
      ),
    );
  }

  void _showManualConnectionDialog(BuildContext context) {
    final TextEditingController ipController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ручное подключение'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ipController,
              decoration: const InputDecoration(
                labelText: 'IP-адрес хоста',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Ваше имя',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Пароль (если требуется)',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ОТМЕНА'),
          ),
          ElevatedButton(
            onPressed: () {
              if (ipController.text.trim().isEmpty || nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Заполните все обязательные поля')),
                );
                return;
              }

              Navigator.pop(context);

              // Подключение по IP
              context.read<GameDiscoveryBloc>().add(
                ConnectToGameDirectly(
                  ipAddress: ipController.text,
                  playerName: nameController.text,
                  password: passwordController.text,
                ),
              );
            },
            child: const Text('ПОДКЛЮЧИТЬСЯ'),
          ),
        ],
      ),
    );
  }
}
