import 'package:flutter/material.dart';
import 'package:bunker/presentation/pages/splash_page.dart';
import 'package:bunker/presentation/pages/home_page.dart';
import 'package:bunker/presentation/pages/create_game_page.dart';
import 'package:bunker/presentation/pages/join_game_page.dart';
import 'package:bunker/presentation/pages/lobby_page.dart';
import 'package:bunker/presentation/pages/game_page.dart';
import 'package:bunker/presentation/pages/how_to_play_page.dart';
import 'package:bunker/presentation/pages/premium_page.dart';
import 'package:bunker/data/models/game_model.dart';
import 'package:bunker/presentation/blocs/game_creation/game_creation_bloc.dart';

class AppRouter {
  // Имена маршрутов
  static const String splash = '/';
  static const String home = '/home';
  static const String createGame = '/create_game';
  static const String joinGame = '/join_game';
  static const String lobby = '/lobby';
  static const String game = '/game';
  static const String howToPlay = '/how_to_play';
  static const String premium = '/premium';

  // Генератор маршрутов
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case createGame:
        return MaterialPageRoute(builder: (_) => const CreateGamePage());
      case joinGame:
        return MaterialPageRoute(builder: (_) => const JoinGamePage());
      case lobby:
      // Обработка аргументов для лобби
        if (settings.arguments is GameCreationState) {
          // Лобби для хоста
          final gameCreationState = settings.arguments as GameCreationState;
          return MaterialPageRoute(
            builder: (_) => LobbyPage(
              isHost: true,
              gameCreationState: gameCreationState,
              playerName: "Хост",
            ),
          );
        } else if (settings.arguments is Map) {
          // Лобби для клиента
          final args = settings.arguments as Map;
          return MaterialPageRoute(
            builder: (_) => LobbyPage(
              isHost: false,
              game: args['game'] as GameModel?,
              playerName: args['playerName'] as String,
            ),
          );
        } else {
          // Некорректные аргументы
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(
                child: Text('Ошибка: некорректные аргументы для лобби'),
              ),
            ),
          );
        }
      case game:
        return MaterialPageRoute(builder: (_) => const GamePage());
      case howToPlay:
        return MaterialPageRoute(builder: (_) => const HowToPlayPage());
      case premium:
        return MaterialPageRoute(builder: (_) => const PremiumPage());
      default:
      // Маршрут по умолчанию
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Маршрут не найден: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
