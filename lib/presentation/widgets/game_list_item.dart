import 'package:flutter/material.dart';
import 'package:bunker/data/models/game_model.dart';
import 'package:bunker/presentation/widgets/post_apocalyptic_card.dart';

class GameListItem extends StatelessWidget {
  final GameModel game;
  final VoidCallback onTap;

  const GameListItem({
    Key? key,
    required this.game,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PostApocalypticCard(
      elevation: 3,
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      game.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Иконка пароля если игра защищена
                  if (game.hasPassword)
                    const Icon(
                      Icons.lock,
                      color: Colors.amber,
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Информация об игре
              Row(
                children: [
                  _buildInfoChip(
                    Icons.people,
                    '${game.currentPlayers}/${game.maxPlayers}',
                    Colors.blue.shade100,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    Icons.timer,
                    '${game.discussionTime ~/ 60} мин',
                    Colors.green.shade100,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    game.balanceLevel == 'competitive'
                        ? Icons.fitness_center
                        : Icons.sports_esports,
                    game.balanceLevel == 'competitive'
                        ? 'Спорт.'
                        : 'Обычн.',
                    game.balanceLevel == 'competitive'
                        ? Colors.red.shade100
                        : Colors.purple.shade100,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Индикатор состояния
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: game.state == GameState.lobby
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    game.state == GameState.lobby
                        ? 'В ожидании игроков'
                        : 'Игра уже начата',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade400,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.grey.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
