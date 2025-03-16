import 'dart:math';
import 'package:bunker/data/models/player_model.dart';
import 'package:bunker/data/models/player_card_model.dart';
import 'package:bunker/data/models/catastrophe_model.dart';
import 'package:bunker/data/models/shelter_model.dart';
import 'package:bunker/data/models/generated_ending_model.dart';
import 'package:bunker/core/utils/logger.dart';
import 'package:uuid/uuid.dart';

/// Утилита для генерации игрового контента
class GameContentGenerator {
  final Logger _logger = Logger('GameContentGenerator');
  final Random _random = Random();
  final Uuid _uuid = const Uuid();

  // Singleton
  static final GameContentGenerator _instance = GameContentGenerator._internal();
  factory GameContentGenerator() => _instance;
  GameContentGenerator._internal();

  /// Генерация полного набора карточек для игрока
  Future<List<PlayerCardModel>> generatePlayerCards(List<Map<String, dynamic>> cardsByType) async {
    try {
      final cards = <PlayerCardModel>[];

      // Добавляем по одной карточке каждого основного типа
      cards.add(_generateCardOfType(CardType.profession, cardsByType));
      cards.add(_generateCardOfType(CardType.biological, cardsByType));
      cards.add(_generateCardOfType(CardType.health, cardsByType));
      cards.add(_generateCardOfType(CardType.hobby, cardsByType));
      cards.add(_generateCardOfType(CardType.baggage, cardsByType));
      cards.add(_generateCardOfType(CardType.phobia, cardsByType));

      // Добавляем с некоторой вероятностью карточку особого условия
      if (_random.nextDouble() < 0.5) {
        cards.add(_generateCardOfType(CardType.specialCondition, cardsByType));
      }

      // Добавляем с некоторой вероятностью карточку характера
      if (_random.nextDouble() < 0.3) {
        cards.add(_generateCardOfType(CardType.character, cardsByType));
      }

      return cards;
    } catch (e) {
      _logger.error("Ошибка при генерации карточек: $e");
      // В случае ошибки возвращаем минимальный набор карточек-заглушек
      return [
        PlayerCardModel(
          id: _uuid.v4(),
          type: CardType.profession,
          title: "Случайная профессия",
          description: "Сгенерировано автоматически",
          isRevealed: false,
          utilityIndex: 5,
        ),
        PlayerCardModel(
          id: _uuid.v4(),
          type: CardType.biological,
          title: "Средний возраст",
          description: "Сгенерировано автоматически",
          isRevealed: false,
          utilityIndex: 5,
        ),
        PlayerCardModel(
          id: _uuid.v4(),
          type: CardType.health,
          title: "Нормальное здоровье",
          description: "Сгенерировано автоматически",
          isRevealed: false,
          utilityIndex: 5,
        ),
      ];
    }
  }

  /// Генерация карточки определенного типа
  PlayerCardModel _generateCardOfType(CardType type, List<Map<String, dynamic>> cardsByType) {
    // Находим все карточки нужного типа
    final typeCards = cardsByType.where((card) => card['type'] == type.toString()).toList();

    // Если карточки данного типа не найдены, возвращаем заглушку
    if (typeCards.isEmpty) {
      return PlayerCardModel(
        id: _uuid.v4(),
        type: type,
        title: "Неизвестно",
        description: "Карточка не найдена",
        isRevealed: false,
        utilityIndex: 5,
      );
    }

    // Выбираем случайную карточку
    final cardData = typeCards[_random.nextInt(typeCards.length)];

    return PlayerCardModel(
      id: _uuid.v4(),
      type: type,
      title: cardData['title'],
      description: cardData['description'],
      isRevealed: false,
      utilityIndex: cardData['utility_index'] ?? 5,
    );
  }

  /// Генерация описания концовки игры
  Future<GeneratedEndingModel> generateEnding(
      String gameId,
      List<PlayerModel> survivors,
      CatastropheModel catastrophe,
      ShelterModel shelter,
      bool isSuccess,
      ) async {
    try {
      String title;
      String storyText;

      if (isSuccess) {
        title = _generateSuccessTitle();
        storyText = _generateSuccessStory(survivors, catastrophe, shelter);
      } else {
        title = _generateFailureTitle();
        storyText = _generateFailureStory(survivors, catastrophe, shelter);
      }

      return GeneratedEndingModel(
        id: _uuid.v4(),
        gameId: gameId,
        title: title,
        storyText: storyText,
        isSuccess: isSuccess,
        generatedAt: DateTime.now(),
        acquisitionMethod: 'local_generation',
        generatorVersion: 1,
      );
    } catch (e) {
      _logger.error("Ошибка при генерации концовки: $e");

      // В случае ошибки возвращаем концовку-заглушку
      return GeneratedEndingModel(
        id: _uuid.v4(),
        gameId: gameId,
        title: isSuccess ? "Выжившие справились!" : "Последний свет погас...",
        storyText: isSuccess
            ? "Группе удалось пережить катастрофу и начать новую жизнь."
            : "К сожалению, группа выживших не смогла противостоять испытаниям судьбы.",
        isSuccess: isSuccess,
        generatedAt: DateTime.now(),
        acquisitionMethod: 'fallback',
        generatorVersion: 1,
      );
    }
  }

