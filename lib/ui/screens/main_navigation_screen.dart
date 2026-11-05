import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'calendar_screen.dart';
import 'profile_screen.dart';
import 'analytics_screen.dart';
import 'ai_insights_screen.dart';
import 'new_entry_screen.dart';
import 'settings_screen.dart';
import 'credits_screen.dart';
import 'pin_change_screen.dart';
import 'backup_screen.dart';
import 'reports_screen.dart';
import 'reminders_screen.dart';
import '../../models/mood_entry.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _openEntry(MoodEntry? entry, [DateTime? date]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewEntryScreen(initialEntry: entry, initialDate: date),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onOpenEntry: _openEntry),
      CalendarScreen(onOpenEntry: _openEntry),
      const AnalyticsScreen(),
      const AIInsightsScreen(),
      ProfileScreen(
        onOpenSettings: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (c) => SettingsScreen(
              onChangePin: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => const PinChangeScreen()),
              ),
              onOpenCredits: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => const CreditsScreen()),
              ),
              onOpenBackup: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => const BackupScreen()),
              ),
              onOpenReports: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => const ReportsScreen()),
              ),
              onOpenReminders: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => const RemindersScreen()),
              ),
            ),
          ),
        ),
        onOpenCredits: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (c) => const CreditsScreen()),
        ),
      ),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (idx) => setState(() => _currentIndex = idx),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "Calendario"),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: "Patrones"),
          BottomNavigationBarItem(icon: Icon(Icons.psychology), label: "IA"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),
    );
  }
}