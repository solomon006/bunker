import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bunker/core/constants/asset_paths.dart';
import 'package:bunker/presentation/blocs/game_creation/game_creation_bloc.dart';
import 'package:bunker/presentation/widgets/post_apocalyptic_slider.dart';
import 'package:bunker/presentation/widgets/post_apocalyptic_switch.dart';
import 'package:bunker/presentation/widgets/post_apocalyptic_card.dart';
import 'package:bunker/presentation/widgets/post_apocalyptic_button.dart';
import 'package:bunker/config/app_router.dart';

class CreateGamePage extends StatelessWidget {
  const CreateGamePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameCreationBloc(),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AssetPaths.backgroundTexture),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: _CreateGameForm(),
          ),
        ),
      ),
    );
  }
}

class _CreateGameForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameCreationBloc, GameCreationState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок и кнопка назад
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'СОЗДАТЬ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Для симметрии
                ],
              ),

              const SizedBox(height: 20),

              // Количество игроков
              PostApocalypticCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '4',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Выберите количество игроков',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    PostApocalypticSlider(
                      value: state.playerCount.toDouble(),
                      min: 4,
                      max: 18,
                      onChanged: (value) => context.read<GameCreationBloc>().add(
                        PlayerCountChanged(value.round()),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Рекомендуем 10-14 игроков',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Расширенный набор карт
              PostApocalypticCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Расширенный набор карт',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        PostApocalypticSwitch(
                          value: state.useExtendedCardSet,
                          onChanged: (value) => context.read<GameCreationBloc>().add(
                            ExtendedCardSetToggled(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    IconButton(
                      icon: const Icon(Icons.help_outline),
                      onPressed: () => _showInfoDialog(context, 'Расширенный набор карт',
                          'Включает дополнительные профессии, биологические характеристики, хобби и особые условия.'
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Спортивный режим
              PostApocalypticCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Спортивный режим',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        PostApocalypticSwitch(
                          value: state.useSportsMode,
                          onChanged: (value) => context.read<GameCreationBloc>().add(
                            SportsModeToggled(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    IconButton(
                      icon: const Icon(Icons.help_outline),
                      onPressed: () => _showInfoDialog(context, 'Спортивный режим',
                          'Более сбалансированные характеристики, ограниченное время на обсуждение и сокращенное количество раундов.'
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Поле для имени игры
              PostApocalypticCard(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Название игры',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white70,
                  ),
                  initialValue: state.gameName,
                  onChanged: (value) => context.read<GameCreationBloc>().add(
                    GameNameChanged(value),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Пароль для игры
              PostApocalypticCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Пароль (необязательно)',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Пароль для игры',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white70,
                      ),
                      obscureText: true,
                      initialValue: state.password,
                      onChanged: (value) => context.read<GameCreationBloc>().add(
                        PasswordChanged(value),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Кнопка создания игры
              Center(
                child: PostApocalypticButton(
                  onPressed: () {
                    // Создание игры и переход в лобби
                    context.read<GameCreationBloc>().add(
                      CreateGameSubmitted(),
                    );

                    Navigator.pushReplacementNamed(
                      context,
                      AppRouter.lobby,
                      arguments: context.read<GameCreationBloc>().state,
                    );
                  },
                  text: 'ДАЛЕЕ',
                  width: 200,
                  height: 60,
                  accentColor: Colors.green[700]!,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ПОНЯТНО'),
          ),
        ],
      ),
    );
  }
}