  /// Генерация заголовка для успешной концовки
  String _generateSuccessTitle() {
    final titles = [
      "Новое начало",
      "Выжившие победили",
      "На руинах старого мира",
      "Надежда человечества",
      "Пережившие апокалипсис",
      "Сквозь тьму - к свету",
      "Возрождение вида",
      "Горстка выживших",
      "Последние из людей",
      "Рассвет новой эры",
    ];

    return titles[_random.nextInt(titles.length)];
  }

  /// Генерация заголовка для неудачной концовки
  String _generateFailureTitle() {
    final titles = [
      "Последний свет погас",
      "Конец пути",
      "Тщетные попытки",
      "И никого не осталось",
      "Крах последней надежды",
      "Забытые историей",
      "Угасание человечества",
      "Последний вздох",
      "Бесславный финал",
      "Хроники исчезновения",
    ];

    return titles[_random.nextInt(titles.length)];
  }

  /// Генерация описания для успешной концовки
  String _generateSuccessStory(
      List<PlayerModel> survivors,
      CatastropheModel catastrophe,
      ShelterModel shelter,
      ) {
    final professions = survivors
        .map((s) {
      final professionCard = s.cards.firstWhere(
            (c) => c.type == CardType.profession,
        orElse: () => PlayerCardModel(
          id: '',
          type: CardType.profession,
          title: 'Неизвестная профессия',
          isRevealed: false,
          utilityIndex: 0,
        ),
      );
      return professionCard.title;
    })
        .join(', ');

    final introLines = [
      "После долгих месяцев в бункере, выжившие сумели создать функционирующее сообщество.",
      "Несмотря на все трудности, группе удалось пережить катастрофу и заложить основы нового общества.",
      "Бункер стал надежным убежищем от ужасов внешнего мира, давая возможность группе выжить.",
      "Благодаря правильному выбору выживших, человечество получило шанс на новое начало.",
    ];

    final middleLines = [
      "Ключевую роль сыграли специалисты: $professions.",
      "Бункер площадью ${shelter.area} м² оказался достаточно просторным для комфортного проживания.",
      "Запасов хватило на все ${shelter.duration} года изоляции от внешнего мира.",
      "Каждый из выживших внес свой вклад в общее дело, используя свои навыки и знания.",
    ];

    final outroLines = [
      "Когда пришло время покинуть бункер, мир снаружи начал восстанавливаться.",
      "Выжившие смогли заложить основу для возрождения цивилизации.",
      "Человечество выстояло перед лицом ${catastrophe.title.toLowerCase()}, доказав свою выносливость.",
      "Эта группа людей стала надеждой на возрождение человеческой цивилизации.",
    ];

    final intro = introLines[_random.nextInt(introLines.length)];
    final middle = middleLines[_random.nextInt(middleLines.length)];
    final outro = outroLines[_random.nextInt(outroLines.length)];

    return "$intro $middle $outro";
  }

  /// Генерация описания для неудачной концовки
  String _generateFailureStory(
      List<PlayerModel> survivors,
      CatastropheModel catastrophe,
      ShelterModel shelter,
      ) {
    final introLines = [
      "К сожалению, выбранная группа оказалась неспособной к выживанию в условиях бункера.",
      "Надежды на выживание рухнули практически сразу после того, как двери бункера закрылись.",
      "Конфликты и непримиримые разногласия разрушили последнюю надежду человечества.",
      "Выжившие не смогли адаптироваться к новым условиям жизни после катастрофы.",
    ];

    final middleLines = [
      "Недостаток необходимых навыков и знаний привел к быстрому истощению ресурсов.",
      "Бункер площадью всего ${shelter.area} м² оказался слишком тесным, что породило напряженность.",
      "Запасов должно было хватить на ${shelter.duration} года, но из-за неправильного использования они закончились раньше.",
      "Психологическое давление оказалось слишком сильным для большинства членов группы.",
    ];

    final outroLines = [
      "В итоге, бункер стал не спасением, а могилой для последних представителей человечества.",
      "Последний выживший умер в одиночестве, и надежда на возрождение угасла навсегда.",
      "${catastrophe.title} стала финальной точкой в истории человеческого вида.",
      "Так закончилась история человечества - не с грохотом, а с тихим вздохом.",
    ];

    final intro = introLines[_random.nextInt(introLines.length)];
    final middle = middleLines[_random.nextInt(middleLines.length)];
    final outro = outroLines[_random.nextInt(outroLines.length)];

    return "$intro $middle $outro";
  }
}
