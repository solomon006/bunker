import 'package:get_it/get_it.dart';
import 'package:bunker/core/network/network_service.dart';
import 'package:bunker/core/storage/local_storage.dart';
import 'package:bunker/data/repositories/game_repository.dart';
import 'package:bunker/data/repositories/content_repository.dart';

final GetIt getIt = GetIt.instance;

// Конфигурация зависимостей приложения
Future<void> configureDependencies() async {
  // Инициализация хранилища
  final localStorage = LocalStorage();
  await localStorage.init();
  getIt.registerSingleton<LocalStorage>(localStorage);

  // Регистрация сетевого сервиса
  getIt.registerLazySingleton<NetworkService>(() => NetworkService());

  // Регистрация репозиториев
  getIt.registerLazySingleton<ContentRepository>(() => ContentRepository());

  getIt.registerLazySingleton<GameRepository>(() => GameRepository(
    networkService: getIt<NetworkService>(),
    contentRepository: getIt<ContentRepository>(),
  ));
}
