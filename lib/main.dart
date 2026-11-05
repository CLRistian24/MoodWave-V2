import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'providers/mood_provider.dart';
import 'ui/screens/lock_screen.dart';
import 'ui/screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_MX', null);
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => MoodProvider()..loadInitialData(),
      child: const MoodWaveApp(),
    ),
  );
}

class MoodWaveApp extends StatelessWidget {
  const MoodWaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MoodProvider>(
      builder: (context, provider, child) {
        return MaterialApp(
          title: 'MoodWave / Fonn v2.0',
          debugShowCheckedModeBanner: false,
          themeMode: provider.darkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          // La navegación inicia en MainNavigationScreen (que ya contiene AnalyticsScreen en su pestaña)
          home: provider.isUnlocked ? const MainNavigationScreen() : const LockScreen(),
        );
      },
    );
  }
}