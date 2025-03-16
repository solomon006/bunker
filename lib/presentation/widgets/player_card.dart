import 'package:flutter/material.dart';
import 'package:bunker/data/models/player_model.dart';
import 'package:bunker/data/models/player_card_model.dart';
import 'package:bunker/presentation/widgets/post_apocalyptic_card.dart';

class PlayerCard extends StatelessWidget {
  final PlayerModel player;
  final bool isCurrentPlayer;
  final bool showVoteButton;
  final VoidCallback? onVote;

  const PlayerCard({
    Key? key,
    required this.player,
    this.isCurrentPlayer = false,
    this.showVoteButton = false,
    this.onVote,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PostApocalypticCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Заголовок карточки игрока
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _getHeaderColor(),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white70,
                  child: Text(
                    player.orderNumber.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getHeaderColor(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            player.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (isCurrentPlayer)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'ВЫ',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _getHeaderColor(),
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (player.isHost)
                        const Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Хост',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                if (showVoteButton && onVote != null)
                  ElevatedButton.icon(
                    onPressed: onVote,
                    icon: const Icon(Icons.how_to_vote),
                    label: const Text('Голосовать'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Состояние игрока
          if (player.isEliminated)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.red.withOpacity(0.2),
              child: const Center(
                child: Text(
                  'ИСКЛЮЧЕН',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // Характеристики игрока
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Профессия: ${_getProfessionText()}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Здесь будут отображаться все раскрытые характеристики
                ...player.cards
                    .where((card) => card.isRevealed || isCurrentPlayer)
                    .map(
                      (card) => _buildCharacteristicItem(card, isCurrentPlayer),
                    )
                    .toList(),

                // Индикаторы нераскрытых характеристик
                if (!isCurrentPlayer &&
                    player.cards.any((card) => !card.isRevealed))
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _buildHiddenCharacteristics(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacteristicItem(PlayerCardModel card, bool isOwn) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _getCardTypeIcon(card.type),
            size: 20,
            color:
                card.isRevealed || isOwn
                    ? _getCardTypeColor(card.type)
                    : Colors.grey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getCardTypeName(card.type) + ':',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  card.isRevealed || isOwn ? card.title : '???',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        card.isRevealed || isOwn
                            ? FontWeight.normal
                            : FontWeight.bold,
                    color:
                        card.isRevealed || isOwn ? Colors.black87 : Colors.grey,
                  ),
                ),
                if ((card.isRevealed || isOwn) && card.description != null)
                  Text(
                    card.description!,
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
          if (isOwn && !card.isRevealed)
            Tooltip(
              message: 'Скрыто от других игроков',
              child: Icon(
                Icons.visibility_off,
                size: 20,
                color: Colors.grey.shade400,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHiddenCharacteristics() {
    final hiddenCount = player.cards.where((card) => !card.isRevealed).length;

    return Row(
      children: [
        Icon(Icons.lock, size: 16, color: Colors.grey.shade400),
        const SizedBox(width: 8),
        Text(
          'Скрыто характеристик: $hiddenCount',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  String _getProfessionText() {
    // Ищем карточку профессии
    final professionCard = player.cards.firstWhere(
      (card) => card.type == CardType.profession,
      orElse:
          () => PlayerCardModel(
            id: '',
            type: CardType.profession,
            title: 'Неизвестно',
            isRevealed: false,
            utilityIndex: 0,
          ),
    );

    // Возвращаем название профессии или "???" если она скрыта
    return (professionCard.isRevealed || isCurrentPlayer)
        ? professionCard.title
        : '???';
  }

  Color _getHeaderColor() {
    if (player.isEliminated) {
      return Colors.grey;
    } else if (player.isHost) {
      return Colors.amber.shade800;
    } else if (isCurrentPlayer) {
      return Colors.blue.shade700;
    } else {
      return Colors.purple;
    }
  }

  IconData _getCardTypeIcon(CardType type) {
    switch (type) {
      case CardType.profession:
        return Icons.work;
      case CardType.biological:
        return Icons.person;
      case CardType.health:
        return Icons.favorite;
      case CardType.hobby:
        return Icons.sports_esports;
      case CardType.baggage:
        return Icons.backpack;
      case CardType.specialCondition:
        return Icons.star;
      case CardType.phobia:
        return Icons.psychology_alt;
      case CardType.character:
        return Icons.face;
      default:
        return Icons.help_outline;
    }
  }

  Color _getCardTypeColor(CardType type) {
    switch (type) {
      case CardType.profession:
        return Colors.blue;
      case CardType.biological:
        return Colors.green;
      case CardType.health:
        return Colors.red;
      case CardType.hobby:
        return Colors.purple;
      case CardType.baggage:
        return Colors.orange;
      case CardType.specialCondition:
        return Colors.amber;
      case CardType.phobia:
        return Colors.teal;
      case CardType.character:
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  String _getCardTypeName(CardType type) {
    switch (type) {
      case CardType.profession:
        return 'Профессия';
      case CardType.biological:
        return 'Биологические характеристики';
      case CardType.health:
        return 'Здоровье';
      case CardType.hobby:
        return 'Хобби';
      case CardType.baggage:
        return 'Багаж';
      case CardType.specialCondition:
        return 'Особое условие';
      case CardType.phobia:
        return 'Фобия';
      case CardType.character:
        return 'Характер';
      default:
        return 'Неизвестный тип';
    }
  }
}
