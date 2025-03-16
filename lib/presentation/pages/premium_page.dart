import 'package:flutter/material.dart';
import 'package:bunker/core/constants/asset_paths.dart';
import 'package:bunker/presentation/widgets/post_apocalyptic_card.dart';
import 'package:bunker/presentation/widgets/post_apocalyptic_button.dart';

class PremiumPage extends StatelessWidget {
  const PremiumPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ПРЕМИУМ'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AssetPaths.backgroundTexture),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.purple, Colors.blue, Colors.green, Colors.yellow, Colors.orange, Colors.red],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Text(
                      'УЛУЧШИ СВОЮ ИГРУ',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            blurRadius: 2,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Премиум преимущества
                PostApocalypticCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ПРЕИМУЩЕСТВА ПРЕМИУМ',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildPremiumFeature(
                        icon: Icons.extension,
                        title: 'Полный набор карточек',
                        description: 'Доступ ко всем 500+ карточкам характеристик, включая редкие и эксклюзивные.',
                      ),
                      const Divider(),
                      _buildPremiumFeature(
                        icon: Icons.remove_red_eye,
                        title: 'Без рекламы',
                        description: 'Никаких раздражающих баннеров и прерываний во время игры.',
                      ),
                      const Divider(),
                      _buildPremiumFeature(
                        icon: Icons.auto_awesome,
                        title: 'Уникальные катастрофы',
                        description: 'Эксклюзивные сценарии катастроф и особые бункеры для более разнообразных игр.',
                      ),
                      const Divider(),
                      _buildPremiumFeature(
                        icon: Icons.person_add,
                        title: 'Неограниченное число игроков',
                        description: 'Играйте с большим количеством друзей - до 18 человек одновременно.',
                      ),
                      const Divider(),
                      _buildPremiumFeature(
                        icon: Icons.api,
                        title: 'Генерация концовок с ИИ',
                        description: 'Уникальные истории завершения игры, созданные искусственным интеллектом.',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Планы подписки
                PostApocalypticCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ВЫБЕРИТЕ ПЛАН',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Месячная подписка
                      _buildSubscriptionPlan(
                        title: 'Месячная подписка',
                        price: '199 ₽',
                        description: 'Полный доступ на 30 дней',
                        color: Colors.blue.shade100,
                        accentColor: Colors.blue.shade700,
                        onTap: () => _showPurchaseDialog(context, 'месячную подписку', '199 ₽'),
                      ),

                      const SizedBox(height: 12),

                      // Годовая подписка
                      Stack(
                        children: [
                          _buildSubscriptionPlan(
                            title: 'Годовая подписка',
                            price: '999 ₽',
                            description: 'Полный доступ на 365 дней (экономия 58%)',
                            color: Colors.purple.shade100,
                            accentColor: Colors.purple.shade700,
                            onTap: () => _showPurchaseDialog(context, 'годовую подписку', '999 ₽'),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'ЛУЧШАЯ ЦЕНА',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Пожизненная подписка
                      _buildSubscriptionPlan(
                        title: 'Пожизненный доступ',
                        price: '2499 ₽',
                        description: 'Все функции навсегда, включая будущие обновления',
                        color: Colors.amber.shade100,
                        accentColor: Colors.amber.shade700,
                        onTap: () => _showPurchaseDialog(context, 'пожизненный доступ', '2499 ₽'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Дополнительные наборы
                PostApocalypticCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ТЕМАТИЧЕСКИЕ НАБОРЫ',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildContentPack(
                        title: 'Постядерная пустошь',
                        description: '75 новых карточек, 5 бункеров и 10 катастроф в стиле Fallout',
                        price: '299 ₽',
                        color: Colors.green.shade100,
                        onTap: () => _showPurchaseDialog(context, 'набор "Постядерная пустошь"', '299 ₽'),
                      ),

                      const SizedBox(height: 12),

                      _buildContentPack(
                        title: 'Пандемия',
                        description: '60 карточек, 4 бункера и 8 катастроф на тему вирусных эпидемий',
                        price: '249 ₽',
                        color: Colors.red.shade100,
                        onTap: () => _showPurchaseDialog(context, 'набор "Пандемия"', '249 ₽'),
                      ),

                      const SizedBox(height: 12),

                      _buildContentPack(
                        title: 'Экологическая катастрофа',
                        description: '70 карточек, 6 бункеров и 12 катастроф связанных с климатическими изменениями',
                        price: '279 ₽',
                        color: Colors.blue.shade100,
                        onTap: () => _showPurchaseDialog(context, 'набор "Экологическая катастрофа"', '279 ₽'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Кнопка восстановления покупок
                Center(
                  child: PostApocalypticButton(
                    onPressed: () {},
                    text: 'ВОССТАНОВИТЬ ПОКУПКИ',
                    icon: Icons.restore,
                    width: 280,
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumFeature({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.amber.shade800,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionPlan({
    required String title,
    required String price,
    required String description,
    required Color color,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: accentColor,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                  const Text(
                    'Купить',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
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

  Widget _buildContentPack({
    required String title,
    required String description,
    required String price,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade400,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  price,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPurchaseDialog(BuildContext context, String item, String price) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Подтверждение покупки'),
        content: Text('Вы уверены, что хотите приобрести $item за $price?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ОТМЕНА'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Здесь будет логика покупки
              _showSuccessDialog(context);
            },
            child: const Text('КУПИТЬ'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Успешная покупка'),
        content: const Text('Спасибо за покупку! Все преимущества премиум доступны.'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ОК'),
          ),
        ],
      ),
    );
  }
}
