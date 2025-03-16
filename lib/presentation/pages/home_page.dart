import 'package:flutter/material.dart';
import 'package:bunker/core/constants/asset_paths.dart';
import 'package:bunker/presentation/widgets/post_apocalyptic_button.dart';
import 'package:bunker/config/app_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AssetPaths.backgroundTexture),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Лого игры
                Container(
                  width: 200,
                  height: 200,
                  margin: const EdgeInsets.only(bottom: 40),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(AssetPaths.gameLogo),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                // Кнопка подключения
                PostApocalypticButton(
                  onPressed: () => Navigator.pushNamed(context, AppRouter.joinGame),
                  text: 'ПОДКЛЮЧИТЬСЯ',
                  icon: Icons.wifi,
                  width: 280,
                  height: 60,
                  accentColor: Colors.blue[700]!,
                ),

                const SizedBox(height: 20),

                // Кнопка "Как играть"
                PostApocalypticButton(
                  onPressed: () => Navigator.pushNamed(context, AppRouter.howToPlay),
                  text: 'КАК ИГРАТЬ',
                  icon: Icons.help_outline,
                  width: 280,
                  height: 60,
                  accentColor: Colors.green[700]!,
                ),

                const SizedBox(height: 20),

                // Кнопка создания игры
                PostApocalypticButton(
                  onPressed: () => Navigator.pushNamed(context, AppRouter.createGame),
                  text: 'СОЗДАТЬ',
                  icon: Icons.add,
                  width: 280,
                  height: 60,
                  accentColor: Colors.deepPurple[700]!,
                ),

                const SizedBox(height: 20),

                // Кнопка премиум
                PostApocalypticButton(
                  onPressed: () => Navigator.pushNamed(context, AppRouter.premium),
                  text: 'ПРЕМИУМ',
                  icon: Icons.star,
                  width: 280,
                  height: 60,
                  accentColor: Colors.amber[800]!,
                  gradient: const LinearGradient(
                    colors: [Colors.purple, Colors.blue, Colors.green, Colors.yellow, Colors.orange, Colors.red],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),

                const Spacer(),

                // Кнопка заказа игры
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.shopping_cart, size: 18),
                    label: const Text('Заказать игру'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.brown[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
