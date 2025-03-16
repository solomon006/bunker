import 'package:flutter/material.dart';
import 'package:bunker/data/models/player_card_model.dart';

class PlayerCharacteristicCard extends StatelessWidget {
  final PlayerCardModel card;
  final bool isOwnCard;
  final VoidCallback? onRevealPressed;

  const PlayerCharacteristicCard({
    Key? key,
    required this.card,
    required this.isOwnCard,
    this.onRevealPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Если это карта другого игрока и она не раскрыта, показываем заблокированную версию
    final isVisible = isOwnCard || card.isRevealed;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _getCardColor(card.type).withOpacity(isVisible ? 1.0 : 0.5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isOwnCard && !card.isRevealed ? onRevealPressed : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Иконка характеристики
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      _getCardIcon(card.type),
                      color: isVisible ? Colors.black87 : Colors.black38,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Название характеристики
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getCardTypeName(card.type),
                        style: TextStyle(
                          fontSize: 12,
                          color: isVisible ? Colors.black87 : Colors.black38,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isVisible ? card.title : '???',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isVisible ? Colors.black87 : Colors.black38,
                        ),
                      ),
                      if (isVisible && card.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          card.description!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Индикатор видимости
                if (isOwnCard)
                  Icon(
                    card.isRevealed ? Icons.visibility : Icons.visibility_off,
                    color: card.isRevealed ? Colors.black87 : Colors.black54,
                  ),

                // Кнопка для раскрытия карты
                if (isOwnCard && !card.isRevealed)
                  IconButton(
                    icon: const Icon(Icons.touch_app),
                    color: Colors.black87,
                    onPressed: onRevealPressed,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCardColor(CardType type) {
    switch (type) {
      case CardType.profession:
        return Colors.blue[100]!;
      case CardType.biological:
        return Colors.green[100]!;
      case CardType.health:
        return Colors.red[100]!;
      case CardType.hobby:
        return Colors.purple[100]!;
      case CardType.baggage:
        return Colors.orange[100]!;
      case CardType.specialCondition:
        return Colors.yellow[100]!;
      case CardType.phobia:
        return Colors.blue[200]!;
      case CardType.character:
        return Colors.grey[300]!;
    }
  }

  IconData _getCardIcon(CardType type) {
    switch (type) {
      case CardType.profession:
        return Icons.work;
      case CardType.biological:
        return Icons.person;
      case CardType.health:
        return Icons.favorite;
      case CardType.hobby:
        return Icons.music_note;
      case CardType.baggage:
        return Icons.inventory_2;
      case CardType.specialCondition:
        return Icons.star;
      case CardType.phobia:
        return Icons.bug_report;
      case CardType.character:
        return Icons.psychology;
    }
  }

  String _getCardTypeName(CardType type) {
    switch (type) {
      case CardType.profession:
        return 'Профессия';
      case CardType.biological:
        return 'Био. Характеристики';
      case CardType.health:
        return 'Состояние Здоровья';
      case CardType.hobby:
        return 'Хобби';
      case CardType.baggage:
        return 'Багаж';
      case CardType.specialCondition:
        return 'Особое Условие';
      case CardType.phobia:
        return 'Фобия';
      case CardType.character:
        return 'Характер';
    }
  }
}
