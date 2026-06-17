import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'models/card_progress.dart';
import 'models/app_state.dart';
import 'services/data_service.dart';
import 'services/progress_service.dart';
import 'services/session_service.dart';
import 'providers/data_provider.dart';
import 'providers/progress_provider.dart';
import 'providers/session_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(CardProgressAdapter());
  Hive.registerAdapter(AppStateAdapter());
  await Hive.openBox<CardProgress>('cardProgress');
  await Hive.openBox<AppState>('appState');

  final appStateBox = Hive.box<AppState>('appState');
  if (appStateBox.isEmpty) {
    appStateBox.add(AppState());
  }

  final dataService = DataService();
  await dataService.load();

  final progressService = ProgressService(dataService: dataService);
  final sessionService = SessionService();

  runApp(
    MultiProvider(
      providers: [
        Provider<DataService>.value(value: dataService),
        ChangeNotifierProvider(create: (_) => DataProvider(dataService)),
        ChangeNotifierProvider(create: (_) => ProgressProvider(progressService)),
        ChangeNotifierProvider(create: (_) => SessionProvider(sessionService)),
      ],
      child: const PrepWiseApp(),
    ),
  );
}

class PrepWiseApp extends StatelessWidget {
  const PrepWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PrepWise',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3A7CA5)),
        useMaterial3: true,
        fontFamily: 'Roboto',
        cardTheme: const CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            minimumSize: const Size.fromHeight(48),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            minimumSize: const Size.fromHeight(48),
          ),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 1,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
