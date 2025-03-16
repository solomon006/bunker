import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:bunker/data/models/catastrophe_model.dart';
import 'package:bunker/data/models/shelter_model.dart';
import 'package:bunker/data/models/player_card_model.dart';
import 'package:bunker/core/constants/asset_paths.dart';
import 'package:bunker/core/utils/logger.dart';
import 'package:uuid/uuid.dart';

class ContentRepository {
  final _logger = Logger('ContentRepository');
  final _random = Random();

  // Кэш для контента
  List<CatastropheModel>? _catastrophes;
  List<ShelterModel>? _shelters;
  Map<CardType, List<Map<String, dynamic>>>? _cardsByType;

  // Загрузка катастроф из JSON-файла
  Future<List<CatastropheModel>> _loadCatastrophes() async {
    if (_catastrophes != null) return _catastrophes!;

    try {
      final jsonString = await rootBundle.loadString(AssetPaths.catastrophes);
      final jsonData = json.decode(jsonString) as List;

      _catastrophes = jsonData.map((item) {
        final map = item as Map<String, dynamic>;
        return CatastropheModel(
          id: map['id'],
          title: map['title'],
          description: map['description'],
          rating: map['rating'] ?? 0,
        );
      }).toList();

      return _catastrophes!;
    } catch (e) {
      _logger.error("Ошибка при загрузке катастроф: $e");

      // Возвращаем заглушки в случае ошибки
      return [
        CatastropheModel(
          id: 'default-1',
          title: 'Искусственный интеллект Василиск Роко',
          description: 'Искусственный интеллект Василиск Роко, разработанный одним программистом из NTU, оказался агрессивно настроен против людей. Он намерен наказать людей, которые не помогали его созданию.',
          rating: 5,
        ),
        CatastropheModel(
          id: 'default-2',
          title: 'Ядерная война',
          description: 'Неожиданно начавшаяся ядерная война между крупнейшими державами привела к массовому запуску ракет с ядерными боеголовками. Большая часть населения погибла в первые часы конфликта.',
          rating: 5,
        ),
      ];
    }
  }

  // Загрузка бункеров из JSON-файла
  Future<List<ShelterModel>> _loadShelters() async {
    if (_shelters != null) return _shelters!;

    try {
      final jsonString = await rootBundle.loadString(AssetPaths.shelters);
      final jsonData = json.decode(jsonString) as List;

      _shelters = jsonData.map((item) {
        final map = item as Map<String, dynamic>;
        return ShelterModel(
          id: map['id'],
          name: map['name'],
          area: map['area'] ?? 0,
          duration: map['duration'] ?? 0,
          capacity: map['capacity'] ?? 0,
          description: map['description'] ?? '',
        );
      }).toList();

      return _shelters!;
    } catch (e) {
      _logger.error("Ошибка при загрузке бункеров: $e");

      // Возвращаем заглушки в случае ошибки
      return [
        ShelterModel(
          id: 'default-1',
          name: 'ГО-42',
          area: 150,
          duration: 3,
          capacity: 10,
          description: 'Грязный бункер, никогда не использовавшийся по назначению. Известно, что в бункере водятся тараканы.',
        ),
        ShelterModel(
          id: 'default-2',
          name: 'Подземная база',
          area: 200,
          duration: 2,
          capacity: 15,
          description: 'Бывшая секретная военная база, наспех переоборудованная под укрытие. Часть систем жизнеобеспечения работает нестабильно.',
        ),
      ];
    }
  }

  // Загрузка карточек определенного типа
  Future<List<Map<String, dynamic>>> _loadCardsByType(CardType type) async {
    if (_cardsByType == null) {
      _cardsByType = {};
    }

    if (_cardsByType!.containsKey(type)) {
      return _cardsByType![type]!;
    }

    String assetPath;

    switch (type) {
      case CardType.profession:
        assetPath = AssetPaths.professionCards;
        break;
      case CardType.biological:
        assetPath = AssetPaths.biologicalCards;
        break;
      case CardType.health:
        assetPath = AssetPaths.healthCards;
        break;
      case CardType.hobby:
        assetPath = AssetPaths.hobbyCards;
        break;
      case CardType.baggage:
        assetPath = AssetPaths.baggageCards;
        break;
      case CardType.phobia:
        assetPath = AssetPaths.phobiaCards;
        break;
      case CardType.specialCondition:
        assetPath = AssetPaths.specialCards;
        break;
      default:
        assetPath = AssetPaths.professionCards;
    }

    try {
      final jsonString = await rootBundle.loadString(assetPath);
      final jsonData = json.decode(jsonString) as List;

      _cardsByType![type] = jsonData.cast<Map<String, dynamic>>().toList();
      return _cardsByType![type]!;
    } catch (e) {
      _logger.error("Ошибка при загрузке карточек типа $type: $e");

      // Возвращаем заглушки в случае ошибки
      return [
        {
          'title': 'Заглушка для $type',
          'description': 'Заглушка для описания',
          'utility_index': 5,
        }
      ];
    }
  }

  // Получение случайной катастрофы
  Future<CatastropheModel> getRandomCatastrophe() async {
    final catastrophes = await _loadCatastrophes();
    return catastrophes[_random.nextInt(catastrophes.length)];
  }

  // Получение случайного бункера
  Future<ShelterModel> getRandomShelter() async {
    final shelters = await _loadShelters();
    return shelters[_random.nextInt(shelters.length)];
  }

  // Получение случайной карточки определенного типа
  Future<PlayerCardModel> _getRandomCard(CardType type) async {
    final cards = await _loadCardsByType(type);
    final cardData = cards[_random.nextInt(cards.length)];

    return PlayerCardModel(
      id: const Uuid().v4(),
      type: type,
      title: cardData['title'],
      description: cardData['description'],
      isRevealed: false,
      utilityIndex: cardData['utility_index'] ?? 5,
    );
  }

  // Генерация полного набора карточек для игрока
  Future<List<PlayerCardModel>> generatePlayerCards() async {
    final cards = <PlayerCardModel>[];

    // Добавляем по одной карточке каждого типа
    cards.add(await _getRandomCard(CardType.profession));
    cards.add(await _getRandomCard(CardType.biological));
    cards.add(await _getRandomCard(CardType.health));
    cards.add(await _getRandomCard(CardType.hobby));
    cards.add(await _getRandomCard(CardType.baggage));
    cards.add(await _getRandomCard(CardType.phobia));

    // Добавляем с некоторой вероятностью особое условие
    if (_random.nextDouble() < 0.7) {
      cards.add(await _getRandomCard(CardType.specialCondition));
    }

    return cards;
  }
}
