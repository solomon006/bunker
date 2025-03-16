import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bunker/config/di.dart';
import 'package:bunker/config/app_router.dart';
import 'package:bunker/config/app_theme.dart';
import 'package:bunker/config/localization.dart';
import 'package:bunker/presentation/pages/splash_page.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  // Обеспечиваем инициализацию Flutter до запуска приложения
  WidgetsFlutterBinding.ensureInitialized();

  // Принудительное использование портретной ориентации
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Настройка стиля системной навигации на Android
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppTheme.primaryBackground,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Инициализация Hive для локального хранения
  await Hive.initFlutter();

  // Инициализация зависимостей
  await configureDependencies();

  // Запуск приложения
  runApp(const BunkerApp());
}

class BunkerApp extends StatelessWidget {
  const BunkerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Бункер',
      debugShowCheckedModeBanner: false, // Убираем баннер Debug
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Автоматический выбор темы на основе системных настроек
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: AppRouter.splash,
    );
  }
}
