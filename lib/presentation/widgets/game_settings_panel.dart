import 'package:flutter/material.dart';
import 'package:bunker/data/models/game_model.dart';
import 'package:bunker/presentation/widgets/post_apocalyptic_card.dart';
import 'package:bunker/presentation/widgets/post_apocalyptic_slider.dart';
import 'package:bunker/presentation/widgets/post_apocalyptic_switch.dart';

class GameSettingsPanel extends StatelessWidget {
  final GameModel game;
  final bool isHost;
  final ValueChanged<int>? onDiscussionTimeChanged;
  final ValueChanged<int>? onVoteTimeChanged;
  final ValueChanged<VoteType>? onVoteTypeChanged;
  final VoidCallback? onClose;

  const GameSettingsPanel({
    Key? key,
    required this.game,
    required this.isHost,
    this.onDiscussionTimeChanged,
    this.onVoteTimeChanged,
    this.onVoteTypeChanged,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PostApocalypticCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'НАСТРОЙКИ ИГРЫ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (onClose != null)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                ),
            ],
          ),
          const Divider(),

          // Настройки, доступные для изменения только хосту
          AbsorbPointer(
            absorbing: !isHost,
            child: Opacity(
              opacity: isHost ? 1.0 : 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Время обсуждения
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Время обсуждения:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: PostApocalypticSlider(
                                value: game.discussionTime / 60,
                                min: 1,
                                max: 10,
                                divisions: 9,
                                label: '${(game.discussionTime / 60).round()} мин',
                                onChanged: (value) {
                                  if (onDiscussionTimeChanged != null) {
                                    onDiscussionTimeChanged!((value * 60).round());
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 60,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade400),
                              ),
                              child: Text(
                                '${(game.discussionTime / 60).round()} мин',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Время голосования
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Время голосования:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: PostApocalypticSlider(
                                value: game.voteTime.toDouble(),
                                min: 10,
                                max: 120,
                                divisions: 11,
                                label: '${game.voteTime} сек',
                                onChanged: (value) {
                                  if (onVoteTimeChanged != null) {
                                    onVoteTimeChanged!(value.round());
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 60,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade400),
                              ),
                              child: Text(
                                '${game.voteTime} с',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Тип голосования
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Тип голосования:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildVoteTypeOption(
                              context,
                              VoteType.open,
                              'Открытое',
                              Icons.visibility,
                            ),
                            const SizedBox(width: 8),
                            _buildVoteTypeOption(
                              context,
                              VoteType.semiOpen,
                              'Полуоткрытое',
                              Icons.visibility_outlined,
                            ),
                            const SizedBox(width: 8),
                            _buildVoteTypeOption(
                              context,
                              VoteType.closed,
                              'Закрытое',
                              Icons.visibility_off,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Divider(),

          // Базовые настройки (только для отображения)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Информация об игре:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildInfoItem(
                  'Максимум игроков:',
                  game.maxPlayers.toString(),
                ),
                _buildInfoItem(
                  'Режим игры:',
                  game.balanceLevel == 'competitive' ? 'Спортивный' : 'Обычный',
                ),
                _buildInfoItem(
                  'Пакет контента:',
                  game.packId > 1 ? 'Расширенный' : 'Базовый',
                ),
                _buildInfoItem(
                  'Сложность:',
                  _getDifficultyText(game.difficultyLevel),
                ),
                _buildInfoItem(
                  'Количество раундов:',
                  game.totalRounds.toString(),
                ),
              ],
            ),
          ),

          // Примечание для не-хостов
          if (!isHost)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info,
                    color: Colors.blue,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Только хост может изменять настройки игры',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVoteTypeOption(
      BuildContext context,
      VoteType type,
      String label,
      IconData icon,
      ) {
    final isSelected = game.voteType == type;

    return Expanded(
      child: InkWell(
        onTap: () {
          if (onVoteTypeChanged != null) {
            onVoteTypeChanged!(type);
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.shade100 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey.shade400,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.blue : Colors.grey.shade700,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.blue : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getDifficultyText(int level) {
    switch (level) {
      case 1:
        return 'Легкая';
      case 2:
        return 'Средняя';
      case 3:
        return 'Высокая';
      default:
        return 'Неизвестно';
    }
  }
}
