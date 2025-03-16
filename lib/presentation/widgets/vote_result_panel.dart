import 'package:flutter/material.dart';
import 'package:bunker/data/models/player_model.dart';
import 'package:bunker/presentation/widgets/post_apocalyptic_card.dart';

class VoteResultPanel extends StatelessWidget {
  final Map<String, int> voteResults;
  final List<PlayerModel> players;
  final String? eliminatedPlayerId;
  final VoidCallback? onClose;

  const VoteResultPanel({
    Key? key,
    required this.voteResults,
    required this.players,
    this.eliminatedPlayerId,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Сортируем результаты по количеству голосов
    final sortedResults = players
        .where((player) => voteResults.containsKey(player.id))
        .toList()
      ..sort((a, b) => (voteResults[b.id] ?? 0).compareTo(voteResults[a.id] ?? 0));

    return PostApocalypticCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'РЕЗУЛЬТАТЫ ГОЛОСОВАНИЯ',
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
          const SizedBox(height: 16),

          // Результаты голосования
          ...sortedResults.map((player) => _buildVoteResultItem(player, voteResults[player.id] ?? 0)),

          const SizedBox(height: 16),

          // Итог голосования
          if (eliminatedPlayerId != null)
            _buildEliminationResult(),
        ],
      ),
    );
  }

  Widget _buildVoteResultItem(PlayerModel player, int votes) {
    final isEliminated = player.id == eliminatedPlayerId;
    final totalVotes = voteResults.values.fold(0, (sum, count) => sum + count);
    final percentage = totalVotes > 0 ? (votes / totalVotes * 100).round() : 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Аватар игрока
              CircleAvatar(
                backgroundColor: isEliminated ? Colors.red : Colors.grey.shade300,
                child: Text(
                  player.orderNumber.toString(),
                  style: TextStyle(
                    color: isEliminated ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Имя игрока
              Expanded(
                child: Text(
                  player.name,
                  style: TextStyle(
                    fontWeight: isEliminated ? FontWeight.bold : FontWeight.normal,
                    color: isEliminated ? Colors.red : Colors.black,
                  ),
                ),
              ),
              // Количество голосов
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isEliminated ? Colors.red.shade100 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '$votes голосов ($percentage%)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isEliminated ? Colors.red.shade900 : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Прогресс бар
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey.shade200,
              color: isEliminated ? Colors.red : Colors.blue,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEliminationResult() {
    final eliminatedPlayer = players.firstWhere(
          (player) => player.id == eliminatedPlayerId,
      orElse: () => players.first,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.red,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'Игрок ${eliminatedPlayer.name} исключен из бункера',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Получено ${voteResults[eliminatedPlayerId] ?? 0} голосов',
            style: TextStyle(
              fontSize: 14,
              color: Colors.red.shade900,
            ),
          ),
        ],
      ),
    );
  }
}
