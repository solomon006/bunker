import 'package:flutter/material.dart';
import 'package:bunker/data/models/game_round_model.dart';
import 'package:bunker/presentation/widgets/post_apocalyptic_card.dart';

class RoundInfoPanel extends StatelessWidget {
  final GameRoundModel round;
  final int totalPlayers;
  final int remainingPlayers;
  final int remainingTime;
  final VoidCallback? onClose;

  const RoundInfoPanel({
    Key? key,
    required this.round,
    required this.totalPlayers,
    required this.remainingPlayers,
    required this.remainingTime,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final minutes = remainingTime ~/ 60;
    final seconds = remainingTime % 60;

    return PostApocalypticCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'РАУНД ${round.roundNumber}',
                style: const TextStyle(
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

          // Информация о раунде
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem(
                  Icons.people,
                  'Всего игроков',
                  totalPlayers.toString(),
                ),
                _buildInfoItem(
                  Icons.person,
                  'Выживших',
                  remainingPlayers.toString(),
                ),
                _buildInfoItem(
                  Icons.person_remove,
                  'Нужно исключить',
                  round.targetEliminationCount.toString(),
                ),
              ],
            ),
          ),

          const Divider(),

          // Таймер
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.timer,
                  color: Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Оставшееся время: ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // Прогресс раунда
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Исключено игроков: ${round.eliminations.length}/${round.targetEliminationCount}',
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: round.targetEliminationCount > 0
                        ? round.eliminations.length / round.targetEliminationCount
                        : 0,
                    backgroundColor: Colors.grey.shade200,
                    color: Colors.red,
                    minHeight: 10,
                  ),
                ),
              ],
            ),
          ),

          if (round.isCompleted)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Раунд завершен',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  if (round.roundSummary != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        round.roundSummary!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green.shade800,
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

  Widget _buildInfoItem(IconData icon, String title, String value) {
    return Column(
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
